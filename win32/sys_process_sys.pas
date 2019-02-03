{   System-dependent routines that deal with processes.
*   The system-independent routines are in module SYS_PROCESS.PAS.
*
*   This version is for the Microsoft Win32 API.
}
module sys_process_sys;
define sys_proc_release;
define sys_proc_status;
define sys_proc_stop;
define sys_run;
define sys_run_shell;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
%include 'string.ins.pas';

var
  envvar_prio: string_var32_t :=
    [str := 'COGNIVIS_PRIO_PROC', len := 18, max := size_char(envvar_prio.str)];
{
**********************************************************************
}
procedure sys_proc_release (           {let go of process, may deallocate resources}
  in      proc: sys_sys_proc_id_t;     {ID of process we launched}
  out     stat: sys_err_t);            {returned error status}
  val_param;

var
  ok: win_bool_t;

begin
  sys_error_none (stat);               {init to no error}

  ok := CloseHandle (proc);            {try to close the handle to the process}
  if ok = win_bool_false_k then begin  {error ?}
    stat.sys := GetLastError;          {get system error code}
    end;
  end;
{
**********************************************************************
}
procedure sys_proc_stop (              {stop a process on this system}
  in      proc: sys_sys_proc_id_t;     {ID of process to stop}
  out     stat: sys_err_t);            {returned error status}
  val_param;

var
  ok: win_bool_t;                      {not WIN_BOOL_FALSE_K on system call success}

begin
  sys_error_none (stat);               {init to no error occurred}

  ok := TerminateProcess (
    proc,                              {handle to process}
    sys_sys_exstat_wekill_k);          {exit status of process and all its threads}
  if ok = win_bool_false_k then begin  {error ?}
    stat.sys := GetLastError;
    end;
  end;
{
**********************************************************************
}
function sys_proc_status (             {get info about a process on this system}
  in      proc: sys_sys_proc_id_t;     {ID of process to get status of}
  in      wait: boolean;               {wait for process to terminate on TRUE}
  out     exstat: sys_sys_exstat_t;    {child process exit status}
  out     stat: sys_err_t)             {completion status code}
  :boolean;                            {TRUE if child process stopped}
  val_param;

var
  ok: win_bool_t;                      {not WIN_BOOL_FALSE_K on system call success}
  donewait: donewait_k_t;              {reason Wail... function returned}

label
  syerr;

begin
  sys_error_none (stat);               {init to no errors occurred}
  sys_proc_status := false;            {init to child process still running}

  if wait then begin                   {supposed to wait for process to terminate ?}
    donewait := WaitForSingleObject (  {wait for process to terminate}
      proc,                            {handle to process to wait for}
      timeout_infinite_k);             {wait as long as needed for process}
    case donewait of                   {why did wait routine return ?}
donewait_signaled_k: ;                 {process terminated}
donewait_failed_k: begin               {hard error encountered}
syerr:                                 {jump here on system error occurred}
        stat.sys := GetLastError;      {get system error code}
        return;                        {return with system error}
        end;
otherwise                              {should never get here}
      sys_stat_set (sys_subsys_k, sys_stat_failed_k, stat); {set stat to "failed"}
      return;                          {return with our "failed" status}
      end;                             {end of DONEWAIT cases}
    end;                               {done trying to stop process}

  ok := GetExitCodeProcess (           {try to get exit status code of process}
    proc,                              {system handle to process}
    exstat);                           {returned exit status code}
  if ok = win_bool_false_k then goto syerr; {system call failed ?}

  if exstat <> still_running_k then begin {process has stopped ?}
    sys_proc_status := true;           {indicate process stopped to caller}
    discard( CloseHandle(proc) );      {try to close handle to the process}
    end;
  end;
{
**********************************************************************
}
procedure sys_run (                    {run program in separate process}
  in      cmline: univ string_var_arg_t; {prog pathname and command line arguments}
  in      stdio_method: sys_procio_k_t; {how to set up standard I/O of new process}
  in out  stdin, stdout, stderr: sys_sys_iounit_t; {system STDIO handles}
  out     proc: sys_sys_proc_id_t;     {system ID of new process}
  out     stat: sys_err_t);            {completion status code}
  val_param;

const
  cline_max_k = 8192;                  {max characters we can pass on command line}
  max_msg_parms = 1;                   {max parameters we can pass to a message}
  max_close_k = 8;                     {max handles we can remember to close at end}

var
  pcreate: pcreate_t;                  {set of process creation option flags}
  procstart: procstart_t;              {startup info for new process}
  procinfo: procinfo_t;                {info about newly created process}
  proc_us_h: win_handle_t;             {pseudo-handle to our process}
  h: win_handle_t;                     {scratch system handle}
  inherit: win_bool_t;                 {process may inherit our handles on TRUE}
  ok: win_bool_t;                      {not WIN_BOOL_FALSE_K on system call success}
  priority: pcreate_k_t;               {PCREATE_PRIO_xxx_K, IDLE, NORM, HIGH, REAL}
  n_close: sys_int_machine_t;          {number of entries in CLOSE_LIST}
  close_list:                          {handles to close after process created}
    array[1..max_close_k] of win_handle_t;
  cline: array[1..cline_max_k] of char; {command line for new process}
  envval: string_var80_t;
  token: string_var16_t;
  pick: sys_int_machine_t;             {number of keyword picked from list}
  p: string_index_t;                   {parse index}
  msg_parm:                            {parameter references for messages}
    array[1..max_msg_parms] of sys_parm_msg_t;
  stat2: sys_err_t;

label
  no_prio, syerr, leave;
{
*************************
*
*   Local function HANDLE_INHERITABLE (H_OLD)
*
*   Create an inheritable copy of the system handle H_OLD.  The function return
*   value is the new handle.
}
function handle_inheritable (          {create duplicate handle that is inheritable}
  in      h_old: win_handle_t)         {handle to duplicate}
  :win_handle_t;                       {new inheritable handle}
  val_param;

var
  h_new: win_handle_t;                 {new handle}
  ok: win_bool_t;                      {not WIN_BOOL_FALSE_K on system call success}

begin
  ok := DuplicateHandle (              {make duplicate handle that is inheritable}
    proc_us_h,                         {process owning old handle}
    h_old,                             {handle to duplicate}
    proc_us_h,                         {process to own new handle}
    h_new,                             {returned new handle}
    0,                                 {access flags, ignored}
    win_bool_true_k,                   {explicitly allow new handle to be inherited}
    [dupflag_access_same_k]);          {use existing access, ignore access flags}
  if ok = win_bool_false_k then begin  {didn't create new handle ?}
    h_new := handle_none_k;            {flag handle as not existing}
    end;
  handle_inheritable := h_new;
  end;
{
*************************
*
*   Local subroutine REMEMBER_CLOSE (H)
*
*   Put the system handle H in a list so that it will be closed after the
*   new process is created.
}
procedure remember_close (
  in      h: win_handle_t);
  val_param;

begin
  if n_close >= max_close_k then return; {punt on no more room in close list}

  n_close := n_close + 1;              {update number of entries in list}
  close_list[n_close] := h;            {set this new list entry}
  end;
{
*************************
*
*   Start of main routine SYS_RUN.
}
begin
  token.max := size_char(token.str);   {init local var strings}
  envval.max := size_char(envval.str);
  sys_error_none (stat);               {init to no error occurred}

  n_close := 0;                        {init to no handles to close at end}
  string_t_c (cmline, cline, cline_max_k); {copy command line to system format}
  proc_us_h := GetCurrentProcess;      {get pseudo-handle to our process}
{
*   Init all the parameters with static or default values.
}
  priority := pcreate_prio_norm_k;     {set default priority of new process}

  sys_envvar_get (envvar_prio, envval, stat2); {try to read environment variable}
  if sys_error(stat2) then goto no_prio; {couln't read environment variable ?}
  p := 1;                              {init envval parse index}
  string_token (envval, p, token, stat2); {try to extract token from envvar value}
  if sys_error(stat2) then goto no_prio;
  string_upcase (token);
  string_tkpick80 (token, 'LOW NORMAL HIGH', pick);
  case pick of
1:  priority := pcreate_prio_idle_k;
2:  priority := pcreate_prio_norm_k;
3:  priority := pcreate_prio_high_k;
    end;
no_prio:                               {jump here on no priority info available}
  pcreate := [priority];               {set priority of new process}

  procstart.size := sizeof(procstart); {init process startup info data structure}
  procstart.reserved1_p := nil;
  procstart.desktop_p := nil;
  procstart.title_p := nil;
  procstart.x := 0;
  procstart.y := 0;
  procstart.dx := 0;
  procstart.dy := 0;
  procstart.xchars := 80;
  procstart.ychars := 20;
  procstart.fill_attr := 0;
  procstart.flags := [];
  procstart.winshow := ord(winshow_normal_k);
  procstart.reserved2 := 0;
  procstart.reserved3 := nil;
  procstart.stdin := handle_none_k;
  procstart.stdout := handle_none_k;
  procstart.stderr := handle_none_k;

  inherit := win_bool_false_k;         {init to process can't inherit our handles}

  case stdio_method of                 {how to set up process standard I/O streams ?}
{
*   Process gets no standard I/O connection to parent.
}
sys_procio_none_k: begin
  pcreate := pcreate +
    [pcreate_noconsole_k];             {don't use our console, don't make new}
  end;
{
*   Process will use the same standard I/O streams we do.  The new process'
*   standard I/O will look just like our standard I/O to the user.
}
sys_procio_same_k: begin
  procstart.stdin := handle_inheritable (
    GetStdHandle (stdstream_in_k));
  remember_close (procstart.stdin);

  procstart.stdout := handle_inheritable (
    GetStdHandle (stdstream_out_k));
  remember_close (procstart.stdout);

  procstart.stderr := handle_inheritable (
    GetStdHandle (stdstream_err_k));
  remember_close (procstart.stderr);

  procstart.flags := procstart.flags +
    [pstart_stdio_k];                  {standard I/O handles provided}
  inherit := win_bool_true_k;          {allow process to inherit our handles}
  end;
{
*   Process will "talk" to us with its standard I/O.  This means we create
*   a pipe for each standard I/O stream.  The process will get the handle
*   for one end, and we will pass back the handles to the other ends.
}
sys_procio_talk_k: begin
  ok := CreatePipe (                   {create a uni-directional pipe}
    h,                                 {handle for reading from pipe}
    win_handle_t(stdin),               {handle for writing to pipe}
    nil,                               {no security attributes specified}
    0);                                {use default buffer size}
  if ok = win_bool_false_k then begin
    goto syerr;
    end;
  procstart.stdin := handle_inheritable (h);
  if procstart.stdin = handle_none_k then begin
    goto syerr;
    end;
  remember_close (procstart.stdin);
  remember_close (h);

  ok := CreatePipe (                   {create a uni-directional pipe}
    win_handle_t(stdout),              {handle for reading from pipe}
    h,                                 {handle for writing to pipe}
    nil,                               {no security attributes specified}
    0);                                {use default buffer size}
  if ok = win_bool_false_k then begin
    goto syerr;
    end;
  procstart.stdout := handle_inheritable (h);
  if procstart.stdout = handle_none_k then begin
    goto syerr;
    end;
  remember_close (procstart.stdout);
  remember_close (h);

  ok := CreatePipe (                   {create a uni-directional pipe}
    win_handle_t(stderr),              {handle for reading from pipe}
    h,                                 {handle for writing to pipe}
    nil,                               {no security attributes specified}
    0);                                {use default buffer size}
  if ok = win_bool_false_k then begin
    goto syerr;
    end;
  procstart.stderr := handle_inheritable (h);
  if procstart.stderr = handle_none_k then begin
    goto syerr;
    end;
  remember_close (procstart.stderr);
  remember_close (h);

  procstart.flags := procstart.flags +
    [pstart_stdio_k];                  {standard I/O handles provided}
  pcreate := pcreate +
    [pcreate_noconsole_k];             {don't use our console, don't make new}
  inherit := win_bool_true_k;          {allow process to inherit our handles}
  end;
{
*   The standard I/O handles for the new process have been explicitly given
*   us by the caller.
}
sys_procio_explicit_k: begin
  procstart.stdin := handle_inheritable (stdin);
  procstart.stdout := handle_inheritable (stdout);
  procstart.stderr := handle_inheritable (stderr);
  procstart.flags := procstart.flags +
    [pstart_stdio_k];                  {standard I/O handles provided}
  pcreate := pcreate +
    [pcreate_noconsole_k];             {don't use our console, don't make new}
  inherit := win_bool_true_k;          {allow process to inherit our handles}
  end;

otherwise
    sys_msg_parm_int (msg_parm[1], ord(stdio_method));
    sys_message_bomb ('sys', 'proc_stdio_method_unknown', msg_parm[1], 1);
    end;                               {end of standard I/O handling method cases}
{
*   Create the process.
}
  ok := CreateProcessA (               {try to create the new process}
    nil,                               {no explicit module pathname supplied}
    cline,                             {command line}
    nil,                               {no process security attributes supplied}
    nil,                               {no thread security attributes supplied}
    inherit,                           {inherit our handles on TRUE}
    pcreate,                           {set of additional process creation flags}
    nil,                               {inherit our environment}
    nil,                               {inherit our working directory}
    procstart,                         {new process startup info}
    procinfo);                         {returned info about new process and thread}
  if ok = win_bool_false_k then begin  {didn't create new process ?}
syerr:                                 {jump here on system error encountered}
    stat.sys := GetLastError;          {save error code}
    goto leave;
    end;
  proc := procinfo.process_h;          {return handle to the new process}
  discard(                             {close our handle to process' main thread}
    CloseHandle(procinfo.thread_h)
    );

leave:                                 {common exit point}
  while n_close > 0 do begin           {once for each handle in CLOSE_LIST}
    discard( CloseHandle (close_list[n_close]) );
    n_close := n_close - 1;            {one less handle left to close}
    end;
  end;
{
**********************************************************************
}
procedure sys_run_shell (              {run command as if entered to shell}
  in      cmline: univ string_var_arg_t; {prog pathname and command line arguments}
  out     stat: sys_err_t);            {completion status code}
  val_param;

const
  exec_max_k = 1024;                   {max characters of executable object name}
  parms_max_k = 8192;                  {max characters of command line parameters}

var
  p: string_index_t;                   {CMLINE parse index}
  parm: string_treename_t;             {parameter parsed from CMLINE}
  parms: string_var8192_t;             {accumulated command line parameters}
  exec: array [1..exec_max_k] of char; {name of file to execute in Windows format}
  wparms: array [1..parms_max_k] of char; {execution parameters in Windwos format}
  err: win_uint_t;                     {error status from Windows routine}

begin
  parm.max := size_char(parm.str);     {init local var strings}
  parms.max := size_char(parms.str);

  p := 1;                              {init CMLINE parse index}
  string_token (cmline, p, parm, stat); {get executable name}
  if sys_error(stat) then return;
  string_treename (parm, parms);       {expand to full pathname}
  string_token_make (parms, parm);     {make single parsable token}
  string_t_c (parm, exec, exec_max_k); {convert it to Windows format}

  parms.len := 0;                      {init to no parameters}
  while true do begin                  {loop for each executable parameter}
    string_token (cmline, p, parm, stat); {extract this parameter}
    if string_eos(stat) then exit;     {hit end of parameters ?}
    if sys_error(stat) then return;
    string_append_token (parms, parm); {add this parameter to parameters list}
    end;                               {back to get next parameter}
  string_t_c (parms, wparms, parms_max_k); {convert parameters to Windows format}

  err := ShellExecuteA (               {run the shell command}
    0,                                 {no parent window}
    0,                                 {no specific operation, defaults to "open"}
    exec,                              {name of system object to "execute"}
    wparms,                            {parameters for the executable object}
    0,                                 {run in current directory}
    1);                                {show the result normally}
  if err > 32 then return;             {no error ?}
{
*   Return the error status indicated by ERR.  The error codes 100-132 in the
*   SYS subsystem are reserved for the ShellExecute return values 0-32.
}
  sys_stat_set (sys_subsys_k, err + 100, stat);
  end;
