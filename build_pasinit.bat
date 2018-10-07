@echo off
rem
rem   Set up for building a Pascal (.pas suffix) module.
rem
set srcdir=sys
set buildname=

call src_get sys sys.ins.pas
call src_get sys sys_sys.ins.pas
call src_get sys sys2.ins.pas
call src_get sys sys_sys2.ins.pas
call src_get sys sys_mem.ins.pas
call src_get sys sys_subsys_resolve.ins.pas
call src_get sys base.ins.pas

call src_getfrom util util.ins.pas
call src_getfrom string string.ins.pas
call src_getfrom string string_cmline_set.ins.pas
call src_getfrom file file.ins.pas
call src_getfrom file file_map.ins.pas
call src_builddate "%srcdir%"
