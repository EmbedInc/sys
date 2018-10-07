{   Program TEST_RUN <command line> [<option1> . . .]
*
*   Test routines that invoke programs.  The <command line> argument will be
*   the complete command line of the invoked program.  Valid options are:
*
*   -STDIO
*
*     Connect the invoked programs standard streams to this program's streams.
*     The standard streams are: standard input, standard output, error output.
}
program test_run;
%include 'sys.ins.pas';
%include 'util.ins.pas';
%include 'string.ins.pas';

const
  max_msg_parms = 1;                   {max parameters we can pass to a message}

var
  cmline:                              {command line for invoked program}
    %include '(cog)lib/string_treename.ins.pas';
  exstat: sys_sys_exstat_t;            {subordinate process exit status}
  stdio: boolean;                      {TRUE on -STDIO command line arg}
  tf: boolean;                         {returned TRUE/FALSE status from program}
  timer: sys_timer_t;                  {stopwatch to see how long program takes}

  opt:                                 {command line option name}
    %include '(cog)lib/string32.ins.pas';
  pick: sys_int_machine_t;             {number of option name in list}
  msg_parm:                            {message parameter references}
    array[1..max_msg_parms] of sys_parm_msg_t;
  stat: sys_err_t;                     {error status code}

label
  next_parm, done_parms;

begin
  sys_timer_init (timer);              {init stopwatch}

  string_cmline_init;                  {init reading our command line}
  string_cmline_token (cmline, stat);  {get command line of invoked program}
  string_cmline_req_check (stat);      {this argument is required}

  stdio := false;                      {init to default values}

next_parm:                             {back here for each new command line parameter}
  string_cmline_token (opt, stat);     {get next command line option name}
  if string_eos(stat) then goto done_parms; {exhausted command line ?}
  string_upcase (opt);                 {make upper case for token matching}
  string_tkpick80 (opt,
    '-STDIO',
    pick);
  case pick of
{
*   -STDIO
}
1: begin
  stdio := true;
  end;
{
*   Unrecognized command line option name.
}
otherwise
    string_cmline_opt_bad;
    end;                               {end of option name cases}
  goto next_parm;                      {back for next command line option}
done_parms:                            {jump here when all done with comline parms}

  sys_timer_start (timer);             {turn on stopwatch}
  if stdio
    then begin                         {connect program to our streams}
      sys_run_wait_stdsame (cmline, tf, exstat, stat);
      end
    else begin                         {don't connect program to any streams}
      sys_run_wait_stdnone (cmline, tf, exstat, stat);
      end
    ;
  sys_timer_stop (timer);              {turn off stopwatch}
  sys_msg_parm_vstr (msg_parm[1], cmline);
  sys_error_abort (stat, 'sys', 'test_run_program_error', msg_parm, 1);

  sys_msg_parm_int (msg_parm[1], ord(exstat));
  if tf
    then begin                         {program indicated TRUE}
      sys_message_parms ('sys', 'test_run_bool_true', msg_parm, 1);
      end
    else begin                         {program indicated FALSE}
      sys_message_parms ('sys', 'test_run_bool_false', msg_parm, 1);
      end
    ;

  sys_msg_parm_fp2 (msg_parm[1], sys_timer_sec(timer));
  sys_message_parms ('sys', 'time_elapsed', msg_parm, 1); {print program's elapsed time}
  end.
