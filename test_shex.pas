{   Program TEST_SHEX filename
*
*   Test the ability to execute thru the shell.  Bare system execution requires
*   the file to be directly executable, like a .EXE.  By executing thru the
*   shell, file name suffix associations are taken into account.  For example,
*   ".htm" files should launch the default browser and display the HTML file
*   content.
}
program test_shex;
%include '(cog)lib/base.ins.pas';

var
  parm:                                {command line parameter}
    %include '(cog)lib/string_treename.ins.pas';
  cmd:                                 {command to execute}
    %include '(cog)lib/string8192.ins.pas';
  stat: sys_err_t;

begin
  string_cmline_init;
  cmd.len := 0;                        {init the command to execute to empty}
  while true do begin                  {get each command line parameter}
    string_cmline_token (parm, stat);  {try to get this command line parameter}
    if string_eos(stat) then exit;
    string_append_token (cmd, parm);   {add it to the command line to run}
    end;

  sys_run_shell (
    cmd,
    stat);
  sys_error_abort (stat, '', '', nil, 0);
  end.
