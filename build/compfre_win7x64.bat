@echo off
set ddkpath=C:\WinDDK\7600.16385.1\bin\x86
set incpath=C:\WinDDK\7600.16385.1\inc
set libpath=C:\WinDDK\7600.16385.1\lib
set binpath=..\bin\compfre_win7x64
set objpath=..\bin\compfre_win7x64\Intermediate

title Compiling NoirVisor, Free Build, 64-Bit Windows (AMD64 Architecture)
echo Project: NoirVisor
echo Platform: 64-Bit Windows
echo Preset: Release/Free Build
echo Powered by zero.tangptr@gmail.com
echo Copyright 2018-2020, Zero Tang. All rights reserved.
pause

echo ============Start Compiling============
echo Compiling Windows Driver Framework...
%ddkpath%\amd64\cl.exe ..\src\booting\windrv\driver.c /I"%incpath%\crt" /I"%incpath%\api" /I"%incpath%\ddk" /Zi /nologo /W3 /WX /O2 /Oy- /D"_AMD64_" /D"_M_AMD64" /D"_WIN64" /D "_NDEBUG" /D"_UNICODE" /D "UNICODE" /Zc:wchar_t /FAcs /Fa"%objpath%\driver.cod" /Fo"%objpath%\driver.obj" /Fd"%objpath%\vc90.pdb" /GS- /Gy /Gr /TC /c /errorReport:queue

%ddkpath%\rc.exe /i"%incpath%\api" /i"%incpath%\ddk" /i"%incpath%\mfc42" /fo"%objpath%\version.res" /n ..\src\booting\windrv\version.rc

echo Compiling Core Engine of Intel VT-x...
for %%1 in (..\src\vt_core\*.c) do (%ddkpath%\amd64\cl.exe %%1 /I"..\src\include" /Zi /nologo /W3 /WX /Oi /O2 /favor:INTEL64 /D"_msvc" /D"_amd64" /D"_vt_core" /D"_%%~n1" /Zc:wchar_t /FAcs /Fa"%objpath%\%%~n1.cod" /Fo"%objpath%\%%~n1.obj" /Fd"%objpath%\vc90.pdb" /GS- /Gy /Gr /TC /c /errorReport:queue)

echo Compiling Core Engine of AMD-V...
for %%1 in (..\src\svm_core\*.c) do (%ddkpath%\amd64\cl.exe %%1 /I"..\src\include" /Zi /nologo /W3 /WX /Oi /O2 /favor:AMD64 /D"_msvc" /D"_amd64" /D"_svm_core" /D"_%%~n1" /Zc:wchar_t /FAcs /Fa"%objpath%\%%~n1.cod" /Fo"%objpath%\%%~n1.obj" /Fd"%objpath%\vc90.pdb" /GS- /Gy /Gr /TC /c /errorReport:queue)

echo Compiling Core Engine of MSHV...
for %%1 in (..\src\mshv_core\*.c) do (%ddkpath%\amd64\cl.exe %%1 /I"..\src\include" /Zi /nologo /W3 /WX /Oi /O2 /D"_msvc" /D"_amd64" /D"_mshv_core" /D"_%%~n1" /Zc:wchar_t /FAcs /Fa"%objpath%\%%~n1.cod" /Fo"%objpath%\%%~n1.obj" /Fd"%objpath%\vc90.pdb" /GS- /Gy /Gr /TC /c /errorReport:queue)

echo Compiling Core of Cross-Platform Framework (XPF)...
for %%1 in (..\src\xpf_core\windows\*.c) do (%ddkpath%\amd64\cl.exe %%1 /I"%incpath%\crt" /I"%incpath%\api" /I"%incpath%\ddk" /Zi /nologo /W3 /WX /O2 /D"_AMD64_" /D"_M_AMD64" /D"_WIN64" /D "_NDEBUG" /D"_UNICODE" /D "UNICODE" /Zc:wchar_t /FAcs /Fa"%objpath%\%%~n1.cod" /Fo"%objpath%\%%~n1.obj" /Fd"%objpath%\vc90.pdb" /GS- /Gy /Gr /TC /c /errorReport:queue)

%ddkpath%\amd64\cl.exe ..\src\xpf_core\noirhvm.c /I"..\src\include" /Zi /nologo /W3 /WX /Oi /O2 /D"_msvc" /D"_amd64" /D"_central_hvm" /Zc:wchar_t /FAcs /Fa"%objpath%\noirhvm.cod" /Fo"%objpath%\noirhvm.obj" /Fd"%objpath%\vc90.pdb" /GS- /Gy /Gr /TC /c /errorReport:queue

%ddkpath%\amd64\cl.exe ..\src\xpf_core\ci.c /I"..\src\include" /Zi /nologo /W3 /WX /Oi /O2 /D"_msvc" /D"_amd64" /D"_code_integrity" /Zc:wchar_t /FAcs /Fa"%objpath%\ci.cod" /Fo"%objpath%\ci.obj" /Fd"%objpath%\vc90.pdb" /GS- /Gy /Gr /TC /c /errorReport:queue

for %%1 in (..\src\xpf_core\windows\*.asm) do (%ddkpath%\amd64\ml64.exe /W3 /WX /D"_amd64" /Zf /Zd /Fo"%objpath%\%%~n1.obj" /c /nologo %%1)

echo ============Start Linking============
%ddkpath%\amd64\link.exe "%objpath%\*.obj" "%objpath%\version.res" /LIBPATH:"%libpath%\win7\amd64" /NODEFAULTLIB "ntoskrnl.lib" "..\src\disasm\LDE64.lib" /NOLOGO /OPT:REF /OPT:ICF /DEBUG /PDB:"%objpath%\NoirVisor.pdb" /OUT:"%binpath%\NoirVisor.sys" /SUBSYSTEM:NATIVE /Driver /ENTRY:"NoirDriverEntry" /Machine:X64 /ERRORREPORT:QUEUE
echo Completed!
echo.

echo This is Release/Free Build. Compiling Script will not perform signing!
echo You are supposed to sign this binary file with a formal signature!

pause