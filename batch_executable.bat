@echo off
REM Activate the Anaconda environment
call C:\Path\To\Anaconda\Scripts\activate.bat markerlessTrackingEnv
REM Run your Python script in a new minimized window
start /b python C:\Path\To\Current\Directory\Python_TS_GUI.py
