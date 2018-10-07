@echo off
rem
rem   Build the executable programs from this source directory.
rem
setlocal
call build_pasinit

call src_prog %srcdir% test_date %1
call src_prog %srcdir% test_date_time1 %1
call src_prog %srcdir% test_env %1
call src_prog %srcdir% test_exit_error %1
call src_prog %srcdir% test_exit_ok %1
call src_prog %srcdir% test_fptrap %1
call src_prog %srcdir% test_gui %1
call src_prog %srcdir% test_order %1
call src_prog %srcdir% test_run %1
call src_prog %srcdir% test_shex %1
