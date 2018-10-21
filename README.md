## A script to remotley run RedLine
The script is a Batch Script i made to drop and Run RedLine on a remote machine. This has helped me hunt the red team.

# The info
The term dropper here is used to describe the deployment packages that the redline tool can create for you. You will need the DIr to be named something you will know what it does. This script will take that Dir and everything in it drop it on the remote machine and run it remotely. It will then check in on an interval to see if the process is complete (it also may timeout after a number of checks). WHen comeplete it will try to email you or will tell you it failed.

# Requirements
-Scipt requires you to have Admin rights,Access, and WMI open on source and destination machines.

  -Yes you can modify the script to run PsExec instead of wmi by replacing any wmic calls with PsExec and keeping the same args.
  
-Please run setup file to create the pre reqs

-For email to work you will need to allow smtp relay on a mail server you tell it to send emails to and setup email script or args in bat file

# Where to get RedLine
The tool RedLine made by FireEye can be found here: https://www.fireeye.com/services/freeware/redline.html

# Legal
THIS IS OPEN SOURCE SOFTWARE AND NOT READY FOR PRODUCTION, YET! If you use this software you do so at your own risk and the liability is with you. Note that the author is not responsible for the way the product is used and the software comes without warrenty. If you use the software (this means execution of it on a system) you acknowledge that you accept any risk or outcome with the use of the software. I have NEVER authorized, condoned, or recommend the use of anything in any of my repos for any malicious reason. Do not use for evil, malicious purposes, or on machines you do not own. I recommend that you always TEST it before you use it or deploy it. Use at your own risk.
