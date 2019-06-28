@Echo off

start chrome http://localhost:8000
if %ERRORLEVEL% neq 0 goto tryMozilla

php -S localhost:8000
if %ERRORLEVEL% neq 0 goto phpError

:tryMozilla
@rem start firefox https://www.google.co.in/
if %ERRORLEVEL% neq 0 goto browserFail

:phpError
@rem echo PHP not installed
exit /b 0

:browserFail
@rem echo No compatible browser found
exit /b 1

PAUSE