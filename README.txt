Flag Popper v. 1.0.02
Author: Andrew Morgan
If you have questions or find any bugs, please feel free to e-mail me at morgana@ecu.edu.
___________

DESCRIPTION
___________


Flag Popper displays customizable pop-up messages for flagged requests whenever they are:

	• Checked in from the lender (Borrowing)

	• Checked in from the patron (Borrowing)

	• Marked found (Lending and Doc Del)

	• Returned from the borrower (Lending)

***Please note that you can only have one addon at a time that uses these processing steps at a time. If you already have an addon turned on that makes use of the processing steps, this will cause a conflict and prevent one of them from working.

The settings can be used to customize the message that displays for each flag's pop-up, as well as whether the flag is always kept or always removed when the request is processed. By default the pop-up will allow the user to choose to keep or remove the flag. If you have a long list of flags to customize, you may want to edit the setting value in the config file (typically located at C:\Program Files (x86)\ILLiad\Addons\Flag Popper) directly.

__________________________

CONFIGURATION INSTRUCTIONS
__________________________

1] CustomFlags setting: The format of this setting must be:

	flag name ~ message_action | second flag name ~ message_action |

Where "flag name" is the name of the flag, "message" is the custom message to display on the pop-up, and "action" specifies whether the flag should always be kept, always be removed, or if the user has the option to do either. The possible values for action are "keep," "remove," or "choose." Example:

	Problem Requests ~ Something's up with this request!_keep | Rush Requests ~ Rush request - don't forget expedited shipping._choose | 

When a request with the "Problem Requests" flag is processed, a pop-up with the message "Something's up with this request!" will appear, and the flag will not be removed. Similarly for requests with the "Rush Requests" flag, but the user will have the option to remove the flag upon processing.

Spaces before and after the ~, _, and | don't matter, so feel free to space them out in a way that makes it easy to read. The trailing | is necessary. Also, be sure not to use any of these symbols in your flag names or messages.

2] HiddenFlags setting: The format of this setting must be:

	flag name_action | second flag name_action | 

Where "flag name" is the name of the flag, and "action" specifies whether the flag should be kept or removed. Example:

	Request Sent - Shipped_remove | Purchased Awaiting Receipt_keep | 

When a request with the "Request Sent - Shipped" flag is processed, the flag will be removed and no message will pop up. When a request with the "Purchased Awaiting Receipt" flag is processed, the flag will be kept and no message will pop up. Defining flags in this setting with "keep" essentially treats them as they would be without the addon.

Spaces before and after the _ and | don't matter, and the trailing | is necessary.