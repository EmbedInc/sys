{   System-dependent routines that manipulate Cognivision clock descriptors.
*
*   This version should work for systems where the system clock descriptor
*   has two fields.  SEC is time in seconds, USEC is additional
*   time in micro-seconds.  Time 0 is the start of 1 January 1970.
}
module sys_clock_sys;
define sys_clock;
define sys_clock_from_sys_abs;
define sys_clock_from_sys_rel;
define sys_clock_to_sys;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
{
*   Constants used for converting tio/from relative system time values.
*   The constants here are somewhat arbitrary, but don't really matter as
*   long as converion to and from a relative system time value are consistant.
}
const
  day_year = 365;                      {days in a year}
  sec_minute = 60;                     {seconds in a minute}
  sec_hour = sec_minute * 60;          {seconds in an hour}
  sec_day = sec_hour * 24;             {seconds in a day}
  sec_month = sec_day * 30;            {seconds in a month}
  sec_year = sec_day * day_year;       {seconds in a year}
{
***************************************************
*
*   Function SYS_CLOCK_FROM_SYS_REL (CLOCK_SYS)
*
*   Convert a system time descriptor describing a relative time value to
*   a Cognivision clock value.
}
function sys_clock_from_sys_rel (      {make clock value from relative system time}
  in      clock_sys: sys_sys_time_t)   {relative system time descriptor}
  :sys_clock_t;                        {returned Cognivision time descriptor}
  val_param;

var
  s: sys_fp2_t;                        {accumulated relative seconds}

begin
  s :=
    clock_sys.year * sec_year +
    clock_sys.month * sec_month +
    clock_sys.day * sec_day +
    clock_sys.hour * sec_hour +
    clock_sys.minute * sec_minute +
    clock_sys.second +
    clock_sys.msec * 1000.0;

  sys_clock_from_sys_rel := sys_clock_from_fp_rel (s);
  end;
{
***************************************************
*
*   Function SYS_CLOCK_FROM_SYS_ABS (CLOCK_SYS)
*
*   Convert a system time descriptor describing an absolute time value to
*   a Cognivision clock value.
}
function sys_clock_from_sys_abs (      {make clock value from absolute system time}
  in      clock_sys: sys_sys_time_t)   {absolute system time descriptor}
  :sys_clock_t;                        {returned Cognivision time descriptor}
  val_param;

var
  date: sys_date_t;                    {Cognivision expanded date/time descriptor}

begin
  date.year := clock_sys.year;         {fill in Cognivision date descriptor}
  date.month := clock_sys.month - 1;
  date.day := clock_sys.day - 1;
  date.hour := clock_sys.hour;
  date.minute := clock_sys.minute;
  date.second := clock_sys.second;
  date.sec_frac := clock_sys.msec * 0.001;
  date.hours_west := 0.0;
  date.tzone_id := sys_tzone_cut_k;
  date.daysave := sys_daysave_no_k;
  date.daysave_on := false;

  sys_clock_from_sys_abs := sys_clock_from_date (date);
  end;
{
***************************************************
*
*   Function SYS_CLOCK
*
*   Return the current time in a Cognivision time descriptor.
}
function sys_clock                     {get the current time}
  :sys_clock_t;                        {returned time descriptor for current time}
  val_param;

var
  time_sys: sys_sys_time_t;            {system time descriptor}

begin
  GetSystemTime (time_sys);            {get current system coordinated univ time}
  sys_clock := sys_clock_from_sys_abs(time_sys); {convert to Cog time descriptor}
  end;
{
***************************************************
*
*   Function SYS_CLOCK_TO_SYS (CLOCK)
*
*   Convert a Cognivision time descriptor to a system time descriptor.
}
function sys_clock_to_sys (            {convert Cognivision to system clock time}
  in      clock: sys_clock_t)          {Cognivision time descriptor}
  :sys_sys_time_t;                     {returned system time descriptor}
  val_param;

var
  date: sys_date_t;                    {Cognivision expanded date/time descriptor}
  time_sys: sys_sys_time_t;            {system time descriptor}
  s: sys_fp2_t;                        {relative seconds}

begin
  if clock.rel
{
*   Input time is RELATIVE.
}
    then begin
      s := sys_clock_to_fp2 (clock);   {convert to relative seconds}
      time_sys.year := trunc(s / sec_year);
      s := s - time_sys.year * sec_year;
      time_sys.month := 0;
      time_sys.day_week := 0;
      time_sys.day := trunc(s / sec_day);
      s := s - time_sys.day * sec_day;
      time_sys.hour := trunc(s / sec_hour);
      s := s - time_sys.hour * sec_hour;
      time_sys.minute := trunc(s / sec_minute);
      s := s - time_sys.minute * sec_minute;
      time_sys.second := trunc(s);
      s := s - time_sys.second;
      time_sys.msec := trunc(s * 1000.0);
      end
{
*   Input time is ABSOLUTE.
}
    else begin
      sys_clock_to_date (              {make expanded date/time descriptor}
        clock,                         {input Cognivision clock value}
        sys_tzone_cut_k,               {coordinated universal time}
        0.0,                           {hours west of coordinated univeral time}
        sys_daysave_no_k,              {don't use daylight savings time}
        date);                         {returned date/time descriptor}

      time_sys.year := date.year;      {fill in system time descriptor}
      time_sys.month := date.month + 1;
      time_sys.day_week := sys_date_dayofweek (date);
      time_sys.day := date.day + 1;
      time_sys.hour := date.hour;
      time_sys.minute := date.minute;
      time_sys.second := date.second;
      time_sys.msec := trunc (date.sec_frac * 1000.0);
      end
    ;


  sys_clock_to_sys := time_sys;
  end;
