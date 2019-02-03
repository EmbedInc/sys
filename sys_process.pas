{   System-independent routines that deal with processes.
*
*   The system-dependent routines are in SYS_PROCESS_SYS.PAS.
}
module sys_process;
define sys_run_stdtalk;
define sys_run_wait_stdnone;
define sys_run_wait_stdsame;
%include 'sys2.ins.pas';
{
**********************************************************************
}
procedure sys_run_stdtalk (            {run prog, get handles to standard streams}
  in      cmline: univ string_var_arg_t; {prog pathname and command line arguments}
  out     proc: sys_sys_proc_id_t;     {system ID of new process}
  out     stdin: sys_sys_file_conn_t;  {program's standard input stream handle}
  out     stdout: sys_sys_file_conn_t; {program's standard output stream handle}
  out     stderr: sys_sys_file_conn_t; {program's standard error stream handle}
  out     stat: sys_err_t);            {returned error status}
  val_param;

begin
  sys_run (                            {run separate process}
    cmline,                            {prog pathname and command line arguments}
    sys_procio_talk_k,                 {return handles to talk to process std I/O}
    stdin, stdout, stderr,             {returned handles to talk to process with}
    proc,                              {returned ID of new process}
    stat);
  end;
{
**********************************************************************
}
procedure sys_run_wait_stdnone (       {run program, wait until done, no I/O conn}
  in      cmline: univ string_var_arg_t; {prog pathname and command line arguments}
  out     tf: boolean;                 {TRUE/FALSE condition returned by program}
  out     exstat: sys_sys_exstat_t;    {exit status returned by program}
  out     stat: sys_err_t);            {program's completion status code}
  val_param;

var
  io_dummy: sys_sys_iounit_t;          {unused}
  proc: sys_sys_proc_id_t;             {ID of new process}

begin
  sys_run (                            {run separate process}
    cmline,                            {prog pathname and command line arguments}
    sys_procio_none_k,                 {specify no I/O connection to new process}
    io_dummy, io_dummy, io_dummy,      {process I/O handles, unused}
    proc,                              {returned ID of new process}
    stat);
  if sys_error(stat) then return;

  discard( sys_proc_status (           {get process status}
    proc,                              {process ID}
    true,                              {wait for process to terminate}
    exstat,                            {returned process exit status}
    stat));
  if sys_error(stat) then return;

  tf := exstat = 0;                    {exit status of 0 also means TRUE}
  end;
{
**********************************************************************
}
procedure sys_run_wait_stdsame (       {run prog, wait for done, standard I/O conn}
  in      cmline: univ string_var_arg_t; {prog pathname and command line arguments}
  out     tf: boolean;                 {TRUE/FALSE condition returned by program}
  out     exstat: sys_sys_exstat_t;    {exit status returned by program}
  out     stat: sys_err_t);            {program's completion status code}
  val_param;

var
  io_dummy: sys_sys_iounit_t;          {unused}
  proc: sys_sys_proc_id_t;             {ID of new process}

begin
  sys_run (                            {run separate process}
    cmline,                            {prog pathname and command line arguments}
    sys_procio_same_k,                 {new process will use our standard I/O conn}
    io_dummy, io_dummy, io_dummy,      {process I/O handles, unused}
    proc,                              {returned ID of new process}
    stat);
  if sys_error(stat) then return;

  discard( sys_proc_status (           {get process status}
    proc,                              {process ID}
    true,                              {wait for process to terminate}
    exstat,                            {returned process exit status}
    stat));
  if sys_error(stat) then return;

  tf := exstat = 0;                    {exit status of 0 also means TRUE}
  end;
