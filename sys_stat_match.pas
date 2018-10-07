{   Subroutine SYS_STAT_MATCH (SUBSYS, CODE, STAT)
*
*   Return TRUE if the status indicated by STAT is the code CODE within the
*   subsystem of ID SUBSYS.  If STAT does match, then it is reset to indicate
*   no error.
}
module sys_STAT_MATCH;
define sys_stat_match;
%include 'sys2.ins.pas';

function sys_stat_match (              {TRUE on specified STAT condition}
  in      subsys: sys_int_machine_t;   {subsystem ID to compare against}
  in      code: sys_int_machine_t;     {code within subsystem to compare against}
  in out  stat: sys_err_t)             {status to test, reset to no error if matched}
  :boolean;                            {TRUE if STAT matched specified conditions}
  val_param;

begin
  if
      stat.err and
      (stat.subsys = subsys) and
      (stat.code = code)

    then begin                         {status DOES match}
      sys_stat_match := true;
      sys_error_none (stat);           {reset STAT on match condition}
      end

    else begin                         {status does NOT match}
      sys_stat_match := false;
      end
    ;
  end;
