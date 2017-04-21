@echo off
echo  --------------------------------------
echo  {     Remote Investigation  Script   }
echo  --------------------------------------
echo  -------------Step1--------------------
echo Collecting system date time info...
for /f "tokens=1-4 delims=/ " %%i in ("%date%") do (
     set dow=%%i
     set month=%%j
     set day=%%k
     set year=%%l
   )
set datestr=%month%_%day%_%year%
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set Thetime=%%a%%b)
goto Step2

:Step2
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set Thetime=%%a%%b)
echo  -------------Step2 %datestr%_%Thetime%--------------------
set /p IP=Enter IP or hostname:
set /p AdminAcct=Enter LOCAL Admin Account on remote machine:
set /p AdminAcctJustname=Enter either Domain\AccountName or just account name if local for the account above:
set /p AdmiNPWD=Enter above accounts Password:
cd C:\Tools\RedLineAnalysis\
dir /A:D
set /p Collector=Enter folder name of the collector to us:
echo USING COLLECOTR: C:\Tools\RedLineAnalysis\%Collector%
if not exist "C:\Tools\RedLineAnalysis\%Collector%" goto Step2
echo Started Analisys for Target:%IP% Account:%AdminAcct% collector:%Collector%
::Variable Settings
set CollectorLoc=C:\Tools\RedLineAnalysis\%Collector%
set LocationOfRedLineOnRemoteMachine=\\%IP%\c$\RedLine\%Collector%
set AnalysisStroage=C:\Tools\RedLineAnalysis\Analysis
set HostAnalysisLoc=C:\Redline\%Collector%
set RunFile=%HostAnalysisLoc%\RunRedlineAudit.bat
set EmailScriptLocation=C:\Tools\RedLineAnalysis\EmailEvent.ps1
set LogFile=C:\Tools\RedLineAnalysis\%IP%_Log_%datestr%.txt
if exist %LogFile% del /Q %LogFile%
type nul >%LogFile%
echo APP START %datestr%_%Thetime%>> %LogFile%
echo  -------------Step2_%datestr%_%Thetime%-------------------->> %LogFile%
echo Started Analisys for Target:%IP% Account:%AdminAcct% Collector:%Collector%>> %LogFile%
goto GETDISKSPACEONCLIENT

:Step3
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set Thetime=%%a%%b)
echo  ------------Step3 %datestr%_%Thetime%------------------->> %LogFile%
echo  ------------Step3 %datestr%_%Thetime%-------------------
cd "C:\Tools\RedLineAnalysis\"
wmic /node:%IP% /user:%AdminAcct% /password:"%AdmiNPWD%" process call create "cmd /C mkdir %HostAnalysisLoc%">> %LogFile%
start /wait xcopy "%CollectorLoc%\*" "%LocationOfRedLineOnRemoteMachine%" /Y /I /S /E>> %LogFile%
IF '%ERRORLEVEL%'=='0' (
  echo WMIC claims it ran as expected...>> %LogFile%
  echo WMIC claims it ran as expected...
  if Not exist %LocationOfRedLineOnRemoteMachine%\Sessions goto FailToStart
set /a x=0
echo Confirmed analysis started on remote machine %IP%>> %LogFile%
echo Confirmed analysis started on remote machine %IP%
goto RemoteProcessRunningCheck

:RemoteProcessRunningCheck
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set Thetime=%%a%%b)
echo -------------Process running check %datestr%_%Thetime%------------>> %LogFile%
echo -------------Process running check %datestr%_%Thetime%------------
echo Checking to see if key file exists on client machine>> %LogFile%
echo Checking to see if key file exists on client machine
if exist "%LocationOfRedLineOnRemoteMachine%\Sessions\AnalysisSession1\AnalysisSession1.mans" goto ENDandKill
echo Key file does not exist on client machine yet, script not done running>> %LogFile%
echo Key file does not exist on client machine yet, script not done running
goto WAIT

:WAIT
start /wait C:\Windows\System32\timeout.exe /T 900
echo Completed Check-in %x% of 12>> %LogFile%
echo Completed Check-in %x% of 12
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set Thetime=%%a%%b)
set /a x+=1
echo -------------Waiting on app to finish_%Thetime%-------------------->> %LogFile%
echo -------------Waiting on app to finish_%Thetime%--------------------
if %x% EQU 3 goto GETDISKSPACEONCLIENT
if %x% EQU 6 goto GETDISKSPACEONCLIENT
if %x% EQU 9 goto GETDISKSPACEONCLIENT
if %x% EQU 12 goto GETDISKSPACEONCLIENT
goto RemoteProcessRunningCheck

:NOTENOUGHSPACE
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set Thetime=%%a%%b)
echo  -----------Not Enough Disk Space %datestr%_%Thetime%------------------->> %LogFile%
echo  -----------Not Enough Disk Space %datestr%_%Thetime%-------------------
echo ERROR: NOT ENOGH SPACE ON MACHINE TO RUN OR CONTINUE JOB>> %LogFile%
echo ERROR: NOT ENOGH SPACE ON MACHINE TO RUN OR CONTINUE JOB
set /p override=Do you want to override safe guards y or n:
echo override value : %override%>> %LogFile%
echo override value : %override%
if "%override%" == "y" goto Step3
if "%override%" == "n" echo - Not enough space on user machine to run tool. Admin chose to exit on override question. Free Space %FreeSpace%GB on %IP%..exiting app>> %LogFile%
timeout /T 5
EXIT /B

:GETDISKSPACEONCLIENT
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set Thetime=%%a%%b)
echo  ---------Disk Space Check %datestr%_%Thetime%------------------->> %LogFile%
echo  ---------Disk Space Check %datestr%_%Thetime%-------------------
@SETLOCAL ENABLEEXTENSIONS
@SETLOCAL ENABLEDELAYEDEXPANSION
@FOR /F "tokens=1-3" %%n IN ('"WMIC /node:"%IP%" LOGICALDISK GET Name,Size,FreeSpace | find /i "C""') DO @SET FreeBytes=%%n & @SET TotalBytes=%%p
@SET /A TotalSpace=!TotalBytes:~0,-9!
@SET /A FreeSpace=!FreeBytes:~0,-10!
@SET /A TotalUsed=%TotalSpace% - %FreeSpace%
@SET /A PercentUsed=(!TotalUsed!*100)/!TotalSpace!
@SET /A PercentFree=100-!PercentUsed!
@ECHO Total space: %TotalSpace%GB>> %LogFile%
@ECHO Free space: %FreeSpace%GB>> %LogFile%
@ECHO Used space: %TotalUsed%GB>> %LogFile%
@ECHO Percent Used: %PercentUsed%%%>> %LogFile%
@ECHO Percent Free: %PercentFree%%%>> %LogFile%
IF /I "%x%" EQU "6" (
	IF /I %FreeSpace% LSS "3" goto EndandKillNotEnoughSpace
) ELSE (
	IF /I "%x%" EQU "12" (
		IF /I %FreeSpace% LSS "5" goto EndandKillNotEnoughSpace
		IF /I %FreeSpace% GEQ "5" goto ENDandRun
	)
)
if %FreeSpace% LSS "1" goto EndandKillNotEnoughSpace
if %FreeSpace% LSS "3" goto NOTENOUGHSPACE
goto Step3

:ENDandRun
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set Thetime=%%a%%b)
echo ------------EndandRun %datestr%_%Thetime%------------->> %LogFile%
echo ------------EndandRun %datestr%_%Thetime%-------------
echo Exiting app %datestr%_%Thetime%. Not killing running process on remote machine. User expected to retrieve files>> %LogFile%
echo Exiting app %datestr%_%Thetime%. Not killing running process on remote machine. User expected to retrieve files
mkdir "%AnalysisStroage%%IP%_%datestr%">> %LogFile%
move %LogFile% %AnalysisStroage%%IP%_%datestr%
if exist "%AnalysisStroage%%IP%_%datestr%\AnalysisSession1\AnalysisSession1.mans" Powershell.exe -executionpolicy remotesigned -file "%EmailScriptLocation%" -subject "%USERNAME% your Remote Investigation of %IP% has COMPLETED" -body "Analysis %Collector% completed on %IP% but failed to get files to Stageing server. Likely due to timeout. Lcoation: LocationOfRedLineOnRemoteMachine%\Sessions\AnalysisSession1\"
if Not exist "%AnalysisStroage%%IP%_%datestr%\AnalysisSession1\AnalysisSession1.mans" Powershell.exe -executionpolicy remotesigned -file "%EmailScriptLocation%" -subject "%USERNAME% your  Remote Investigation of %IP% has TIMEDOUT" -body "Once Analysis %Collector% is comeplete it will be Located: %LocationOfRedLineOnRemoteMachine%\Sessions\AnalysisSession1\"
EXIT /B

:FailToStart
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set Thetime=%%a%%b)
echo ------------FailToStart %datestr%_%Thetime%------------->> %LogFile%
echo ------------FailToStart %datestr%_%Thetime%-------------
echo PsExec and wmic failed to start remote investigation app...>> %LogFile%
echo PsExec and wmic failed to start remote investigation app moving log file...
mkdir "%AnalysisStroage%%IP%_%datestr%">> %LogFile%
move %LogFile% %AnalysisStroage%%IP%_%datestr%
Powershell.exe -executionpolicy remotesigned -file "%EmailScriptLocation%" -subject "%USERNAME% your Remote Investigation of %IP% has an ERROR" -body "Error running %Collector% collector, unable to start remote investigation on remote system likley due to the account used doesnt have permissions. Analysis Canceled and files removed."
EXIT /B

:EndandKillNotEnoughSpace
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set Thetime=%%a%%b)
echo  -----------EndandKillNotEnoughSpace %datestr%_%Thetime%---------------------->> %LogFile%
echo  -----------EndandKillNotEnoughSpace %datestr%_%Thetime%----------------------
echo Exiting app %datestr%_%Thetime%, Moving files, and Killing processes>> %LogFile%
echo Exiting app %datestr%_%Thetime%, Moving files, and Killing processes
mkdir "%AnalysisStroage%%IP%_%datestr%">> %LogFile%
if exist "%LocationOfRedLineOnRemoteMachine%\Sessions\AnalysisSession1.mans" start /wait xcopy "%LocationOfRedLineOnRemoteMachine%\Sessions\*" "%AnalysisStroage%%IP%_%datestr%\" /Y /I /S /E>> %LogFile%
taskkill /S %IP% /u %AdminAcct% /P %AdmiNPWD% /FI "USERNAME eq %AdminAcctJustname%">> %LogFile%
wmic /node:%IP% /user:%AdminAcct% /password:"%AdmiNPWD%" process call create "cmd.exe /C "rmdir /Q /S C:\Redline">> %LogFile%
move %LogFile% %AnalysisStroage%%IP%_%datestr%
if exist "%AnalysisStroage%%IP%_%datestr%\AnalysisSession1\AnalysisSession1.mans" Powershell.exe -executionpolicy remotesigned -file "%EmailScriptLocation%" -subject "%USERNAME% your Remote Investigation of %IP% has COMPLETED" -body "Disk space was low on target machiens drive. However, Anlaysis %Collector% completed successfully and is located on Stageing server %AnalysisStroage%%IP%_%datestr%. All file son target removed."
if Not exist "%AnalysisStroage%%IP%_%datestr%\AnalysisSession1\AnalysisSession1.mans" Powershell.exe -executionpolicy remotesigned -file "%EmailScriptLocation%" -subject "%USERNAME% your Remote Investigation of %IP% had an ERROR" -body "Error running %Collector% collector, disk space is either to low to, unable to continue after timeout, unable to access remote machine with account provided. Analysis Canceled and files removed."
EXIT /B

:ENDandKill
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set Thetime=%%a%%b)
echo  -----------EndandKill %datestr%_%Thetime%---------------------->> %LogFile%
echo  -----------EndandKill %datestr%_%Thetime%----------------------
echo Exiting app %datestr%_%Thetime%, Moving files, and Killing processes>> %LogFile%
echo Exiting app %datestr%_%Thetime%, Moving files, and Killing processes
mkdir "%AnalysisStroage%%IP%_%datestr%">> %LogFile%
start /wait xcopy "%LocationOfRedLineOnRemoteMachine%\Sessions\*" "%AnalysisStroage%%IP%_%datestr%\" /Y /I /S /E>> %LogFile%
taskkill /S %IP% /u %AdminAcct% /P %AdmiNPWD% /FI "USERNAME eq %AdminAcctJustname%">> %LogFile%
wmic /node:%IP% /user:%AdminAcct% /password:"%AdmiNPWD%" process call create "cmd.exe /C rmdir /Q /S C:\Redline">> %LogFile%
move %LogFile% %AnalysisStroage%%IP%_%datestr%
if exist "%AnalysisStroage%%IP%_%datestr%\AnalysisSession1\AnalysisSession1.mans" Powershell.exe -executionpolicy remotesigned -file "%EmailScriptLocation%" -subject "%USERNAME% your Remote Investigation of %IP% has COMPLETED" -body "Anlaysis %Collector% completed successfully and is located on Stageing server %AnalysisStroage%%IP%_%datestr%"
if Not exist "%AnalysisStroage%%IP%_%datestr%\AnalysisSession1\AnalysisSession1.mans" Powershell.exe -executionpolicy remotesigned -file "%EmailScriptLocation%" -subject "%USERNAME% your  Remote Investigation of %IP% has an ERROR" -body "Error running %Collector% collector,the app timeout. Analysis Canceled on client and any created files moved to server."
EXIT /B
