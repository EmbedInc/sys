@echo off
rem
rem   BUILD [-dbg]
rem
rem   Build everything from the SYS source directory.
rem
setlocal
call godir (cog)source/sys
call build_lib
call build_progs
