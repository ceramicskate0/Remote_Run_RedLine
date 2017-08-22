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
