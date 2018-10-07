{   System dependent routines for handling system menus.
*
*   This version is for the Microsoft Windows Win32 API.
}
module sys_sys_menu;
define sys_menu_entry_set;
define sys_menu_entry_del;

%include 'sys2.ins.pas';
%include 'string.ins.pas';
%include 'file.ins.pas';
%include 'sys_sys2.ins.pas';
{
********************************************************************************
*
*   Local subroutine MAKE_PATH (MENUID, RELPATH, TNAM, CREATE, STAT)
*
*   Find the complete file system path of a menu directory and ensure that it
*   exists.  MENUID is the ID of the particular menu, and RELPATH is the
*   relative path starting from this root menu.  TNAM is returned the full
*   file system path.
}
procedure make_path (                  {find menu path in file system, ensure exists}
  in      menuid: sys_menu_k_t;        {ID of the root system menu to use}
  in      relpath: univ string_var_arg_t; {menu directory path within indicated root}
  in out  tnam: univ string_var_arg_t; {returned full pathname to menu directory}
  in      create: boolean;             {create intermediate directories as needed}
  out     stat: sys_err_t);            {completion status}
  val_param; internal;

var
  pathid: csidl_k_t;                   {ID for special system directory menu is in}
  dir: string_leafname_t;              {name of one directory from RELPATH}
  delim: sys_int_machine_t;            {index of delimiter used}
  p: string_index_t;                   {RELPATH parse index}

begin
  dir.max := size_char(dir.str);       {init local var string}

  case menuid of                       {which menu to add entry to ?}
sys_menu_desk_all_k: pathid := csidl_common_desktopdirectory_k;
sys_menu_desk_user_k: pathid := csidl_desktopdirectory_k;
sys_menu_progs_all_k: pathid := csidl_common_programs_k;
sys_menu_progs_user_k: pathid := csidl_programs_k;
otherwise
    sys_stat_set (sys_subsys_k, sys_stat_menuid_bad_k, stat);
    sys_stat_parm_int (ord(menuid), stat);
    return;
    end;
  sys_sys_get_stdpath (pathid, tnam, stat); {get file pathname to selected root menu}
  if sys_error(stat) then return;
{
*   The treename to the root directory identified by MENUID as mapped into the
*   file system is in TNAM, and is guaranteed to exist.
*
*   Now make sure all the additional subdirectories indicated by RELPATH exist
*   and add them to TNAM to make the final returned treename.
}
  p := 1;                              {init RELPATH parse index}
  while p <= relpath.len do begin      {keep looping until all of RELPATH used}
    string_token_anyd (                {get next directory name from RELPATH}
      relpath, p,                      {input string and parse index}
      '/\', 2,                         {list of token delimiter characters}
      0,                               {no delimiters may be repeated}
      [string_tkopt_padsp_k],          {strip leading/trailing blanks from tokens}
      dir,                             {this directory name parsed from RELPATH}
      delim,                           {index of the delimiter (not used)}
      stat);
    if string_eos(stat) then exit;     {hit end of relative path ?}
    if dir.len <= 0 then next;         {empty directory name, ignore ?}
{
*   The next subdirectory name is in DIR.
}
    string_append1 (tnam, '\');        {add new directory to end of absolute path}
    string_append (tnam, dir);
    if create then begin
      file_create_dir (tnam, [file_crea_keep_k], stat); {create if not already exists}
      if sys_error(stat) then return;
      end;
    end;                               {back for next directory in RELPATH}
  end;
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
  in      parms: univ string_var_arg_t; {target program command line parameters}
  in      wdir: univ string_var_arg_t; {working directory to run program in}
  in      desc: univ string_var_arg_t; {optional description string}
  in      icon: univ string_var_arg_t; {optional pathname of menu entry icon}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  tnam: string_treename_t;             {scratch treename}
  utnam: array [1 .. win_max_path_k+1] of win_wchar_t; {unicode menu entry treename}
  progt: string_treename_t;            {full treename of program to run from menu entry}
  wdirt: string_treename_t;            {full treename of working dir to run program in}
  icont: string_treename_t;            {full treename of menu entry icon BMP file}
  cargs: string_var8192_t;             {local copy of command line parameters}
  cdesc: string_var8192_t;             {local copy of description string for NULL term}

begin
  tnam.max := size_char(tnam.str);     {init local var strings}
  progt.max := size_char(progt.str);
  wdirt.max := size_char(wdirt.str);
  icont.max := size_char(icont.str);
  cargs.max := size_char(cargs.str);
  cdesc.max := size_char(cdesc.str);

  make_path (menuid, entpath, tnam, true, stat); {make absolute menu directory treename}
  if sys_error(stat) then return;
  string_append1 (tnam, '\');
  string_append (tnam, name);          {add menu entry .LNK file name}
  string_appends (tnam, '.lnk'(0));
  ascii_unicode (tnam, utnam, win_max_path_k+1); {make unicode menu entry treename}

  string_treename (prog, progt);       {make program full treename}
  string_terminate_null (progt);       {make C string of STR field}

  string_copy (parms, cargs);          {make command line parameters}
  string_terminate_null (cargs);

  string_treename (wdir, wdirt);       {make full working directory treename}
  string_terminate_null (wdirt);

  string_copy (desc, cdesc);           {make local copy of description string}
  string_terminate_null (cdesc);       {make C string of STR field}

  icont.len := 0;
  if icon.len > 0 then begin           {icon pathname was supplied ?}
    string_treename (icon, icont);     {make icon file full treename}
    end;
  string_terminate_null (icont);       {make C string of STR field}

  sys_sys_menu_entry_set (             {create the menu entry}
    utnam,                             {unicode treename of menu entry in file system}
    progt.str,                         {target command this menu entry executes}
    cargs.str,                         {command line parameters}
    wdirt.str,                         {working directory to run program in}
    cdesc.str,                         {menu entry description string}
    icont.str,                         {treename of icon to associate with menu entry}
    stat);
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

var
  rootlen: sys_int_machine_t;          {pathname length of menu root directory}
  tnam: string_treename_t;             {treename of menu entry file}
  dir: string_treename_t;
  fnam: string_leafname_t;
  finfo: file_info_t;                  {info about directory entry, not used}
  conn: file_conn_t;                   {connection to directory}

begin
  tnam.max := size_char(tnam.str);     {init local var strings}
  dir.max := size_char(dir.str);
  fnam.max := size_char(fnam.str);

  fnam.len := 0;
  make_path (menuid, fnam, tnam, false, stat); {get treename of menu root directory}
  if sys_error(stat) then return;
  rootlen := tnam.len;                 {save length of root pathname}
{
*   Delete the menu entry.
}
  make_path (menuid, entpath, tnam, false, stat); {make treename of directory with menu entry}
  if sys_error(stat) then return;

  string_append1 (tnam, '\');
  string_append (tnam, name);          {add menu entry .LNK file name}
  string_appends (tnam, '.lnk'(0));
  file_delete_name (tnam, stat);       {try to delete the menu entry}
  discard( file_not_found(stat) );     {OK if didn't previously exist}
{
*   Delete all the directories that contained the directory entry that are empty
*   up to but not including the menu root directory.
}
  while true do begin                  {loop until hit menu root directory}
    string_pathname_split (tnam, dir, fnam); {get the containing directory name in DIR}
    if dir.len <= rootlen then exit;   {at menu root ?}
    string_copy (dir, tnam);           {update starting directory for next time}

    file_open_read_dir (dir, conn, stat); {try to open this directory to read it}
    if file_not_found(stat) then next; {this directory doesn't exist ?}
    if sys_error(stat) then return;    {hard error opening directory ?}
    file_read_dir (conn, [], fnam, finfo, stat); {try to get first directory entry}
    file_close (conn);                 {don't need to read directory anymore}
    if not sys_error(stat) then exit;  {directory is not empty}
    if not file_eof(stat) then return; {hard error reading directory ?}

    file_delete_tree (dir, [file_del_errgo_k], stat); {delete this directory, which is empty}
    if sys_error(stat) then return;
    end;                               {back to do next level up directory}
  end;
