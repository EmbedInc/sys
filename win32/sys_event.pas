{   Module of routines that deal with system events which can be waited on.
*
*   This version is for the Microsoft Win32 API.
}
module sys_event;
define sys_event_create_bool;
define sys_event_create_cnt;
define sys_event_del_bool;
define sys_event_del_cnt;
define sys_event_notify_bool;
define sys_event_notify_cnt;
define sys_event_wait_any;
define sys_event_wait;
define sys_event_wait_tout;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
{
**********************************************************************
}
procedure sys_event_create_bool (      {create a Boolean (on/off) system event}
  out     id: sys_sys_event_id_t);     {system event handle, initialized to OFF}
  val_param;

begin
  id := CreateEventA (                 {create a new event object}
    nil,                               {no security attributes supplied}
    win_bool_false_k,                  {reset event on successful wait}
    win_bool_false_k,                  {event not initially triggered}
    nil);                              {no name supplied}
  if id = handle_none_k then begin     {system call failed ?}
    sys_sys_error_bomb ('sys', 'event_create_bool', nil, 0);
    end;
  end;
{
**********************************************************************
}
procedure sys_event_create_cnt (       {create a counted event (semiphore)}
  out     id: sys_sys_event_id_t);     {system event handle, initialized to no event}
  val_param;

begin
  id := CreateSemaphoreA (             {create a new semaphore object}
    nil,                               {no security attributes supplied}
    0,                                 {initial value, not signalled}
    16#7FFFFFFF,                       {maximum allowed semiphore value}
    nil);                              {no name supplied}
  if id = handle_none_k then begin     {system call failed ?}
    sys_sys_error_bomb ('sys', 'event_create_cnt', nil, 0);
    end;
  end;
{
**********************************************************************
}
procedure sys_event_del_bool (         {delete a Boolean system event}
  in out  id: sys_sys_event_id_t);     {handle to event to delete}
  val_param;

begin
  discard( CloseHandle (id) );         {close handle to the event object}
  end;
{
**********************************************************************
}
procedure sys_event_del_cnt (          {delete a counted system event}
  in out  id: sys_sys_event_id_t);     {handle to event to delete}
  val_param;

begin
  discard( CloseHandle (id) );         {close handle to the semaphore object}
  end;
{
**********************************************************************
}
procedure sys_event_notify_bool (      {notify (trigger) a Boolean system event}
  in out  id: sys_sys_event_id_t);     {handle to event to trigger}
  val_param;

var
  ok: win_bool_t;

begin
  ok := SetEvent (id);                 {set the event object to signalled}
  if ok = win_bool_false_k then begin  {system call failed ?}
    sys_sys_error_bomb ('sys', 'event_notify_bool', nil, 0);
    end;
  end;
{
**********************************************************************
}
procedure sys_event_notify_cnt (       {notify (trigger) a counted system event}
  in out  id: sys_sys_event_id_t;      {handle to event to trigger}
  in      n: sys_int_machine_t);       {number of times to notify the event}
  val_param;

var
  i: win_long_t;
  ok: win_bool_t;

begin
  ok := ReleaseSemaphore (             {increment the semaphore value}
    id,                                {handle to the semaphore object}
    1,                                 {amount to increment the semaphore by}
    i);                                {semaphore value before increment (unused)}
  if ok = win_bool_false_k then begin  {system call failed ?}
    sys_sys_error_bomb ('sys', 'event_notify_cnt', nil, 0);
    end;
  end;
{
**********************************************************************
}
procedure sys_event_wait_any (         {wait for any event in list to trigger}
  in out  events: sys_event_list_t;    {list of events to wait on}
  in      n_list: sys_int_machine_t;   {number of entries in EVENTS list}
  in      timeout: real;               {seconds timeout, or SYS_TIMEOUT_xxx_K}
  out     n: sys_int_machine_t;        {1-N triggered event, 0 = timeout, -1 = err}
  out     stat: sys_err_t);            {returned error status, N = -1 on error}
  val_param;

var
  donewait: donewait_k_t;              {reason wait completed}
  tout: win_dword_t;                   {timeout value in system format}

begin
  sys_error_none (stat);               {init to no errors}

  if timeout = sys_timeout_none_k
    then begin                         {no timeout, wait forever}
      tout := timeout_infinite_k;
      end
    else begin                         {timeout after specified elapsed time}
      tout := round(max(1.0, timeout * 1000.0)); {convert to integer milliseconds}
      end
    ;

  donewait := WaitForMultipleObjects ( {wait for any one of the events to occur}
    n_list,                            {number of events in list to wait for}
    events,                            {the list of events to wait on}
    win_bool_false_k,                  {any (not all) event triggered ends wait}
    tout);                             {timeout strategy}

  case donewait of
donewait_timeout_k: begin              {no events were signalled, timeout reached}
      n := 0;                          {indicate timeout reached}
      end;
donewait_failed_k: begin               {hard error occurred}
      stat.sys := GetLastError;        {return system error status}
      n := -1;                         {indicate hard error}
      end;
otherwise
    if (ord(donewait) >= 0) and (ord(donewait) < n_list) then begin {event happened ?}
      n := ord(donewait) + 1;          {indicate number of event that triggered}
      return;
      end;
    sys_stat_set (sys_subsys_k, sys_stat_failed_k, stat); {set error status}
    n := -1;                           {indicate hard error}
    end;                               {end of DONEWAIT cases}
  end;
{
**********************************************************************
}
function sys_event_wait_tout (         {wait for single event or timeout}
  in out  event: sys_sys_event_id_t;   {the event to wait on}
  in      timeout: real;               {seconds timeout, or SYS_TIMEOUT_xxx_K}
  out     stat: sys_err_t)             {returned error status}
  :boolean;                            {TRUE on timeout or error}
  val_param;

var
  donewait: donewait_k_t;              {reason wait completed}
  tout: win_dword_t;                   {timeout value in system format}

begin
  sys_error_none (stat);               {init to no errors}
  sys_event_wait_tout := true;         {init to returning with timeout or error}

  if timeout = sys_timeout_none_k
    then begin                         {no timeout, wait forever}
      tout := timeout_infinite_k;
      end
    else begin                         {timeout after specified elapsed time}
      tout := round(max(1.0, timeout * 1000.0)); {convert to integer milliseconds}
      end
    ;

  donewait := WaitForSingleObject (    {wait on one event or timeout}
    event,                             {the event to wait on}
    tout);                             {maximum time to wait}

  case donewait of
donewait_timeout_k: ;                  {timeout reached}
donewait_failed_k: begin               {hard error occurred}
      stat.sys := GetLastError;        {return system error status}
      end;
otherwise
    sys_event_wait_tout := false;      {indicate returning due to event, not timeout}
    end;
  end;
{
**********************************************************************
}
procedure sys_event_wait (             {wait indefinitely on a single event}
  in out  event: sys_sys_event_id_t;   {the event to wait on}
  out     stat: sys_err_t);            {returned error status}
  val_param;

var
  donewait: donewait_k_t;              {reason wait completed}

begin
  sys_error_none (stat);               {init to no errors}

  donewait := WaitForSingleObject (    {wait on one event or timeout}
    event,                             {the event to wait on}
    timeout_infinite_k);               {no timeout, wait as long as it takes}
  if donewait = donewait_failed_k then begin {hard error ?}
    stat.sys := GetLastError;          {return system error status}
    end;
  end;
