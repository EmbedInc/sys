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

call src_pas %srcdir% %srcdir%_beep %1
call src_pas %srcdir% %srcdir%_bomb %1
call src_pas %srcdir% %srcdir%_clock_sys %1
call src_pas %srcdir% %srcdir%_envvar %1
call src_pas %srcdir% %srcdir%_error %1
call src_pas %srcdir% %srcdir%_event %1
call src_pas %srcdir% %srcdir%_exec %1
call src_pas %srcdir% %srcdir%_exit %1
call src_pas %srcdir% %srcdir%_fp_ieee %1
call src_pas %srcdir% %srcdir%_fpmode %1
call src_pas %srcdir% %srcdir%_mem %1
call src_pas %srcdir% %srcdir%_node_id %1
call src_pas %srcdir% %srcdir%_node_name %1
call src_pas %srcdir% %srcdir%_process_sys %1
call src_pas %srcdir% %srcdir%_sys_message %1
call src_pas %srcdir% %srcdir%_thread %1
call src_pas %srcdir% %srcdir%_timer %1
call src_pas %srcdir% %srcdir%_timezone_here %1
call src_pas %srcdir% %srcdir%_wait %1
call src_pas %srcdir% %srcdir%_reboot %1
call src_pas %srcdir% %srcdir%_sys %1
call src_c   %srcdir% %srcdir%_c_sys %1
call src_pas %srcdir% %srcdir%_clock %1
call src_pas %srcdir% %srcdir%_clock_from_str %1
call src_pas %srcdir% %srcdir%_cognivis %1
call src_pas %srcdir% %srcdir%_date %1
call src_pas %srcdir% %srcdir%_date_string %1
call src_pas %srcdir% %srcdir%_dummy %1
call src_pas %srcdir% %srcdir%_env_path_get %1
call src_pas %srcdir% %srcdir%_error_abort %1
call src_pas %srcdir% %srcdir%_error_check %1
call src_pas %srcdir% %srcdir%_error_print %1
call src_pas %srcdir% %srcdir%_error_string %1
call src_pas %srcdir% %srcdir%_inetadr %1
call src_pas %srcdir% %srcdir%_init %1
call src_pas %srcdir% %srcdir%_langp_curr_get %1
call src_pas %srcdir% %srcdir%_langp_get %1
call src_pas %srcdir% %srcdir%_mem_error %1
call src_pas %srcdir% %srcdir%_sys_menu %1
call src_c   %srcdir% %srcdir%_sys_menu_c %1
call src_pas %srcdir% %srcdir%_message %1
call src_pas %srcdir% %srcdir%_message_bomb %1
call src_pas %srcdir% %srcdir%_message_parms %1
call src_pas %srcdir% %srcdir%_msg_parm_vstr %1
call src_pas %srcdir% %srcdir%_msg_parm_str %1
call src_pas %srcdir% %srcdir%_msg_parm_int %1
call src_pas %srcdir% %srcdir%_msg_parm_fp1 %1
call src_pas %srcdir% %srcdir%_msg_parm_fp2 %1
call src_pas %srcdir% %srcdir%_msg_parm_real %1
call src_pas %srcdir% %srcdir%_mxlookup %1
call src_pas %srcdir% %srcdir%_order_flip %1
call src_pas %srcdir% %srcdir%_process %1
call src_pas %srcdir% %srcdir%_read_env_global %1
call src_pas %srcdir% %srcdir%_read_env_lang %1
call src_pas %srcdir% %srcdir%_stat_match %1
call src_pas %srcdir% %srcdir%_stat_parm_vstr %1
call src_pas %srcdir% %srcdir%_stat_parm_str %1
call src_pas %srcdir% %srcdir%_stat_parm_int %1
call src_pas %srcdir% %srcdir%_stat_parm_real %1
call src_pas %srcdir% %srcdir%_stat_set %1
call src_pas %srcdir% %srcdir%_width_stdout %1
call src_pas %srcdir% %srcdir%_comblock %1

call src_lib %srcdir% %srcdir%
call src_msg %srcdir% %srcdir%

copya %srcdir%.h (cog)lib/%srcdir%.h
copya %srcdir%.ins.pas (cog)lib/%srcdir%.ins.pas
copya %srcdir%_sys.ins.pas (cog)lib/%srcdir%_sys.ins.pas
copya %srcdir%_sys2.ins.pas (cog)lib/%srcdir%_sys2.ins.pas
copya base.ins.pas (cog)lib/base.ins.pas
