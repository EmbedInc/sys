{   Subroutine SYS_INIT
*
*   Performs one-time initialization of the SYS library.  This routine is not
*   externally declared since it should never be called deliberately by
*   applications or other SYS routines.  It is called only from
*   STRING_CMLINE_SET.
*
*   A call to STRING_CMLINE_SET is required to be the first executable statement
*   of every top level program.  This is guaranteed by SST.  It must be done
*   manually if SST is not used.
}
module sys_init;
define sys_init;
%include 'sys2.ins.pas';

procedure sys_init;

begin
  sys_thread_lock_enter_all;           {make sure global single-thread lock created}
  sys_thread_lock_leave_all;
  end;
