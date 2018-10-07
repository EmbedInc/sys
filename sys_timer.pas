{   Routines to handle stopwatch timers.
*
*   This version is for generic Unix operating systems where the native system
*   time descriptor counts in seconds and mirco-seconds.
}
module sys_timer;
define sys_timer_init;
define sys_timer_sec;
define sys_timer_start;
define sys_timer_stop;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
{
*************************************
*
*   Subroutine
}
procedure sys_timer_init (             {initialize a stopwatch timer}
  out     t: sys_timer_t);             {timer to initialize}

begin
  t.sec := 0.0;
  t.on := false;
  end;
{
*************************************
*
*   Subroutine
}
procedure sys_timer_start (            {start accumulating elapsed time}
  in out  t: sys_timer_t);             {timer to use}

var
  unused: timezone_t;

begin
  sys_sys_err_abort ('sys', 'time_get_err', nil, 0,
    gettimeofday (t.sys, unused) );    {get current system clock value}
  t.on := true;                        {indicate timer is ON}
  end;
{
*************************************
*
*   Subroutine
}
procedure sys_timer_stop (             {stop accumulating elapsed time}
  in out  t: sys_timer_t);             {timer to use}

var
  now: sys_sys_time_t;                 {system time right now}
  unused: timezone_t;

begin
  sys_sys_err_abort ('sys', 'time_get_err', nil, 0,
    gettimeofday (now, unused) );      {get current system clock value}
  t.sec := t.sec +                     {add on elapsed time from timer start}
    now.sec - t.sys.sec +              {add on whole elapsed seconds}
    (now.usec - t.sys.usec)*1.0E-6;    {add on fractions of second}
  t.on := false;                       {indicate no longer timing an interval}
  end;
{
*************************************
*
*   Subroutine
}
function sys_timer_sec (               {return elapsed seconds currently on timer}
  in      t: sys_timer_t)              {timer to use}
  :double;

var
  now: sys_sys_time_t;                 {system time right now}
  unused: timezone_t;

begin
  if t.on
    then begin                         {stopwatch is currently running}
      sys_sys_err_abort ('sys', 'time_get_err', nil, 0,
        gettimeofday (now, unused) );  {get current system clock value}
      sys_timer_sec := t.sec +         {add on elapsed time from timer start}
        now.sec - t.sys.sec +          {add on whole elapsed seconds}
        (now.usec - t.sys.usec)*1.0E-6; {add on fractions of second}
      end
    else begin                         {stopwatch is currently stopped}
      sys_timer_sec := t.sec;
      end
    ;
  end;
