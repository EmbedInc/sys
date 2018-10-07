{   System dependent routines for handling system menus.
*
*   This is the default generic version.  Since these routines are system
*   dependent, the routines here just return unimplemented status.
}
module sys_sys_menu;
define sys_menu_entry_set;
define sys_menu_entry_del;

%include 'sys2.ins.pas';
{
********************************************************************************
*
*   Subroutine SYS_MENU_ENTRY_SET (
*     MENUID, ENTPATH, NAME, PROG, DESC, ICON, STAT)
}
procedure sys_menu_entry_set (         {add entry to system menu, system dependent}
  in      menuid: sys_menu_k_t;        {ID of the menu to add entry to}
  in      entpath: univ string_var_arg_t; {menu entry path relative to MENUID location}
  in      name: univ string_var_arg_t; {menu entry name}
  in      prog: univ string_var_arg_t; {program to run when menu entry chosen}
  in      wdir: univ string_var_arg_t; {working directory to run program in}
  in      desc: univ string_var_arg_t; {optional description string}
  in      icon: univ string_var_arg_t; {optional pathname of menu entry icon}
  out     stat: sys_err_t);            {completion status}
  val_param;

begin
  sys_stat_set (sys_subsys_k, sys_stat_not_impl_subr_k, stat);
  sys_stat_parm_str ('SYS_MENU_ENTRY_SET', stat);
  end;
{
********************************************************************************
*
*   Subroutine SYS_MENU_ENTRY_DEL (MENUID, ENTPATH, STAT)
}
procedure sys_menu_entry_del (         {delete system menu entry}
  in      menuid: sys_menu_k_t;        {ID of the menu to delete entry from}
  in      entpath: univ string_var_arg_t; {menu entry path relative to MENUID location}
  in      name: univ string_var_arg_t; {menu entry name}
  out     stat: sys_err_t);            {completion status}
  val_param;

begin
  sys_stat_set (sys_subsys_k, sys_stat_not_impl_subr_k, stat);
  sys_stat_parm_str ('SYS_MENU_ENTRY_DEL', stat);
  end;
