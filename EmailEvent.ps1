   param (
    [string]$to = "YOUREMAIL@example.com",
	[string]$from = "WHATYOURCALLINTTHIS@example.com",
    [string]$subject = "Remote Investigation",
    [string]$body = "This email is to inform you that a remote investigation has comepleted or timed out.",
    [string]$attach = " "
	[string]$MailServer=""
 )
send-mailmessage -to $to -from $from -subject $subject -body $body -smtpServer $MailServer
