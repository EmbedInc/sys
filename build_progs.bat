@echo off
rem
rem   BUILD_PROGS [-dbg]
rem
rem   Build the executable programs from this source directory.
rem
setlocal
call build_pasinit

call src_progl test_date -nolib
call src_progl test_date_time1 -nolib
call src_progl test_env
call src_progl test_exit_error
call src_progl test_exit_ok
call src_progl test_fptrap
call src_progl test_gui
call src_progl test_order
call src_progl test_run
call src_progl test_shex
