## Remote_RedLine
The script is a Batch Script to drop and Run RedLine on a remote machine.

# The info
The term dropper here is used to describe the deployment packages that the redline tool can create for you. You will need the DIr to be named something you will know what it does. This script will take that Dir and everything in it drop it on the remote machine and run it remotely. It will then check in on an interval to see if the process is complete (it also may timeout after a number of checks). WHen comeplete it will try to email you or will tell you it failed.

# Requirements
-Scipt requires you to have Admin rights,Access, and WMI open on source and destination machines.
  -Yes you can modify the script to run PsExec instead of wmi by replacing any wmic calls with PsExec and keeping the same args.
-Please run setup file to create the pre reqs
-For email to work you will need to allow smtp relay on a mail server you tell it to send emails to

The tool RedLine made by FireEye can be found here: https://www.fireeye.com/services/freeware/redline.html
