@echo off
setlocal EnableDelayedExpansion


set ESC=
set BEL=

title Todo Application

rem menu options
set menu[0]=View List
set menu[1]=New Todo
set menu[2]=Exit

set /a currentOption=0
set /a currentTodo=0

rem display main menu
:menu
    cls
    call :DisplayHeader
    set /a countOption=0
    for /l %%i in (0,1,2) do (
        if !countOption! neq !currentOption! (
            echo ^< !menu[%%i]! ^>
        ) else (
            echo ^<%ESC%[7m !menu[%%i]! %ESC%[0m^>
        )
        set /a countOption+=1
    )

    echo.
    choice /c wsc /m "navigate up, down and continue"

    if %errorlevel% equ 1 set /a currentOption-=1
    if %errorlevel% equ 2 set /a currentOption+=1
    if %errorlevel% equ 3 (
        if !currentOption! equ 0 goto listtodos
        if !currentOption! equ 1 goto newtodo
        if !currentOption! equ 2 exit
    )

    if !currentOption! gtr 2 set /a currentOption=0
    if !currentOption! lss 0 set /a currentOption=2

    goto menu

rem add a new todo to the list
:newtodo
    cls
    call :DisplayHeader
    set /p todo=What you want to do? 
    if "%todo%" neq "" echo 0,%todo%>>todo.txt
    goto menu

rem view todo list
:listtodos
    cls
    call :DisplayHeader
    echo This is your todo list:
    echo.

    set /a todocount=0

    for /f "usebackq tokens=1-2 delims=," %%a in ("todo.txt") do (
        if %%a equ 0 set sign= 
        if %%a equ 1 set sign=x
        if !currentTodo!==!todocount! (
            echo   %ESC%[7m[!sign!] %%b%ESC%[0m
        ) else (
            echo   [!sign!] %%b
        )
        
        set /a todocount+=1
    )

    set /a todocount-=1

    if !todocount! equ -1 echo   %ESC%[47m%ESC%[31;1mYour todo list is empty%ESC%[0m

    echo.
    choice /c wstrq /m "navigate up, down, toggle status, remove or quit"

    if %errorlevel% equ 1 set /a currentTodo-=1
    if %errorlevel% equ 2 set /a currentTodo+=1
    if %errorlevel% equ 3 (
        rem toggle todo status
        set /a _i=0
        for /f "usebackq tokens=1-2 delims=," %%a in ("todo.txt") do (
            if !currentTodo!==!_i! (
                if %%a equ 0 set /a status=1
                if %%a equ 1 set /a status=0
            ) else (
                set /a status=%%a
            )

            echo !status!,%%b>>todo.new.txt
            
            set /a _i+=1
        )
        move todo.new.txt todo.txt
    )
    if %errorlevel% equ 4 (
        rem remove todo
        set /a _i=0
        type nul>todo.new.txt
        for /f "usebackq tokens=*" %%l in ("todo.txt") do (
            if !currentTodo! neq !_i! (
                echo %%l>>todo.new.txt
            ) 
            set /a _i+=1
        )
        if !currentTodo! equ !todocount! set /a currentTodo-=1
        move todo.new.txt todo.txt
    )
    if %errorlevel% equ 5 goto menu

    if !currentTodo! gtr !todocount! set /a currentTodo=0
    if !currentTodo! lss 0 set /a currentTodo=!todocount!

    goto listtodos

exit

rem define subroutines

:DisplayHeader
    echo %ESC%[92mTODO Application
    echo ----------------%ESC%[0m
exit /b