@echo off
:: Step 1: Find Conda Info Path
:: Find where conda is installed by using `conda info --base`
set "base_path="

for %%D in (
    "%USERPROFILE%\anaconda3"
    "%USERPROFILE%\miniconda3"
    "%LOCALAPPDATA%\anaconda3"
    "%LOCALAPPDATA%\miniconda3"
    "C:\ProgramData\anaconda3"
    "C:\ProgramData\Anaconda3"
    "C:\ProgramData\miniconda3"
    "C:\ProgramData\Miniconda3"
    "C:\Anaconda3"
    "C:\Miniconda3"
    "C:\Users\%USERNAME%\Anaconda3"
    "C:\Users\%USERNAME%\Miniconda3"
    "C:\Users\%USERNAME%\AppData\Local\anaconda3"
    "C:\Users\%USERNAME%\AppData\Local\Miniconda3"
) do (
    if exist "%%~D\Scripts\activate.bat" (
        set "base_path=%%~D"
        goto found_conda
    )
)

where conda >nul 2>nul
if %errorlevel%==0 (
    for /f "delims=" %%a in ('conda info --base') do set "base_path=%%a"
    goto found_conda
)

echo Conda installation not found.
set /p "base_path=Enter the full path to your Anaconda/Miniconda installation (e.g., C:\Anaconda3): "

if not exist "%base_path%\Scripts\activate.bat" (
    echo activate.bat was not found at:
    echo %base_path%\Scripts\activate.bat
    pause
    exit /b 1
)

:found_conda
echo Using Conda base path: %base_path%

:: Get the current directory of the batch script
set "current_dir=%cd%"
echo Current directory is: %current_dir%

:: --- Setup for newEnv1 ---

:: Set paths for new environment newEnv1
set "new_env1_name=mediaPipeEnv"
set "new_env1_path=%base_path%\envs\%new_env1_name%"

:: Step 2: Create the environment directory for newEnv1
mkdir "%new_env1_path%"
echo The mediapipe environment directory being set up is: %new_env1_path%

:: Step 3: Unpack the tar.gz file for newEnv1
tar -xzf "%cd%\%new_env1_name%.tar.gz" -C "%new_env1_path%"

:: Step 4: Activate the conda environment for newEnv1 and run conda-unpack
call %base_path%\Scripts\activate.bat %new_env1_name%
conda-unpack

echo Environment for MediaPipe is set. Continuing with setting up the GUI environment.
pause

:: --- Setup for newEnv2 ---

:: Set paths for new environment newEnv2
set "new_env2_name=markerlessTrackingEnv"
set "new_env2_path=%base_path%\envs\%new_env2_name%"

:: Step 5: Create the environment directory for newEnv2
mkdir "%new_env2_path%"
echo The anipose environment directory being set up is: %new_env2_path%

:: Step 6: Unpack the tar.gz file for newEnv2
tar -xzf "%cd%\%new_env2_name%.tar.gz" -C "%new_env2_path%"

echo The GUI environment is installing. This can take approx. 20-40 mins.

:: Step 7: Activate the conda environment for newEnv2 and run conda-unpack
call %base_path%\Scripts\activate.bat %new_env2_name%
conda-unpack

:: Step 8: Test the 'anipose' command in newEnv2
echo Running 'anipose' test in environment %new_env2_name%
anipose

if %ERRORLEVEL%==0 (
    echo "Anipose ran successfully in %new_env2_name%. Continue to path changes."
) else (
    echo "Anipose command failed. Please check the environment setup."
)

pause


:: --- Modify batch_execution.bat and TrackStudio.vbs ---

:: --- Modify batch_execution.bat ---
set "batch_file=batch_executable.bat"
set "temp_batch_file=%batch_file%.new"

echo Current directory is: %current_dir%
setlocal enabledelayedexpansion

:: Check if the batch_execution.bat exists
if not exist "%batch_file%" (
    echo ERROR: File "%batch_file%" not found in the current directory.
    pause
    exit /b 1
)

:: Create a temporary file for writing the updated content
if exist "%temp_batch_file%" del "%temp_batch_file%"

:: Create a temporary file to store the modified content
(
    :: Read each line of the file
    for /f "delims=" %%a in (%batch_file%) do (
        set "line=%%a"
        
        :: Perform replacements
        set "line=!line:C:\Path\To\Anaconda\Scripts=%base_path%\Scripts!"
        set "line=!line:C:\Path\To\Current\Directory=%current_dir%!"

        :: Output the modified line
        echo !line!
    )
) > %temp_batch_file%

:: Debugging: Confirm writing to the new file
if not exist "%temp_batch_file%" (
    echo ERROR: Temporary file "%temp_batch_file%" could not be created.
    pause
    exit /b 1
)


:: Replace the old batch_execution.bat with the new one
move /Y "%temp_batch_file%" "%batch_file%"

echo Successfully updated "%batch_file%"


:: Define the VBS file to modify
set "vbs_file=TrackStudio.vbs"
set "temp_vbs_file=%vbs_file%.new"

:: Check if the VBS file exists
if not exist "%vbs_file%" (
    echo ERROR: File "%vbs_file%" not found in the current directory.
    pause
    exit /b 1
)

:: Create a temporary file for writing the updated content
if exist "%temp_vbs_file%" del "%temp_vbs_file%"

:: Read each line of the file and perform replacements
(
    for /f "delims=" %%a in ('type "%vbs_file%"') do (
        set "line=%%a"
        
        :: Perform replacements
        set "line=!line:C:\Path\To\Current\Directory=%current_dir%!"

        :: Output the modified line
        echo !line!
    )
) > "%temp_vbs_file%"
pause

:: Replace the old TrackStudio.vbs with the new one
move /Y "%temp_vbs_file%" "%vbs_file%"

echo All tasks completed!
pause