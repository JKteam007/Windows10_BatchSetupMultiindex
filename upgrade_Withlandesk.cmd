cls
::**************************************************************
::*********Definir les variables *******************************
:: Dossier contenant les drivers pour Windows 10
Set FolderDrivers=c:\PnPDrivers

:: Fichier Log pour ce script
Set LogFile=c:\migrationw10.log

:: Envoi de l'etat d'avancement a LANDESK
Set SendLDMSmessage=YES
:: Nom du serveur LANDESK pour l'envoi des massages
Set LDMSserver=leblogosd.wuibaille.fr

:: Nettoyage du poste
Set CleanupTEMP=YES
Set CleanupLANDESK=YES
Set CleanupCHROME=YES
Set CleanupCLEANMGR=NO
::**************************************************************
::**************************************************************

:InitSynative
@echo off
Set cmdreg=reg
Set cmdpowershell=powershell
Set cmddism=dism
if defined PROCESSOR_ARCHITEW6432 Set cmdreg=%SystemRoot%\sysnative\reg.exe
if defined PROCESSOR_ARCHITEW6432 Set cmdpowershell=%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe
if defined PROCESSOR_ARCHITEW6432 Set cmddism=%SystemRoot%\Sysnative\cmd.exe /c Dism


:GetPendingReboot
%cmdreg% query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v PendingFileRenameOperations
if %ERRORLEVEL% EQU 0 goto PassReboot
echo pass PendingFileRenameOperations
%cmdreg% query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing" /v RebootPending
if %ERRORLEVEL% EQU 0 goto PassReboot
echo pass RebootPending
%cmdreg% query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v RebootRequired
if %ERRORLEVEL% EQU 0 goto PassReboot
echo pass RebootRequired
%cmdreg% query "HKLM\SOFTWARE\Wow6432Node\landesk\managementsuite\WinClient\VulscanReboot"
if %ERRORLEVEL% EQU 0 goto PassReboot
echo pass PassVulscan


:Init
:: %~dp0 ne fonctionne pas apres le clean de chrome
set SourceISO=%~dp0

:CreateFolderDrivers
:: si le dossier existe pas le setup plante
@echo off
md FolderDrivers

:CleanupLogFile
@echo off
if exist %LogFile% Del %LogFile% /F /Q
echo %date%>>%LogFile%
echo %time%>>%LogFile%

:StopAntivirus
If EXIST "c:\program files (x86)\Trend Micro\OfficeScan client\pccntmon.exe" "c:\program files (x86)\Trend Micro\OfficeScan client\pccntmon.exe" -n Kiabi@2010

:CleaupTemp
@echo off
IF %CleanupTEMP% EQU YES (
echo del c:\temp\*.* /S /Q>>%LogFile%
if exist c:\temp del c:\temp\*.* /S /Q
echo del c:\windows\temp\*.* /S /Q>>%LogFile%
del c:\windows\temp\*.* /S /Q
)

:CleaupLandesk
@echo off
IF %CleanupLANDESK% EQU YES (
echo rm "C:\Program Files (x86)\LANDesk\LDClient\sdmcache">>%LogFile%
:: Vidage du cache LANDESK ATTENTION ne pas eclure les sources de Windows 10
if exist "C:\Program Files (x86)\LANDesk\LDClient\sdmcache\refinst\packageW7" FOR /D %%p IN ("C:\Program Files (x86)\LANDesk\LDClient\sdmcache\refinst\packageW7\*.*") DO rmdir "%%p" /s /q
if exist "C:\Program Files (x86)\LANDesk\LDClient\sdmcache\ToolsW7" FOR /D %%p IN ("C:\Program Files (x86)\LANDesk\LDClient\sdmcache\ToolsW7\*.*") DO rmdir "%%p" /s /q
if exist "C:\Program Files (x86)\LANDesk\LDClient\sdmcache\Log" FOR /D %%p IN ("C:\Program Files (x86)\LANDesk\LDClient\sdmcache\Log\*.*") DO rmdir "%%p" /s /q
if exist "C:\Program Files (x86)\LANDesk\LDClient\sdmcache\Store" FOR /D %%p IN ("C:\Program Files (x86)\LANDesk\LDClient\sdmcache\Store\*.*") DO rmdir "%%p" /s /q
if exist "C:\Program Files\LANDesk\LDClient\sdmcache\refinst\packageW7" FOR /D %%p IN ("C:\Program Files\LANDesk\LDClient\sdmcache\refinst\packageW7\*.*") DO rmdir "%%p" /s /q
if exist "C:\Program Files\LANDesk\LDClient\sdmcache\ToolsW7" FOR /D %%p IN ("C:\Program Files\LANDesk\LDClient\sdmcache\ToolsW7\*.*") DO rmdir "%%p" /s /q
if exist "C:\Program Files\LANDesk\LDClient\sdmcache\Log" FOR /D %%p IN ("C:\Program Files\LANDesk\LDClient\sdmcache\Log\*.*") DO rmdir "%%p" /s /q
if exist "C:\Program Files\LANDesk\LDClient\sdmcache\Store" FOR /D %%p IN ("C:\Program Files\LANDesk\LDClient\sdmcache\Store\*.*") DO rmdir "%%p" /s /q
)

:CleanupCLEANMGR
@echo off
IF %CleanupCLEANMGR% EQU YES (
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders" /v StateFlags1337 /t REG_DWORD /d 2 /f
:: %cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\BranchCache" /v StateFlags1337 /t REG_DWORD /d 2 /f
:: %cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Content Indexer Cleaner" /v StateFlags1337 /t REG_DWORD /d 2 /f
:: %cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\D3D Shader Cache" /v StateFlags1337 /t REG_DWORD /d 2 /f
:: %cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Delivery Optimization Files" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Device Driver Packages" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Diagnostic Data Viewer database files" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files" /v StateFlags1337 /t REG_DWORD /d 2 /f
:: %cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Microsoft Office Temp Files" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Offline Pages Files" /v StateFlags1337 /t REG_DWORD /d 2 /f
:: %cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin" /v StateFlags1337 /t REG_DWORD /d 2 /f
:: %cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\RetailDemo Offline Content" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Service Pack Cleanup" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files" /v StateFlags1337 /t REG_DWORD /d 2 /f
:: %cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files" /v StateFlags1337 /t REG_DWORD /d 2 /f
:: %cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Sync Files" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Upgrade Discarded Files" /v StateFlags1337 /t REG_DWORD /d 2 /f
:: %cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\User file versions" /v StateFlags1337 /t REG_DWORD /d 2 /f
:: %cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Defender" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Files" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows ESD installation files" /v StateFlags1337 /t REG_DWORD /d 2 /f
%cmdreg% add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files" /v StateFlags1337 /t REG_DWORD /d 2 /f
echo cleanmgr.exe /SAGERUN:1337>>%LogFile%
cleanmgr.exe /SAGERUN:1337
)

:CleanupChrome
@echo off
IF %CleanupCHROME% EQU YES (
@echo on
cd /d C:\Users
for /d %%z in (C:\Users\*) do (
	del %%z\AppData\Local\Temp\* /S /Q
	for /d %%y in (%%z\AppData\Local\Temp\*) do @rd /s /q "%%y"
	echo del "%%z\AppData\Local\Google\Chrome\User Data\Default>>%LogFile%
	del "%%z\AppData\Local\Google\Chrome\User Data\Default\*.tmp" /S /Q
	del "%%z\AppData\Local\Google\Chrome\User Data\Default\Cache\*" /S /Q
	del "%%z\AppData\Local\Google\Chrome\User Data\Default\Application Cache\Cache\*" /S /Q
	del "%%z\AppData\Local\Google\Chrome\User Data\Default\GPUCache\*" /S /Q
	del "%%z\AppData\Local\Google\Chrome\User Data\Default\Media Cache\*" /S /Q
	del "%%z\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" /S /Q
)
)


@echo off
:InitCulture
:: Get culture du poste
%cmdpowershell% -command [CultureInfo]::InstalledUICulture.Name>c:\windows\temp\InstalledUICulture.txt
set /p culture= < c:\windows\temp\InstalledUICulture.txt
findstr /m "CultureInfo" c:\windows\temp\InstalledUICulture.txt
IF %ERRORLEVEL% EQU 0 set culture=%Language%


@echo off
:InitOS
FOR /F "tokens=2 delims==" %%A IN ('wmic os get Caption /VALUE ^| FIND /I "Caption="') DO SET OSversion=%%A
SET SerialW10=W269N-WFGWX-YVC9B-4J6C9-T83GX
Set IndexISO=%IndexPro%
Set ProEnt=Pro
echo %OSversion% | findstr /c:"Ent" >nul
IF %ERRORLEVEL% EQU 0  (
SET SerialW10=NPPR9-FWDCX-D2C8J-H872K-2YT43
Set IndexISO=%IndexEnt%
Set ProEnt=Ent
)
Set VersionWin=Windows10
echo %OSversion% | findstr /c:"7" >nul
IF %ERRORLEVEL% EQU 0  (
Set VersionWin=Windows7
)

:: ###########################################################
echo culture=%culture%
echo culture=%culture%>>%LogFile%
echo ProEnt=%ProEnt%
echo ProEnt=%ProEnt%>>%LogFile%
echo VersionWin=%VersionWin%
echo VersionWin=%VersionWin%>>%LogFile%
:: ###########################################################

:: ################# Set WimFile and Index ###################
IF %culture% EQU en-US IF %ProEnt% EQU Pro Set IndexWIM=2
IF %culture% EQU en-US IF %ProEnt% EQU Ent Set IndexWIM=1

IF %culture% EQU es-ES IF %ProEnt% EQU Pro Set IndexWIM=4
IF %culture% EQU es-ES IF %ProEnt% EQU Ent Set IndexWIM=3

IF %culture% EQU fr-FR IF %ProEnt% EQU Pro Set IndexWIM=6
IF %culture% EQU fr-FR IF %ProEnt% EQU Ent Set IndexWIM=5

IF %culture% EQU it-IT IF %ProEnt% EQU Pro Set IndexWIM=8
IF %culture% EQU it-IT IF %ProEnt% EQU Ent Set IndexWIM=7

IF %culture% EQU nl-NL IF %ProEnt% EQU Pro Set IndexWIM=10
IF %culture% EQU nl-NL IF %ProEnt% EQU Ent Set IndexWIM=9

IF %culture% EQU pt-BR IF %ProEnt% EQU Pro Set IndexWIM=14
IF %culture% EQU pt-BR IF %ProEnt% EQU Ent Set IndexWIM=13

IF %culture% EQU pt-PT IF %ProEnt% EQU Pro Set IndexWIM=12
IF %culture% EQU pt-PT IF %ProEnt% EQU Ent Set IndexWIM=11

IF %culture% EQU ro-RO IF %ProEnt% EQU Pro Set IndexWIM=16
IF %culture% EQU ro-RO IF %ProEnt% EQU Ent Set IndexWIM=15

IF %culture% EQU ru-RU IF %ProEnt% EQU Pro Set IndexWIM=17

echo IndexWIM=%IndexWIM%
echo IndexWIM=%IndexWIM% >>%LogFile%

:: ###########################################################


:: ################# Step 4 Start Setup ##########################################
if %SendLDMSmessage% EQU YES "%LDMS_LOCAL_DIR%\..\SendTaskStatus.exe" -core=%LDMSserver% -taskid=%task_ID% -retcode=%errorlevel% -message=Setupexe
echo ********** StartSetup ********************************
echo ********** StartSetup ********************************>>%LogFile%

@echo off
:StartSetup
echo setupexe="%SourceISO%setup.exe"
echo setupexe="%SourceISO%setup.exe" /quiet /auto Upgrade /installfrom "%SourceISO%IndexMUI.wim" /imageindex %IndexWIM% /installdrivers %FolderDrivers% /DynamicUpdate Disable /compat IgnoreWarning /CopyLogs c:\Windows\temp\upgradeW10 /noreboot>>%LogFile%
start /wait "setup" "%SourceISO%setup.exe" /quiet /auto Upgrade /installfrom "%SourceISO%IndexMUI.wim" /imageindex %IndexWIM% /installdrivers %FolderDrivers% /DynamicUpdate Disable /compat IgnoreWarning /CopyLogs c:\Windows\temp\upgradeW10 /noreboot
Set RetourCode=%errorlevel%

@echo off
:Fin
Echo RetourCode=%RetourCode%
Echo RetourCode=%RetourCode% >>%LogFile%
if %SendLDMSmessage% EQU YES "%LDMS_LOCAL_DIR%\..\SendTaskStatus.exe" -core=%LDMSserver% -taskid=%task_ID% -retcode=%RetourCode% -message=%RetourCode%
Exit /B %RetourCode%


:PassReboot
if %SendLDMSmessage% EQU YES "%LDMS_LOCAL_DIR%\..\SendTaskStatus.exe" -core=%LDMSserver% -taskid=%task_ID% -retcode=%errorlevel% -message=PendingReboot
echo ********** PendingReboot ********************************
echo ********** PendingReboot ********************************>>%LogFile%
Exit /B 1000
