-- About Flag Popper.lua (version 1.0.01, 1/31/2019)
-- Author: Andrew Morgan, East Carolina University, morgana@ecu.edu
-- Flag Popper pops flags.
-- But seriously, this addon displays pop-up messages for flagged requests whenever they are:
	-- > Checked in from the lender
	-- > Checked in from the patron
	-- > Marked found in Lending
	-- > Returned from the borrower
-- Settings are used to customize messages displayed in the pop-ups, determine whether the flags are always kept or always removed, or whether the pop-ups are displayed at all for certain flags.

function Silence(str) -- Allows variables containing Lua magic characters to be used as a matchstring. 

	str = str:gsub("%%", "%%%%"):gsub("%(", "%%("):gsub("%)", "%%)"):gsub("%.", "%%."):gsub("%+", "%%+"):gsub("%-", "%%-"):gsub("%*", "%%*"):gsub("%?", "%%?"):gsub("%[", "%%["):gsub("%^", "%%^"):gsub("%$", "%%$");

	return str;
end

function PullData(query) -- Used for SQL queries that will return more than one result.
	local connection = CreateManagedDatabaseConnection();
	function PullData2()
		connection.QueryString = query;
		connection:Connect();
		local results = connection:Execute();
		connection:Disconnect();
		connection:Dispose();
		
		return results;
	end
	
	local success, results = pcall(PullData2, query);
	if not success then
		LogDebug("Problem with SQL query: " .. query .. "\nError: " .. tostring(results));
		connection:Disconnect();
		connection:Dispose();
		return false;
	end
	
	return results;
end

local settings = {};
local list = GetSetting("CustomFlags");
list = list:gsub("%s*|%s*", "|"):gsub("%s*_%s*", "_"):gsub("%s*~%s*", "~"); -- Removes opening/trailing spaces from the list.
settings.CustomFlags = {};

-- Loop puts the settings list into an array.
for ct = 1, select(2, list:gsub("|", "")) do 
	
	local grab = list:match(".-|");
	settings.CustomFlags[ct] = {};
	settings.CustomFlags[ct][1] = grab:match("^.[^~]+"); -- Flag name.
	settings.CustomFlags[ct][2] = grab:match("~[^_]+"):gsub("~", ""); -- Flag message.
	settings.CustomFlags[ct][3] = grab:match("_[^|]+"):gsub("_", ""); -- Keep, remove, or choice.
	
	list = list:gsub(Silence(grab), "");
end

list = GetSetting("HiddenFlags");
list = list:gsub("%s*|%s*", "|"):gsub("%s*_%s*", "_"):gsub("%s*~%s*", "~"); 
settings.HiddenFlags = {};

for ct = 1, select(2, list:gsub("|", "")) do 

	local grab = list:match(".-|");
	settings.HiddenFlags[ct] = {};
	settings.HiddenFlags[ct][1] = grab:match("^.[^_]+"); -- Flag name.
	settings.HiddenFlags[ct][2] = grab:match("_[^|]+"):gsub("_", ""); -- Keep or remove.
	
	list = list:gsub(Silence(grab), "");
end

luanet.load_assembly("System");
luanet.load_assembly("System.Xml");
luanet.load_assembly("System.Windows.Forms");

local message = luanet.import_type("System.Windows.Forms.MessageBox");
local buttons = luanet.import_type("System.Windows.Forms.MessageBoxButtons");
local icons = luanet.import_type("System.Windows.Forms.MessageBoxIcon");
local choice = luanet.import_type("System.Windows.Forms.DialogResult");

function Init()
	RegisterSystemEventHandler("BorrowingRequestCheckedInFromLibrary", "CheckedInFromLender");
	RegisterSystemEventHandler("BorrowingRequestCheckedInFromCustomer", "BorrowingReturns");
	RegisterSystemEventHandler("LendingRequestCheckOut", "LendingMarkFound");
	RegisterSystemEventHandler("LendingRequestCheckIn", "LendingReturns");
	RegisterSystemEventHandler("DocumentDeliveryRequestCheckOut", "DDMarkFound");
end

function FlagPop()
	local tn = GetFieldValue("Transaction", "TransactionNumber");
	
	local query = "SELECT FlagName FROM CustomFlags INNER JOIN TransactionFlags ON TransactionFlags.FlagID = CustomFlags.ID WHERE TransactionNumber = '" .. tn .. "'"; -- Pulls all flags for the transaction being processed.
	
	local results = PullData(query);
	if not results then
		return;
	end
	
	-- Loops through each flag on the transaction.
	for ct = 0, results.Rows.Count - 1 do
		local flag = results.Rows:get_Item(ct):get_Item("FlagName");
		local hidden = false;
		local action = ""; -- Keep, remove, or choose.
		local flagmessage = ""; -- Message to be displayed in pop-up.
		
		-- Loops flag through the array of custom flag settings for a match.
		for dt = 1, #settings.CustomFlags do
			if flag == settings.CustomFlags[dt][1] then
				flagmessage = settings.CustomFlags[dt][2];
				action = settings.CustomFlags[dt][3];
				break;
			else
				flagmessage = flag;
			end
		end
		
		-- Loops flag through the array of hidden flag settings for a match. Since this loop is second, it overrides the custom flag settings.
		for dt = 1, #settings.HiddenFlags do
			if flag == settings.HiddenFlags[dt][1] then
				hidden = true;
				action = settings.HiddenFlags[dt][2];
				break;
			end		
		
		end
		
		if hidden then
			if tostring(action) == "remove" then
				ExecuteCommand("RemoveTransactionFlag", {tn, flag});
			end
		elseif tostring(action) == "keep" then
			message.Show("[" .. flagmessage .. "]\n\n\n\n\tFlag will not be removed.", "Request is flagged");
		elseif tostring(action) == "remove" then
			message.Show("[" .. flagmessage .. "]\n\n\n\n\tFlag will be removed.", "Request is flagged");
			ExecuteCommand("RemoveTransactionFlag", {tn, flag});
		else
			local result = message.Show("[" .. flagmessage .. "]\n\n\n\n\tRemove flag?", "Request is flagged", buttons.YesNo);
			if result == choice.Yes then
				ExecuteCommand("RemoveTransactionFlag", {tn, flag});
			end
		end
	end
end

function CheckedInFromLender(transactionProcessedEventArgs)

	FlagPop();
	
end

function BorrowingReturns(transactionProcessedEventArgs)

	FlagPop();

end

function LendingMarkFound(transactionProcessedEventArgs)

	FlagPop();
	
end

function LendingReturns(transactionProcessedEventArgs)
	
	FlagPop();

end

function DDMarkFound(transactionProcessedEventArgs)

	FlagPop();

end