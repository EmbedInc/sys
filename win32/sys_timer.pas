{   Routines to handle stopwatch timers.
*
*   This version is for the Microsoft Win32 API.
}
module sys_timer;
define sys_timer_init;
define sys_timer_sec;
define sys_timer_start;
define sys_timer_stop;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
{
********************************************************************************
*
*   Subroutine SYS_TIMER_INIT (T)
}
procedure sys_timer_init (             {initialize a stopwatch timer}
  out     t: sys_timer_t);             {timer to initialize}

begin
  t.sec := 0.0;
  t.on := false;
  end;
{
********************************************************************************
*
*   Subroutine SYS_TIMER_START (T)
}
procedure sys_timer_start (            {start accumulating elapsed time}
  in out  t: sys_timer_t);             {timer to use}

begin
  GetSystemTime (t.sys);               {save time when starting stopwatch}
  t.on := true;                        {indicate timer is ON}
  end;
{
********************************************************************************
*
*   Subroutine SYS_TIMER_STOP (T)
*
*   End a timing interval.  The interval length is added to the total currently
*   in the timer.  The results are undefined if the timer is not ON.
}
procedure sys_timer_stop (             {stop accumulating elapsed time}
  in out  t: sys_timer_t);             {timer to use}

var
  now: sys_sys_time_t;                 {system time right now}

begin
  GetSystemTime (now);                 {get time right now}
  t.sec := t.sec +                     {add this interval to accumulated total}
    sys_clock_to_fp2 (sys_clock_sub (
      sys_clock_from_sys_abs(now), sys_clock_from_sys_abs(t.sys) ));
  t.on := false;                       {indicate no longer timing an interval}
  end;
{
********************************************************************************
*
*   Subroutine SYS_TIMER_SEC (T)
}
function sys_timer_sec (               {return elapsed seconds currently on timer}
  in      t: sys_timer_t)              {timer to use}
  :double;

var
  now: sys_sys_time_t;                 {system time right now}

begin
  if t.on
    then begin                         {stopwatch is currently running}
      GetSystemTime (now);             {get time right now}
      sys_timer_sec := t.sec +         {add this interval to accumulated total}
        sys_clock_to_fp2 (sys_clock_sub (
          sys_clock_from_sys_abs(now), sys_clock_from_sys_abs(t.sys) ));
      end
    else begin                         {stopwatch is currently stopped}
      sys_timer_sec := t.sec;
      end
    ;
  end;
