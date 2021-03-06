@echo off
rem
rem   Set up for building a Pascal module.
rem
call build_vars

call src_get %srcdir% config.sst
copya config.sst /e/lib/config_sst

call src_get %srcdir% %srcdir%.ins.pas
call src_get %srcdir% %srcdir%_sys.ins.pas
call src_get %srcdir% %srcdir%2.ins.pas
call src_get %srcdir% %srcdir%_sys2.ins.pas
call src_get %srcdir% %srcdir%_mem.ins.pas
call src_get %srcdir% %srcdir%_subsys_resolve.ins.pas
call src_get %srcdir% base.ins.pas

call src_getfrom util util.ins.pas
call src_getfrom string string.ins.pas
call src_getfrom string string_cmline_set.ins.pas
call src_getfrom file file.ins.pas
call src_getfrom file file_map.ins.pas

call src_builddate "%srcdir%"
