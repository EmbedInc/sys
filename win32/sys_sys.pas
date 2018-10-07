{   Module of routines that are specific to this implementation.  These routines
*   are only called from other implementation-specific routines, and may not
*   exist on other implementations.
*
*   This version is for the Microsoft Win32 API.
}
module sys_sys;
define sys_sys_rootdir;
define sys_sys_error_bomb;
define sys_sys_netstart;
define ascii_unicode;
define unicode_ascii;
define sys_sys_run_gui;
define sys_sys_stdio_gui;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
%include 'string_cmline_set.ins.pas';
%include 'string.ins.pas';

define sys2;                           {declare our private common block}
{
********************************************************************************
*
*   SYS_SYS_ROOTDIR (NAME)
*
*   Return the root directory for this machine.  This is the same as treename
*   of "/".  Unfortunately, Windows doesn't have the notion of a machine root
*   directory, since there is really nothing above all the drive names.  Just
*   "\" refers to the current directory on the current drive, a concept we don't
*   support since we maintain only one current directory per machine.
*
*   The machine root directory will be the root directory of the first local
*   fixed drive, usually "C:\".  If that fails, we'll take the first local
*   removeable drive, then the first network drive.
}
var                                    {local static storage}
  found: boolean := false;             {TRUE if previously found root directory}
  rootdir: string_var4_t;              {root directory name when FOUND is TRUE}

procedure sys_sys_rootdir (            {get system name for machine root directory}
  in out  name: univ string_var_arg_t); {root directory (treename of /), like "C:\"}

var
  first_remove: char;                  {drive letter of first local removable drive}
  first_remote: char;                  {drive letter of first remote drive, if any}
  drtype: drivetype_k_t;               {system drive type ID}

label
  leave;

begin
  if found then goto leave;            {already know root directory name ?}

  rootdir.max := size_char(rootdir.str); {init var string in static storage}
  rootdir.str[2] := ':';               {set static part of drive name}
  rootdir.str[3] := '\';
  rootdir.len := 3;
  rootdir.str[4] := chr(0);            {add null terminator for system call}
  found := true;                       {ROOTDIR will be set from now on}

  first_remove := ' ';                 {init to no local removable drive found}
  first_remote := ' ';                 {init to no remote drive found}
  for rootdir.str[1] := 'A' to 'Z' do begin {scan forwards thru all the drive names}
    drtype := GetDriveTypeA (rootdir.str); {get type of this system drive}
    case drtype of                     {what kind of drive is this ?}
drivetype_remove_k,
drivetype_cdrom_k: begin               {local removeable drive}
        if first_remove = ' '          {save, but keep on looking}
          then first_remove := rootdir.str[1];
        end;
drivetype_fixed_k: begin               {local fixed drive}
        goto leave;                    {we found what we were looking for}
        end;
drivetype_remote_k: begin              {remote drive}
        if first_remote = ' '          {save, but keep on looking}
          then first_remote := rootdir.str[1];
        end;
      end;                             {end of drive type cases}
    end;                               {back to check next drive name}
{
*   No local fixed drive was found.
}
  if first_remove <> ' ' then begin    {there is a local removeable drive ?}
    rootdir.str[1] := first_remove;
    goto leave;
    end;

  if first_remote <> ' ' then begin    {there is a remote drive ?}
    rootdir.str[1] := first_remote;
    goto leave;
    end;

  rootdir.str[1] := 'C';               {default if all else fails}

leave:                                 {common exit point}
  string_copy (rootdir, name);         {return root directory name}
  end;
{
********************************************************************************
*
*   Subroutine SYS_SYS_NETSTART
*
*   Startup the network software DLL, if it hasn't already been started.  All
*   but the first call does nothing.
}
procedure sys_sys_netstart;            {init network SW, if not already done so}

var
  max_version: wsa_version_t;          {max network software version we can drive}
  fail: sys_int_machine_t;             {0 on success}
  stat: sys_err_t;

label
  started;

begin
  if wsa_started then return;          {network software already started ?}
{
*   First try to request a very large version number.  This should, in theory,
*   match whatever the library can offer.
}
  sys_error_none(stat);
  max_version.major := 127;            {allow hookup to anything}
  max_version.minor := 127;
  wsa_info.version_max.major := 0;     {clear fields returned by WSAStartup}
  wsa_info.version_max.minor := 0;
  stat.sys := WSAStartup (max_version, wsa_info); {startup network DLL}
  if not sys_error(stat) then goto started;
{
*   WSAStartup failed when we requested a large version number.  This shouldn't
*   happen, but there are various bugs in different versions of WSAStartup.
*
*   Now loop thru all the valid major version numbers.  If WSAStartup ever
*   fills in its max supported version, we will call it with that.  We give
*   up if it never does.
}
  max_version.minor := 0;
  for max_version.major := 1 to 127 do begin {once for each possible major version}
    stat.sys := WSAStartup (max_version, wsa_info); {try again with this new maj ver}
    if not sys_error(stat) then begin  {WSAStartup succeeded ?}
      fail := WSACleanup;              {undo what the startup call did}
      if fail <> 0 then begin          {cleanup returned system error ?}
        stat.sys := WSAGetLastError;   {get the error code}
        sys_error_abort (stat, 'sys', 'err_netclose', nil, 0);
        end;
      end;                             {done undoing the startup call}

    if wsa_info.version_max.major <> 0 then begin {we got its max version number ?}
      max_version.major := wsa_info.version_max.major; {request max available ver}
      max_version.minor := wsa_info.version_max.minor;
      stat.sys := WSAStartup (max_version, wsa_info); {startup network DLL}
      sys_error_abort (stat, 'sys', 'err_netstart', nil, 0);
      goto started;                    {network library successfully started}
      end;
    end;                               {back and try next major version number}

  sys_message_bomb ('sys', 'err_netversion', nil, 0); {couldn't find valid version}

started:                               {jump here if network lib was started}
  wsa_started := true;                 {indicate network DLL already initialized}
  end;
{
********************************************************************************
*
*   Subroutine SYS_SYS_ERROR_BOMB (SUBSYS, MSG, PARMS, N_PARMS)
*
*   A system error has occurred.  Get the last error code, print the appropriate
*   messages, and bomb.
}
procedure sys_sys_error_bomb (         {system error occurred, bomb with explanation}
  in      subsys: string;              {name of subsystem containing error message}
  in      msg: string;                 {error message name within subsystem}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  val_param;

var
  stat: sys_err_t;                     {error status code}
  err_sys: sys_sys_err_t;              {system error code}

begin
  err_sys := GetLastError;             {get system error code before we corrupt it}
  sys_error_none (stat);               {init error status descriptor}
  stat.sys := err_sys;                 {set error descriptor to indicate system err}

  sys_error_print (stat, '', '', nil, 0); {print message for system error}
  sys_message_bomb (subsys, msg, parms, n_parms); {print caller's message and bomb}
  end;
{
********************************************************************************
*
*   Subroutine ASCII_UNICODE (VSTR, USTR, LEN)
*
*   Convert the Cognivision var string VSTR to the unicode string USTR.  USTR
*   will be null-terminated.  LEN is the maximum number of characters (including
*   the NULL terminator) we are allowed to write to USTR.  If the input string
*   contains more than LEN-1 characters, only the first LEN-1 characters are
*   copied and the NULL terminator is written to the last character position.
}
procedure ascii_unicode (              {convert var string to system UNICODE}
  in      vstr: univ string_var_arg_t; {input Cognivision var string}
  out     ustr: univ unicode_str_t;    {output unicode string}
  in      len: string_index_t);        {max characters to write into USTR}
  val_param;

var
  n: sys_int_machine_t;                {number of characters to really copy}
  i: sys_int_machine_t;

begin
  if len <= 0 then return;             {nothing to do}
  n := max(0, min(vstr.len, len - 1)); {make number of characters to actually copy}

  for i := 1 to n do begin             {copy the text characters}
    ustr[i] := ord(vstr.str[i]);
    end;

  ustr[n + 1] := 0;                    {add NULL terminator to end of string}
  end;
{
********************************************************************************
*
*   Subroutine UNICODE_ASCII (VSTR, USTR, LEN)
*
*   Convert the system unicode character string USTR to the Cognivision var
*   string VSTR.  The string in USTR is assumed to end before the first NULL
*   character, or after LEN characters, whichever occurrs first.
}
procedure unicode_ascii (              {convert system UNICODE string to var string}
  in out  vstr: univ string_var_arg_t; {returned Cognivision var string}
  in      ustr: univ unicode_str_t;    {input unicode string, may have NULL term}
  in      len: string_index_t);        {max characters in USTR}
  val_param;

var
  i: sys_int_machine_t;                {loop counter}
  n: sys_int_machine_t;                {max possible characters to copy}

begin
  n := min(vstr.max, len);             {max possible characters we can copy}

  for i := 1 to n do begin             {once for each character}
    if ustr[i] = 0 then begin          {hit NULL terminiator in input string ?}
      vstr.len := i - 1;
      return;
      end;
    vstr.str[i] := chr(ustr[i]);       {copy this character, may loose info here}
    end;

  vstr.len := n;                       {we copied all N chars if we get here}
  end;
{
********************************************************************************
*
*   Subroutine SYS_SYS_STDIO_GUI
*
*   Do whatever it takes to make sure we have standard I/O connections, and that
*   standard output is useable thru the C runtime stream calls, such as PRINTF.
}
procedure sys_sys_stdio_gui;

begin
  sys_sys_stdout_fix;                  {make sure C lib knows about our std streams}
  sys_sys_stdout_nobuf;                {disable buffering of output standard streams}
  end;
{
********************************************************************************
*
*   Function SYS_SYS_RUN_GUI (NAME, NAMELEN)
*
*   Run a Windows GUI app in such a way that it appears to use our standard I/O
*   connections.  NAME is a regular string containing the name of the command to
*   execute.  NAMELEN is the number of characters in NAME.  The command line
*   arguments, if any, are taken from the command line.  When NAMELEN is zero,
*   NAME is taken from the first command line argument.
*
*   The function return value is the exit status code of the GUI process.
}
function sys_sys_run_gui (             {run GUI app with our standard I/O}
  in      name: string;                {name of program to run}
  in      namelen: sys_int_machine_t)  {number of characters in NAME}
  :win_uint_t;                         {exit status code of subordinate process}
  val_param;

const
  max_msg_parms = 1;                   {max parameters we can pass to a message}

type
  copy_t = record                      {indicates how thread routines should do copy}
    from_h: sys_sys_iounit_t;          {handle to copy from}
    to_h: sys_sys_iounit_t;            {handle to copy to}
    thread_h: win_handle_t;            {handle to thread doing the copying}
    end;

var
  cmline: string_var8192_t;            {complete command line to execute}
  tk: string_var8192_t;                {scratch token}
  proc_h: sys_sys_proc_id_t;           {handle to subordinate process}
  stdin, stdout, stderr: copy_t;       {state blocks for each standard stream}
  thread_id: win_dword_t;              {scratch thread ID}
  exstat: sys_sys_exstat_t;            {child process exit status code}
  i: sys_int_machine_t;                {scratch integer}
  waitfor: array[1..2] of win_handle_t; {list of handles to wait on}
  msg_parm:                            {parameter references for messages}
    array[1..max_msg_parms] of sys_parm_msg_t;
  stat: sys_err_t;

label
  loop_cmline, done_cmline;
{
**********************
*
*   Local subroutine CMLINE_TOKEN_ADD (CMLINE, TKNEW)
*   This routine is local to SYS_SYS_RUN_GUI.
*
*   Add the token TKNEW to the end of the command line CMLINE.  This routine
*   handles imbedded spaces by enclosing the token in quotes, if needed.
}
procedure cmline_token_add (           {add token to exiting command line}
  in out  cmline: univ string_var_arg_t; {command line to add token to}
  in      tknew: univ string_var_arg_t); {token to add to end of command line}
  val_param;

var
  i: sys_int_machine_t;                {scratch integer and loop counter}

label
  copy, quote;

begin
  string_append1 (cmline, ' ');        {add separator before the new token}

  if tknew.len <= 0 then begin         {empty token ?}
    string_appendn (cmline, '""', 2);
    return;
    end;

  if                                   {check for token already is quoted}
      (tknew.len >= 2) and             {long enough to contain two quotes ?}
      (tknew.str[1] = '"') and         {first character is a quote ?}
      (tknew.str[tknew.len] = '"')     {last character is a quote ?}
    then goto copy;                    {already quoted, copy directly}

  for i := 1 to tknew.len do begin     {loop thru the characters in the raw token}
    if tknew.str[i] = ' ' then goto quote; {raw token contains an imbedded blank ?}
    end;
{
*   The token contains no imbedded blanks.
}
copy:
  string_append (cmline, tknew);       {copy the token directly}
  return;
{
*   The token contains imbedded blanks.  It must therefore be enclosed in a
*   pair of quotes.  We also therefore must handle imbedded quote characters.
}
quote:
  string_append1 (cmline, '"');        {write starting quote}
  for i := 1 to tknew.len do begin     {once for each character in the raw token}
    if tknew.str[i] = '"'
      then begin                       {encountered quote character}
        string_appendn (cmline, '""', 2); {write as double quote character}
        end
      else begin                       {not a special character}
        string_append1 (cmline, tknew.str[i]); {copy character directly}
        end
      ;
    end;                               {back to process next raw token character}
  string_append1 (cmline, '"');        {write ending quote}
  end;
{
**********************
*
*   Local function IO_COPY (IODAT)
*
*   Copy the data to/from the I/O connections indicated by IODAT.  This routine
*   is run in a separate thread.  The function return code will become the
*   thread exit status code.
}
function io_copy (                     {perform one I/O connection copy}
  in      iodat: copy_t)               {data structure describing I/O connection}
  :sys_int_adr_t;                      {will become thread exit status}

var
  buf: array[1..1024] of char;         {I/O buffer}
  st: sys_int_machine_t;               {index of next BUF char to write}
  nread: win_dword_t;                  {number of characters actually read}
  nwrite: win_dword_t;                 {number of characters actually written}
  ok: win_bool_t;                      {WIN_BOOL_FALSE_K with GetLastError on error}

label
  loop, rewrite, leave;

begin
loop:                                  {back here to copy each new chunk}
  ok := ReadFile (                     {read block from input stream}
    iodat.from_h,                      {handle to I/O connection to read from}
    buf,                               {data buffer}
    size_min(buf),                     {max amount allowed to read}
    nread,                             {number of bytes actually read}
    nil);                              {no overlap info supplied}
  if ok = win_bool_false_k then goto leave; {error ?}
  if nread = 0 then goto leave;        {hit an end of file ?}

  st := 1;                             {init next BUF entry to write}
rewrite:                               {back here to write each new chunk}
  ok := WriteFile (                    {try to write all remaining data to output}
    iodat.to_h,                        {handle to I/O connection to write to}
    buf[st],                           {data buffer start}
    nread,                             {number of bytes to write}
    nwrite,                            {number of bytes actually written}
    nil);                              {no overlap info supplied}
  if ok = win_bool_false_k then goto leave; {error ?}
  if nwrite = 0 then goto leave;       {didn't write anything ?}
  nread := nread - nwrite;             {make number of bytes left to write}
  if nread <= 0 then goto loop;        {wrote everything we had ?}
  st := st + nwrite;                   {update index to next byte to write}
  goto rewrite;                        {back to write next chunk}

leave:                                 {common exit point}
  io_copy := 0;
  end;
{
**********************
*
*   Start of routine SYS_SYS_RUN_GUI
}
begin
  cmline.max := size_char(cmline.str); {init local var strings}
  tk.max := size_char(tk.str);
  string_cmline_init;                  {init for reading the command line}
{
*   Build the complete command line to execute in CMLINE.
}
  string_vstring (cmline, name, namelen); {init command line with executable name}
  if cmline.len = 0 then begin         {program name not passed in NAME ?}
    string_cmline_token (cmline, stat); {try to get program name as first cmline arg}
    i := 1;
    sys_msg_parm_int (msg_parm[1], i);
    sys_error_abort (stat, 'string', 'cmline_arg_error', msg_parm, 1);
    end;

loop_cmline:                           {back here each new command line token}
  string_cmline_token (tk, stat);      {get next token from command line}
  if string_eos(stat) then goto done_cmline; {exhausted the command line ?}
  sys_error_abort (stat, 'string', 'cmline_opt_err', nil, 0);
  cmline_token_add (cmline, tk);       {add this token to assembled command line}
  goto loop_cmline;                    {back to process next command line token}
done_cmline:                           {CMLINE all set}
{
*   Execute the command line.
}
%debug 2; writeln ('Executing command "', cmline.str:cmline.len, '".');

  sys_run (                            {execute subordinate program}
    cmline,                            {command line to execute}
    sys_procio_talk_k,                 {set up pipes to child proc standard I/O}
    stdin.to_h, stdout.from_h, stderr.from_h, {returned handle to our ends of pipes}
    proc_h,                            {returned handle to child process}
    stat);
  sys_msg_parm_vstr (msg_parm[1], cmline);
  sys_error_abort (stat, 'sys', 'run_talk', msg_parm, 1);
{
*   The target program is running and unnamed pipes have been established
*   to the target program's standard input, standard output, and standard
*   error.
*
*   Now copy our standard I/O to/from these pipes such that it looks like
*   the target program is using our standard I/O.  This will be done by
*   launching a separate thread to handle each I/O connection.
}
  stdin.from_h := GetStdHandle (stdstream_in_k); {fill in non-pipe I/O handles}
  stdout.to_h := GetStdHandle (stdstream_out_k);
  stderr.to_h := GetStdHandle (stdstream_err_k);

  stdin.thread_h := CreateThread (     {create thread to copy standard input}
    nil,                               {no security info supplied}
    0,                                 {use default initial stack size}
    addr(io_copy),                     {address of thread routine}
    addr(stdin),                       {argument passed to thread routine}
    [],                                {optional creation flags}
    thread_id);                        {returned ID of this thread}
  stdout.thread_h := CreateThread (    {create thread to copy standard output}
    nil,                               {no security info supplied}
    0,                                 {use default initial stack size}
    addr(io_copy),                     {address of thread routine}
    addr(stdout),                      {argument passed to thread routine}
    [],                                {optional creation flags}
    thread_id);                        {returned ID of this thread}
  stderr.thread_h := CreateThread (    {create thread to copy standard error}
    nil,                               {no security info supplied}
    0,                                 {use default initial stack size}
    addr(io_copy),                     {address of thread routine}
    addr(stderr),                      {argument passed to thread routine}
    [],                                {optional creation flags}
    thread_id);                        {returned ID of this thread}

  i := 0;                              {init number of handles to wait on}
  if stdout.thread_h <> handle_none_k then begin {STDOUT thread exists ?}
    i := i + 1;
    waitfor[i] := stdout.thread_h;
    end;
  if stderr.thread_h <> handle_none_k then begin {STDERR thread exists ?}
    i := i + 1;
    waitfor[i] := stderr.thread_h;
    end;
  if i > 0 then begin                  {something left to wait for ?}
    discard( WaitForMultipleObjects (  {wait for STDOUT and STDERR threads to finish}
      i,                               {number of handles to wait on}
      waitfor,                         {list of handles to wait on}
      win_bool_true_k,                 {wait for all handles to be signalled}
      timeout_infinite_k) );           {no time limit to wait}
    end;
{
*   The two threads that copy data from the process are finished.  If no errors
*   occurred, this is because they encountered the end of the pipes, which were
*   automatically closed when the process terminated.
}
  discard( sys_proc_status (           {wait for process to finish}
    proc_h,                            {handle to child process}
    true,                              {wait for process to complete}
    exstat,                            {process exit status code}
    stat));

  discard( CloseHandle (stdin.thread_h) ); {try to release all our thread handles}
  discard( CloseHandle (stdout.thread_h) );
  discard( CloseHandle (stderr.thread_h) );

  sys_sys_run_gui := exstat;           {return exit status code of subordinate proc}
  end;
{
********************************************************************************
*
*   Subroutine SYS_SYS_INIT_WINGUI (INST_H, PREV_H, INIT_SHOW, NAME)
*
*   A call to this subroutine is automatically inserted by SST as the first
*   executable statement of a program module of a GUI app.  Note that this
*   routine is not declared in the include file, since SST writes the
*   declaration implicitly.
*
*   The call arguments INST_H, PREV_H, and INIT_SHOW are directly from the
*   WinMain arguments.  NAME is a null-terminated string containing the program
*   name from the PROGRAM statement in the original source code.
}
procedure sys_sys_init_wingui (        {init our OS layer for a Win32 GUI app}
  in      inst_h: win_handle_t;        {handle to this instance of this program}
  in      prev_h: win_handle_t;        {handle to previous instance of this program}
  in      init_show: winshow_k_t;      {initial window show state}
  in      name: string);               {program name, null terminated}
  val_param;

begin
  instance_h := inst_h;                {save some WinMain arguments in common block}
  instance_prev_h := prev_h;
  show_state_initial := init_show;

  sys_sys_stdout_nobuf;                {disable buffering of output standard streams}

  string_cmline_set (0, nil, name);    {set program name and init command line stuff}
  end;
