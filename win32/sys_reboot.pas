{   Routines related to rebooting and shutting down the machine.
*
*   This version is for the WIN32 API.
}
module sys_reboot;
define sys_reboot;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
{
********************************************************************************
*
*   Local subroutine SETPRIV (NAME)
*
*   Activate the indicated system priveledge.
}
procedure setpriv (                    {set process priveledge}
  in      name: string;                {name of the priveledge to set}
  out     stat: sys_err_t);            {completion status}
  val_param; internal;

var
  ok: win_bool_t;                      {WIN_BOOL_FALSE_K on system call failure}
  token_h: win_handle_t;               {handle to access token}
  priv: token_privileges_t;            {info about privileges in an access token}
  rlen: win_dword_t;

begin
  sys_error_none (stat);               {init to no errors occurred}

  ok := OpenProcessToken (             {open handle to access token}
    GetCurrentProcess,                 {handle to thread getting token for}
    [win_tkacc_query_k, win_tkacc_adjust_priv_k],
    token_h);                          {returned handle to access token}
  if ok = win_bool_false_k then begin
    stat.sys := GetLastError;
    end;

  priv.n := 1;                         {number of privileges described}
  ok := LookupPrivilegeValueA (        {get LUID for privilege}
    ''(0),                             {no system name, use local}
    name,                              {name of privilege to get LUID for}
    priv.priv[1].luid);                {returned LUID for this privilege}
  if ok = win_bool_false_k then begin
    stat.sys := GetLastError;
    end;

  priv.priv[1].attr := priv_attr_enable_k; {enable this privilege}
  ok := AdjustTokenPrivileges (        {enable shutdown privilege in our access token}
    token_h,                           {handle to our access token}
    win_bool_false_k,                  {don't disable all privileges}
    priv,                              {descriptor for privilege modifications}
    sizeof(priv),                      {size of array to receive previous privs}
    nil,                               {no array supplied for previous privs}
    rlen);                             {previous privs required size, unused}
  discard( CloseHandle (token_h) );
  if ok = win_bool_false_k then begin
    stat.sys := GetLastError;
    end;
  end;
{
********************************************************************************
*
*   Subroutine SYS_REBOOT (STAT)
*
*   Reboot the machine.
}
procedure sys_reboot (                 {reboot the machine}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  ok: win_bool_t;                      {WIN_BOOL_FALSE_K on system call failure}

begin
  setpriv (privnam_shutdown_k, stat);  {set process priviledge to allow shutdown}
  sys_error_none (stat);               {ignore error trying to set priviledge}

  ok := ExitWindowsEx (                {try to shut down the system}
    [ shutdown_reboot_k,               {reboot after shutdown}
      shutdown_forcehung_k],           {force shutdown after timeout}
    [ shutreas_planned_k,              {indicate planned shutdown, not error}
      shutreas_app_k]);                {due to application}
  if ok = win_bool_false_k then begin  {error ?}
    stat.sys := GetLastError;
    end;
  end;
