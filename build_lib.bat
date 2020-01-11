@echo off
rem
rem   BUILD_LIB [-dbg]
rem
rem   Build the SYS library.
rem
setlocal
call build_pasinit

if exist sys.h del sys.h
call src_get sys sys.instop.pas
sst sys.instop.pas -show_unused 0 -local_ins -write_all -uname sys
rename sys.instop.c sys.h


call src_pas %srcdir% %libname%_beep %1
call src_pas %srcdir% %libname%_bomb %1
call src_pas %srcdir% %libname%_clock_sys %1
call src_pas %srcdir% %libname%_envvar %1
call src_pas %srcdir% %libname%_error %1
call src_pas %srcdir% %libname%_event %1
call src_pas %srcdir% %libname%_exec %1
call src_pas %srcdir% %libname%_exit %1
call src_pas %srcdir% %libname%_fp_ieee %1
call src_pas %srcdir% %libname%_fpmode %1
call src_pas %srcdir% %libname%_mem %1
call src_pas %srcdir% %libname%_node_id %1
call src_pas %srcdir% %libname%_node_name %1
call src_pas %srcdir% %libname%_process_sys %1
call src_pas %srcdir% %libname%_sys_message %1
call src_pas %srcdir% %libname%_thread %1
call src_pas %srcdir% %libname%_timer %1
call src_pas %srcdir% %libname%_timezone_here %1
call src_pas %srcdir% %libname%_wait %1
call src_pas %srcdir% %libname%_reboot %1
call src_pas %srcdir% %libname%_sys %1
call src_c   %srcdir% %libname%_c_sys %1
call src_pas %srcdir% %libname%_clock %1
call src_pas %srcdir% %libname%_clock_from_str %1
call src_pas %srcdir% %libname%_cognivis %1
call src_pas %srcdir% %libname%_date %1
call src_pas %srcdir% %libname%_date_string %1
call src_pas %srcdir% %libname%_dummy %1
call src_pas %srcdir% %libname%_env_path_get %1
call src_pas %srcdir% %libname%_error_abort %1
call src_pas %srcdir% %libname%_error_check %1
call src_pas %srcdir% %libname%_error_print %1
call src_pas %srcdir% %libname%_error_string %1
call src_pas %srcdir% %libname%_inetadr %1
call src_pas %srcdir% %libname%_init %1
call src_pas %srcdir% %libname%_langp_curr_get %1
call src_pas %srcdir% %libname%_langp_get %1
call src_pas %srcdir% %libname%_mem_error %1
call src_pas %srcdir% %libname%_sys_menu %1
call src_c   %srcdir% %libname%_sys_menu_c %1
call src_pas %srcdir% %libname%_message %1
call src_pas %srcdir% %libname%_message_bomb %1
call src_pas %srcdir% %libname%_message_parms %1
call src_pas %srcdir% %libname%_msg_parm_vstr %1
call src_pas %srcdir% %libname%_msg_parm_str %1
call src_pas %srcdir% %libname%_msg_parm_int %1
call src_pas %srcdir% %libname%_msg_parm_fp1 %1
call src_pas %srcdir% %libname%_msg_parm_fp2 %1
call src_pas %srcdir% %libname%_msg_parm_real %1
call src_pas %srcdir% %libname%_mxlookup %1
call src_pas %srcdir% %libname%_order_flip %1
call src_pas %srcdir% %libname%_process %1
call src_pas %srcdir% %libname%_read_env_global %1
call src_pas %srcdir% %libname%_read_env_lang %1
call src_pas %srcdir% %libname%_stat_match %1
call src_pas %srcdir% %libname%_stat_parm_vstr %1
call src_pas %srcdir% %libname%_stat_parm_str %1
call src_pas %srcdir% %libname%_stat_parm_int %1
call src_pas %srcdir% %libname%_stat_parm_real %1
call src_pas %srcdir% %libname%_stat_set %1
call src_pas %srcdir% %libname%_width_stdout %1
call src_pas %srcdir% %libname%_comblock %1

call src_lib %srcdir% %libname%
call src_msg %srcdir% %libname%

copya %libname%.h (cog)lib/%libname%.h
copya %libname%.ins.pas (cog)lib/%libname%.ins.pas
copya %libname%_sys.ins.pas (cog)lib/%libname%_sys.ins.pas
copya %libname%_sys2.ins.pas (cog)lib/%libname%_sys2.ins.pas
call src_get %srcdir% base_public.ins.pas
copya base_public.ins.pas (cog)lib/base.ins.pas
