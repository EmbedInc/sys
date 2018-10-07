{   Module of routines that deal with system events which can be waited on.
*
*   This version is the main line of decent.  Each of the routines here
*   just bomb with a routine not implemented message.
}
module sys_event;
define sys_event_create_bool;
define sys_event_create_cnt;
define sys_event_del_bool;
define sys_event_del_cnt;
define sys_event_notify_bool;
define sys_event_notify_cnt;
define sys_event_wait_any;
%include 'sys2.ins.pas';
{
**********************************************************************
}
procedure sys_event_create_bool (      {create a Boolean (on/off) system event}
  out     id: sys_sys_event_id_t);     {system event handle, initialized to OFF}
  val_param;

begin
  writeln ('Routine SYS_EVENT_CREATE_BOOL is not implemented on this platform.');
  sys_bomb;
  end;
{
**********************************************************************
}
procedure sys_event_create_cnt (       {create a counted event (semiphore)}
  out     id: sys_sys_event_id_t);     {system event handle, initialized to no event}
  val_param;

begin
  writeln ('Routine SYS_EVENT_CREATE_CNT is not implemented on this platform.');
  sys_bomb;
  end;
{
**********************************************************************
}
procedure sys_event_del_bool (         {delete a Boolean system event}
  in out  id: sys_sys_event_id_t);     {handle to event to delete}
  val_param;

begin
  writeln ('Routine SYS_EVENT_DEL_BOOL is not implemented on this platform.');
  sys_bomb;
  end;
{
**********************************************************************
}
procedure sys_event_del_cnt (          {delete a counted system event}
  in out  id: sys_sys_event_id_t);     {handle to event to delete}
  val_param;

begin
  writeln ('Routine SYS_EVENT_DEL_CNT is not implemented on this platform.');
  sys_bomb;
  end;
{
**********************************************************************
}
procedure sys_event_notify_bool (      {notify (trigger) a Boolean system event}
  in out  id: sys_sys_event_id_t);     {handle to event to trigger}
  val_param;

begin
  writeln ('Routine SYS_EVENT_NOTIFY_BOOL is not implemented on this platform.');
  sys_bomb;
  end;
{
**********************************************************************
}
procedure sys_event_notify_cnt (       {notify (trigger) a counted system event}
  in out  id: sys_sys_event_id_t;      {handle to event to trigger}
  in      n: sys_int_machine_t);       {number of times to notify the event}
  val_param;

begin
  writeln ('Routine SYS_EVENT_NOTIFY_CNT is not implemented on this platform.');
  sys_bomb;
  end;
{
**********************************************************************
}
procedure sys_event_wait_any (         {wait for any event in list to trigger}
  in out  events: univ sys_event_list_t; {list of events to wait on}
  in      n_list: sys_int_machine_t;   {number of entries in EVENTS list}
  in      timeout: real;               {seconds timeout, or SYS_TIMEOUT_xxx_K}
  out     n: sys_int_machine_t;        {1-N triggered event, 0 = timeout, -1 = err}
  out     stat: sys_err_t);            {returned error status, N = -1 on error}
  val_param;

begin
  writeln ('Routine SYS_EVENT_WAIT_ANY is not implemented on this platform.');
  sys_bomb;
  end;
