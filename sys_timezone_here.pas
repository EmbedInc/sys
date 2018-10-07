{   Subroutine SYS_TIMEZONE_HERE (TZONE, HOURS_WEST, DAYSAVE)
*
*   Return information about the current time zone.  TZONE is the time zone ID.
*   HOURS_WEST is the number of hours this standard time zone is west of coordinated
*   universal time when daylight savings time is not applied.  DAYSAVE is the
*   daylight savings time strategy for this time zone.
*
*   The returned values are in the correct format to be directly passed to
*   SYS_CLOCK_TO_DATE to convert to a date in the local time zone.
}
module sys_timezone_here;
define sys_timezone_here;
%include 'sys2.ins.pas';

procedure sys_timezone_here (          {get information about the current time zone}
  out     tzone: sys_tzone_k_t;        {time zone ID}
  out     hours_west: real;            {hours west of CUT without daylight save time}
  out     daysave: sys_daysave_k_t);   {daylight savings time strategy}
  val_param;

begin
{
*   This is a temporary version that always returns the USA eastern time zone.
}
  tzone := sys_tzone_east_usa_k;
  hours_west := 5;
  daysave := sys_daysave_appl_k;
  end;
