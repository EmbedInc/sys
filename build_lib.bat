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

call src_pas sys sys_beep %1
call src_pas sys sys_bomb %1
call src_pas sys sys_clock_sys %1
call src_pas sys sys_envvar %1
call src_pas sys sys_error %1
call src_pas sys sys_event %1
call src_pas sys sys_exec %1
call src_pas sys sys_exit %1
call src_pas sys sys_fp_ieee %1
call src_pas sys sys_fpmode %1
call src_pas sys sys_mem %1
call src_pas sys sys_node_id %1
call src_pas sys sys_node_name %1
call src_pas sys sys_process_sys %1
call src_pas sys sys_sys_message %1
call src_pas sys sys_thread %1
call src_pas sys sys_timer %1
call src_pas sys sys_timezone_here %1
call src_pas sys sys_wait %1
call src_pas sys sys_reboot %1
call src_pas sys sys_sys %1
call src_c   sys sys_c_sys %1
call src_pas sys sys_clock %1
call src_pas sys sys_clock_from_str %1
call src_pas sys sys_cognivis %1
call src_pas sys sys_date %1
call src_pas sys sys_date_string %1
call src_pas sys sys_dummy %1
call src_pas sys sys_env_path_get %1
call src_pas sys sys_error_abort %1
call src_pas sys sys_error_check %1
call src_pas sys sys_error_print %1
call src_pas sys sys_error_string %1
call src_pas sys sys_inetadr %1
call src_pas sys sys_init %1
call src_pas sys sys_langp_curr_get %1
call src_pas sys sys_langp_get %1
call src_pas sys sys_mem_error %1
call src_pas sys sys_sys_menu %1
call src_c   sys sys_sys_menu_c %1
call src_pas sys sys_message %1
call src_pas sys sys_message_bomb %1
call src_pas sys sys_message_parms %1
call src_pas sys sys_msg_parm_vstr %1
call src_pas sys sys_msg_parm_str %1
call src_pas sys sys_msg_parm_int %1
call src_pas sys sys_msg_parm_fp1 %1
call src_pas sys sys_msg_parm_fp2 %1
call src_pas sys sys_msg_parm_real %1
call src_pas sys sys_order_flip %1
call src_pas sys sys_process %1
call src_pas sys sys_read_env_global %1
call src_pas sys sys_read_env_lang %1
call src_pas sys sys_stat_match %1
call src_pas sys sys_stat_parm_vstr %1
call src_pas sys sys_stat_parm_str %1
call src_pas sys sys_stat_parm_int %1
call src_pas sys sys_stat_parm_real %1
call src_pas sys sys_stat_set %1
call src_pas sys sys_width_stdout %1
call src_pas sys sys_comblock %1

call src_lib sys sys
call src_msg sys sys

copya sys.h (cog)lib/sys.h
copya sys.ins.pas (cog)lib/sys.ins.pas
copya sys_sys.ins.pas (cog)lib/sys_sys.ins.pas
copya sys_sys2.ins.pas (cog)lib/sys_sys2.ins.pas
copya base.ins.pas (cog)lib/base.ins.pas
