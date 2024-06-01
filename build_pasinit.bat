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

copya sys_sys.ins.pas (cog)lib/sys_sys.ins.pas

call src_getfrom util util.ins.pas
call src_getfrom string string.ins.pas
call src_getfrom string string_cmline_set.ins.pas
call src_getfrom string string2.ins.pas
call src_getfrom string string4.ins.pas
call src_getfrom string string16.ins.pas
call src_getfrom string string32.ins.pas
call src_getfrom string string80.ins.pas
call src_getfrom string string132.ins.pas
call src_getfrom string string256.ins.pas
call src_getfrom string string8192.ins.pas
call src_getfrom string string_leafname.ins.pas
call src_getfrom string string_treename.ins.pas
call src_getfrom file file.ins.pas

call src_builddate "%srcdir%"
