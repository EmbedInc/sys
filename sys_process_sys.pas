{   System-dependent routines that deal with processes.
*   The system-independent routines are in module SYS_PROCESS.PAS.
*
*   This version is the generic Unix version.
}
module sys_process_sys;
define sys_proc_release;
define sys_proc_status;
define sys_proc_stop;
define sys_run;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
%include 'string.ins.pas';
{
**********************************************************************
*
*   Subroutine SYS_PROC_RELEASE (PROC, STAT)
*
*   Release a child process so that no state is used up for the process when
*   it exits.  The default on many systems is that a child process that has
*   exited becomes a "zombie" process until the parent process gets the exit
*   status code.  This call causes the child process to be completely removed
*   from the process table when it exits.  Note that we can therefore no
*   longer determine its exit status code.
*
*   The default on most Unix systems is set up so that an exiting child process
*   just vanishes without creating a zombie.  This routine therefore does
*   nothing.
*
*   On HPUX, for example, an exiting child process causes the SIGCLD signal
*   to be thrown.  The child process is completely removed (and therefore doesn't
*   become a zombie) if SIGCLD is set to SIG_IGN, which is the default.
}
procedure sys_proc_release (           {let go of process, may deallocate resources}
  in      proc: sys_sys_proc_id_t;     {ID of process we launched}
  out     stat: sys_err_t);            {returned error status}
  val_param;

begin
  sys_error_none (stat);               {init to no error}
  end;
{
**********************************************************************
}
procedure sys_proc_stop (              {stop a process on this system}
  in      proc: sys_sys_proc_id_t;     {ID of process to stop}
  out     stat: sys_err_t);            {returned error status}
  val_param;

begin
  sys_error_none (stat);               {init to no error occurred}

  if kill (proc, signal_kill_k) < 0 then begin {send kill signal to process}
    stat.sys := errno;
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
  proc_id: sys_sys_proc_id_t;          {sratch process ID}
  procstat: procstat_t;                {info about stopped process}
  waitopt: waitopt_t;                  {WAITPID options flags}

begin
  sys_error_none (stat);               {init to no error occurred}
  sys_proc_status := true;             {init to indicate child process is stopped}

  if wait                              {need to wait for process to terminate ?}
    then waitopt := []
    else waitopt := [waitopt_nohang_k];

  proc_id := waitpid (                 {get child process current status}
    proc,                              {ID of process to wait for}
    procstat,
    waitopt);                          {wait for process to terminate, if required}
  if proc_id = -1 then begin           {hard error ?}
    stat.sys := errno;
    return;
    end;
  if proc_id = 0 then begin            {process not stopped yet ?}
    sys_proc_status := false;
    return;
    end;

  exstat := procstat.stat;             {extract just the exit status code}
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
  max_msg_parms = 1;                   {max parameters we can pass to a message}

var
  p: string_index_t;                   {CMLINE parse index}
  fnam: string_treename_t;             {file name of program to run}
  progname: string_leafname_t;         {name of program passed as arg0}
  token: string_var8192_t;             {temp string for extracting individual tokens}
  i: sys_int_machine_t;                {scratch integer and loop counter}
  args_list: string_list_t;            {handle to list of arguments}
  argv_p: ^exec_arg_list_t;            {pointer to arguments pointers list}
  mem_p: util_mem_context_p_t;         {points to our memory handle}
  sz: sys_int_adr_t;                   {amount of memory needed}
  child_id: sys_sys_proc_id_t;         {ID of child process}
  msg_parm:                            {references to message parameters}
    array[1..max_msg_parms] of sys_parm_msg_t;

label
  arg_loop, done_args;

begin
  fnam.max := sizeof(fnam.str);        {init local var strings}
  progname.max := sizeof(progname.str);
  token.max := sizeof(token.str);
  sys_error_none (stat);               {init to no error occurred}

  util_mem_context_get (util_top_mem_context, mem_p); {create memory context for us}
  mem_p^.pool_size := 4096;            {set size of pools}
  mem_p^.max_pool_chunk := 256;        {max size allowed to allocate from pool}
  string_list_init (args_list, mem_p^); {init args list data structure}
  args_list.deallocable := false;      {won't need to individually deallocate strings}
  p := 1;                              {init CMLINE parse index}

  string_token (cmline, p, fnam, stat); {get program pathname from CMLINE}
  sys_error_abort (stat, 'sys', 'run_progname_get', nil, 0);
  string_generic_fnam (fnam, '', progname); {get program leaf name}
  fnam.str[min(fnam.max, fnam.len + 1)] := chr(0); {add NULL terms for system calls}
  progname.str[min(progname.max, progname.len + 1)] := chr(0);

arg_loop:                              {back here for each new arg from CMLINE}
  string_token (cmline, p, token, stat); {get next token from whole command line}
  if string_eos(stat) then goto done_args; {hit end of command line string ?}
  args_list.size := token.len + 1;     {make string just big enough for 0 terminator}
  string_list_line_add (args_list);    {create new string for this argument}
  sys_msg_parm_int (msg_parm[1], args_list.n);
  sys_error_abort (stat, 'sys', 'run_arg_get', msg_parm, 1);
  string_copy (token, args_list.str_p^); {copy characters into argument string}
  args_list.str_p^.str[args_list.str_p^.len + 1] := chr(0); {add NULL terminator}
  goto arg_loop;                       {back to handle next program command line arg}
done_args:                             {argument vector is all filled in}
{
*   All the arguments have been separated and are in the strings list ARGS_LIST.
*   Now allocate the argument vector and fill it in.
}
  sz := size_align(exec_arg_p_t) *     {amount of memory needed for arg pointers list}
    (args_list.n + 2);

  util_mem_grab (sz, mem_p^, true, argv_p); {alloc mem for args pointers list}
  argv_p^[0] := addr(progname.str);    {arg 0 is always leaf name of program}
  string_list_pos_start (args_list);   {go to before first argument in list}

  for i := 1 to args_list.n do begin   {once for each argument in list}
    string_list_pos_rel (args_list, 1); {advance to next arg in list}
    argv_p^[i] := addr(args_list.str_p^.str);
    end;

  argv_p^[args_list.n + 1] := nil;     {indicate end of arg pointers list}

case stdio_method of
{
*   Process gets no standard I/O connection to parent.
}
sys_procio_none_k: begin
  child_id := fork;                    {create child process right here}
  if child_id = 0 then begin           {executing the child process ?}
    discard( close (0) );              {close standard input}
    discard( close (1) );              {close standard output}
    discard( close (2) );              {close error output}
    discard( execv(fnam.str, argv_p^) ); {run program by taking over child process}
    call exit (3);                     {exit with error (should never get here)}
    end;
  end;
{
*   Process will use the same standard I/O streams we do.  The new process'
*   standard I/O will look just like our standard I/O to the user.
}
sys_procio_same_k: begin
  child_id := fork;                    {create child process right here}
  if child_id = 0 then begin           {executing the child process ?}
    discard( execv(fnam.str, argv_p^) ); {run program by taking over child process}
    call exit (3);                     {exit with error (should never get here)}
    end;
  end;
{
*   Process will "talk" to us with its standard I/O.  This means we created
*   a pipe for each standard I/O stream.  The process will get the handle
*   for one end, and we will pass back the handles to the other ends.
}
sys_procio_talk_k: begin
  writeln ('Option SYS_PROCIO_TALK_K not implemented in SYS_RUN.');
  sys_bomb;
  end;
{
*   The standard I/O handles for the new process have been explicitly given
*   us by the caller.
}
sys_procio_explicit_k: begin
  writeln ('Option SYS_PROCIO_EXPLICIT_K not implemented in SYS_RUN.');
  sys_bomb;
  end;

otherwise                              {unrecognized STDIO_METHOD}
    sys_msg_parm_int (msg_parm[1], ord(stdio_method));
    sys_message_bomb ('sys', 'proc_stdio_method_unknown', msg_parm[1], 1);
    end;                               {end of STDIO_METHOD cases}

  util_mem_context_del (mem_p);        {delete all our dynamically allocated memory}
  proc := child_id;                    {return handle to child process}
  end;
