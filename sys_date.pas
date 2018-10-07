{   Collection of routines that convert to/from date descriptors.
}
module sys_date;
define sys_date_to_sec;
define sys_date_from_sec;
define sys_clock_from_date;
define sys_clock_to_date;
define sys_date_clean;
define sys_date_dayofweek;
define sys_date_dayofyear;
%include 'sys2.ins.pas';

const
  day_year = 365;                      {days in normal year}
  day_years4 = (day_year * 4) + 1;     {days in normal group of 4 years}
  day_years400 = (day_years4 * 100) - 3; {days in group of 400 years}

  dweek_year = day_year mod 7;         {day of week advance each year}
  dweek_years4 = day_years4 mod 7;     {day of week advance each 4 years}
  dweek_years400 = day_years400 mod 7; {day of week advance each 400 years}

  dweek0 = 6;                          {day of week at time 0, 0 = Sunday, 6 = Sat}

  hour_day = 24;                       {hours in one day}

  sec_min = 60.0;
  sec_hour = sec_min * 60.0;
  sec_day = sec_hour * 24.0;
  sec_year = sec_day * 365.0;
  sec_years4 = (sec_year * 4.0) + sec_day;
  sec_years400 = (sec_years4 * 100.0) - (sec_day * 3.0);

var
  month_days:                          {length of each month in days}
    array[0..11] of sys_int_machine_t :=
    [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  month_days_ofs:                      {days from year start for each month}
    array[0..11] of sys_int_machine_t :=
    [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];

type
  dstype_k_t = (                       {daylight savings time trigger strategies}
    dstype_dmon_k,                     {at given day within given month}
    dstype_dwmon_k);                   {at Nth occurence of weekday withing month}

  daysave_trig_t = record              {daylight savings time trigger descriptor}
    dstype: dstype_k_t;                {trigger type}
    case dstype_k_t of                 {different data for each trigger type}
dstype_dmon_k: (                       {trigger at set day within set month}
      dmon_mon: sys_int_machine_t;     {month offset from start of year}
      dmon_day: sys_int_machine_t;     {day offset from start of month}
      dmon_min: sys_int_machine_t;     {minute offset from start of day}
      );
dstype_dwmon_k: (                      {trigger Nth occurence of specific weekday}
      dwmon_mon: sys_int_machine_t;    {month offset from start of year}
      dwmon_n: sys_int_machine_t;      {Nth occurrence, >0 from start, <0 from end}
      dwmon_dweek: sys_int_machine_t;  {day of week, 0 = Sunday}
      dwmon_min: sys_int_machine_t;    {minute offset from start of day}
      );
    end;

  month_info_t = record                {internal data about a particular month}
    block: sys_int_machine_t;          {400-year block number, 2000 starts block 0}
    year_in_block: sys_int_machine_t;  {year number within block}
    days_in_month: sys_int_machine_t;  {number of days in the month}
    end;
{
********************************************************************************
*
*   Local function LEAP_YEAR (YEAR)
*
*   Return TRUE if YEAR is a leap year (February has one more day than indicated
*   in MONTH_DAYS array).  Return FALSE otherwise.
}
function leap_year (
  in      year: sys_int_machine_t)     {year to test}
  :boolean;                            {TRUE if YEAR is a leap year}
  val_param; internal;

begin
  leap_year :=
    ((year mod 4) = 0) and (           {all leap years are divisible by four}
      (not ((year mod 100) = 0)) or    {centuries aren't leap years}
      ((year mod 400) = 0)             {every fourth century is a leap year anyway}
      )
    ;
  end;
{
********************************************************************************
*
*   Local subroutine MONTH_INFO (YEAR, MONTH, INFO)
*
*   Get information about a month.  The month is identified by the year and
*   month within that year.  MONTH must be in the range 0-11.
}
procedure month_info (
  in      year: sys_int_machine_t;     {number of year containing the month}
  in      month: sys_int_machine_t;    {0-11 month number within the year}
  out     info: month_info_t);         {returned info about the month}
  val_param; internal;

begin
{
*   Set BLOCK and YEAR_IN_BLOCK values.
}
  info.year_in_block := year - 2000;   {make year relative to T0}
  info.block :=                        {number of whole 400-year info.blocks}
    info.year_in_block div 400;
  info.year_in_block :=                {remove whole 400-year info.blocks}
    info.year_in_block - (info.block * 400);
  if info.year_in_block < 0 then begin {make sure YEAR_IN_BLOCK is a positive offset}
    info.year_in_block := info.year_in_block + 400;
    info.block := info.block - 1;
    end;
{
*   Set DAYS_IN_MONTH to the number of days in this month.  This mostly
*   comes from the MONTH_DAYS array, except that February has an
*   extra day in leap years.
}
  info.days_in_month := month_days[month]; {days in month when not a leap year}
  if (month = 1) and then leap_year(year)
    then info.days_in_month := info.days_in_month + 1;
  end;
{
********************************************************************************
*
*   Local function AFTER (DATE, TRIG)
*
*   Return TRUE if DATE represents a time at or after the trigger time
*   specified in TRIG.  DATE is assumed to be normalized.
}
function after (                       {check for at or past trigger time}
  in      date: sys_date_t;            {date/time to check}
  in      trig: daysave_trig_t)        {trigger time to compare DATE against}
  :boolean;                            {TRUE if DATE at or after TRIG}
  val_param;

var
  dw: sys_int_machine_t;               {scratch day of week}
  day: sys_int_machine_t;              {scratch day within month}
  i: sys_int_machine_t;                {scratch integer}
  trig_min: sys_int_machine_t;         {trigger offset from day start in minutes}

label
  at_day, yes, no;

begin
  case trig.dstype of                  {what kind of trigger is this ?}
{
**********
*
*   Trigger is at specific day within specific month.
}
dstype_dmon_k: begin
  if date.month < trig.dmon_mon then goto no;
  if date.month > trig.dmon_mon then goto yes;
  if date.day < trig.dmon_day then goto no;
  if date.day > trig.dmon_day then goto yes;
  trig_min := trig.dmon_min;
  goto at_day;
  end;
{
**********
*
*   Trigger is at Nth occurrence of specific weekday from either start or
*   end of month.
}
dstype_dwmon_k: begin
  if date.month < trig.dwmon_mon then goto no;
  if date.month > trig.dwmon_mon then goto yes;
  dw := sys_date_dayofweek (date);     {get day of week indicated by DATE}
  dw := dw - date.day;                 {make day of week for first day in month}
  day := trig.dwmon_dweek - dw;        {offset into month of first occurrence}
  day := day mod 7;                    {mormalize it}
  if day < 0 then day := day + 7;
  if trig.dwmon_n >= 0
    then begin                         {counting occurrences from start of month}
      day := day + 7*(trig.dwmon_n - 1); {make trigger day within month}
      end
    else begin                         {counting occurrences from end of month}
      i := month_days[date.month];     {init days in this month}
      if (date.month = 1) and then leap_year(date.year) then begin {leap February ?}
        i := i + 1;                    {February has extra day in leap years}
        end;
      i := (i - 1 - day);              {offset of last day from first occurrence day}
      i := (i div 7) + 1;              {number of occurrences this month}
      day := day + 7*(i + trig.dwmon_n); {make trigger day within month}
      end
    ;                                  {DAY is trigger day within this month}
  if date.day < day then goto no;
  if date.day > day then goto yes;
  trig_min := trig.dwmon_min;
  goto at_day;
  end;
{
**********
*
*   Unrecognized trigger type.
}
otherwise
    sys_message_bomb ('sys', 'date_trig_unexp', nil, 0);
    end;
{
*   We are at the trigger day.  TRIG_MIN is the minutes offset from the start
*   of the day for the trigger.
}
at_day:
  if (date.hour * 60 + date.minute) < trig_min
    then goto no;
{
*   We are definately at or after the trigger time.
}
yes:
  after := true;
  return;
{
*   We are definately before the trigger time.
}
no:
  after := false;
  end;
{
********************************************************************************
*
*   Local subroutine DAYSAVE_CHECK (DATE, HWEST, DAYON)
*
*   Determines whether daylight savings time is in effect for the raw time and
*   timezone ID specified in DATE.  HWEST is the hours west adjustment for the
*   timezone at the indicated time.  DAYON is returned indicating whether
*   daylight savings time is in effect at the time.
*
*   DATE is not altered.
}
procedure daysave_check (              {check for daylight savings time in effect}
  in      date: sys_date_t;            {time, timezone, and daysave strategy to check}
  out     hwest: real;                 {hours west of CUT for time in the time fields}
  out     dayon: boolean);             {daylight savings adjustment is in effect}
  val_param; internal;

var
  hw: real;                            {base hours west for the time zone}
  hwd: real;                           {hours west offset when daysave applied}
  trig_day: daysave_trig_t;            {when to switch to daylight savings time}
  trig_std: daysave_trig_t;            {when to switch back to standard time}

begin
  dayon := false;                      {init to daylight savings not in effect}
  hwd := -1.0;                         {default hours west offset when daysave applied}
{
*   Set HW to the base offset for the timezone.
}
  case date.tzone_id of                {which timezone is this ?}
sys_tzone_cut_k: begin                 {coordinated univ time}
      hw := 0.0;
      hwd := 0.0;                      {never has daysave offset}
      end;
sys_tzone_east_usa_k: begin            {USA Eastern timezone}
      hw := 5.0;
      end;
sys_tzone_cent_usa_k: begin            {USA Central timezone}
      hw := 6.0;
      end;
sys_tzone_mount_usa_k: begin           {USA Mountain timezone}
      hw := 7.0;
      end;
sys_tzone_pacif_usa_k: begin           {USA Pacific timezone}
      hw := 8.0;
      end;
otherwise                              {unknown timezone}
    hw := date.hours_west;
    if date.daysave_on then begin      {daysave offset already applied in DATE ?}
      hw := hw - hwd;                  {make base timezone offset}
      end;
    end;

  hwest := hw;                         {init returned value for no daysave applied}
  if hwd = 0.0 then return;            {this timezone has no daysave offset ?}

  case date.daysave of                 {what is daylight savings handling request ?}
sys_daysave_no_k: return;              {don't apply daylight savings time}
sys_daysave_appl_k: ;                  {apply if otherwise appropriate}
otherwise
    sys_message_bomb ('sys', 'daysave_unexp', nil, 0);
    end;
{
*   Get the daylight savings on and off trigger times for this timezone.
*
*   This code defaults all to the USA standard.  Other strategies have not been
*   implemented yet.  Different trigger points based on the year have not been
*   implemented.  All these, when implemented, would go in this section.
}
  trig_day.dstype := dstype_dwmon_k;   {trigger on Nth occurrence of weekday}
  trig_day.dwmon_mon := 3;             {April}
  trig_day.dwmon_n := 1;               {first occurrence}
  trig_day.dwmon_dweek := 0;           {Sunday}
  trig_day.dwmon_min := 120;           {2:00 hours}

  trig_std.dstype := dstype_dwmon_k;   {trigger on Nth occurrence of weekday}
  trig_std.dwmon_mon := 9;             {October}
  trig_std.dwmon_n := -1;              {last occurrence}
  trig_std.dwmon_dweek := 0;           {Sunday}
  trig_std.dwmon_min := 120;           {2:00 hours}
{
*   Check for within the daylight savings time window.  Adjust HWEST and DAYON
*   accordingly.
}
  if                                   {not in daylight time right now ?}
      (not after (date, trig_day)) or  {before daylight time start ?}
      after (date, trig_std)           {after daylight time end ?}
    then return;                       {return with base timezone values}

  hwest := hw + hwd;                   {return adjusted hours west}
  dayon := true;                       {indicate daysave adjustment applied to HWEST}
  end;
{
********************************************************************************
*
*   Subroutine SYS_DATE_TO_SEC (DATE, S)
*
*   Return the offset in seconds from the reference time to the time
*   indicated by DATE.  The reference time is the start of year 2000.
}
function sys_date_to_sec (             {return absolute seconds from a date}
  in      date: sys_date_t)            {descriptor for the input date}
  :double;                             {returned absolute seconds value}
  val_param;

var
  d: sys_date_t;                       {local editable copy of the date}
  minfo: month_info_t;                 {info about the current month}
  i: sys_int_machine_t;                {scratch integer}
  s: double;                           {scratch seconds value}

begin
  sys_date_clean (date, d);            {make local cleaned copy of date in D}
  month_info (d.year, d.month, minfo); {get info about this month}
{
*   The time values in D have been sanitized.  Now compute the seconds offset
*   from zero reference time (start of year 2000).
}
  s :=                                 {seconds into year, assuming not a leap year}
    d.sec_frac + d.second +
    (d.minute * sec_min) +
    ((d.hour + d.hours_west) * sec_hour) +
    ((d.day + month_days_ofs[d.month]) * sec_day);

  if                                   {did we miss the leap day ?}
      (d.month > 1) and (              {past February ?}
        (minfo.year_in_block = 0) or   {first year in block is always a leap year}
        ( ((minfo.year_in_block mod 4) = 0) and then {year is multiple of four ?}
          ((minfo.year_in_block mod 100) <> 0) {not first year in a century ?}
          )
        )
      then begin
    s := s + sec_day;                  {add in seconds for the leap day}
    end;

  i := (minfo.year_in_block + 3) div 4; {init whole leap years since block start}
  i := i -                             {adjust for century years aren't leap years}
    (minfo.year_in_block - 1) div 100;
  s := s + (i * sec_day);              {add in all the leap days since block start}

  s := s + (minfo.year_in_block * sec_year); {add in years since block start}
  sys_date_to_sec :=                   {pass back final value}
    s + (minfo.block * sec_years400);  {add offset to start of this 400-year block}
  end;
{
********************************************************************************
*
*   Subroutine SYS_DATE_FROM_SEC (S, TZONE, HOURS_WEST, DAYSAVE, DATE)
*
*   Create a complete date descriptor given an absolute time in seconds
*   and other information.
}
procedure sys_date_from_sec (
  in      s: double;                   {input time in absolute seconds}
  in      tzone: sys_tzone_k_t;        {time zone to convert into}
  in      hours_west: real;            {for OTHER tz, hours west of CUT without DST}
  in      daysave: sys_daysave_k_t;    {daylight savings time strategy}
  out     date: sys_date_t);           {completely filled in date descriptor}
  val_param;

var
  sec: double;                         {remaining seconds to take into account}
  d: double;                           {scratch FP value}
  hw: real;                            {scratch hours west}
  i, j: sys_int_machine_t;             {scratch integers}
  block: sys_int_machine_t;            {number of 400-year block}

begin
  date.tzone_id := tzone;              {save time zone ID}
  date.hours_west := hours_west;       {set timezone hours west of coor univ time}
  date.daysave := daysave;             {init daylight savings time strategy}
  date.daysave_on := false;            {init to daylight savings time not in effect}

  sec := s - (date.hours_west * sec_hour); {offset to raw time zone}
{
*   Init YEAR to the first year of the 400-year block containing this time.
*   SEC will be the non-negative offset from the start of that year.
}
  d := sec / sec_years400;
  if d >= 0.0
    then begin                         {abs time value is positive}
      block := trunc(d);
      end
    else begin                         {abs time value is negative}
      block := -trunc(-d) - 1;
      end
    ;
  date.year := 2000 + (block * 400);   {make starting year number of block}
  sec := sec - (block * sec_years400); {make seconds offset into block}
{
*   Take first pass at finding YEAR, MONTH, and DAY.
}
  i := trunc(sec / sec_year);          {num of whole years, assuming no leap years}
  date.year := date.year + i;
  sec := sec - (i * sec_year);         {remove whole year offsets}
  j := (i + 3) div 4;                  {number of leap years skipped over}
  j := j - ((i - 1) div 100);          {century years aren't leap years}
  date.month := 0;
  date.day := -j;                      {compensate for skipped leap days}

  i := trunc(sec /sec_day);            {number of whole days left in SEC}
  date.day := date.day + i;            {add on number of whole days}
  sec := sec - (i * sec_day);          {remove whole days from SEC}
{
*   YEAR has been initialized, and MONTH has been set to January (0).
*   Additional whole day offsets due to the offset within the year, and
*   due to skipping leap days is in DAY.  Now adjust the YEAR/MONTH forward
*   or backwards so that DAY ends up within the current month.
}
  if date.day >= 0
    then begin                         {move months forward, if at all}
      i := month_days[date.month];     {make days in this month}
      if (date.month = 1) and then leap_year(date.year)
        then i := i + 1;
      while date.day >= i do begin     {loop forward by months}
        date.day := date.day - i;      {make day within next month}
        date.month := date.month + 1;
        if date.month >= 12 then begin {just wrapped to next year ?}
          date.month := date.month - 12;
          date.year := date.year + 1;
          end;
        i := month_days[date.month];   {make days in this month}
        if (date.month = 1) and then leap_year(date.year)
          then i := i + 1;
        end;                           {back and test with this new month}
      end
    else begin                         {move months backward}
      repeat
        date.month := date.month - 1;  {go to previous month}
        if date.month < 0 then begin   {wrapped to previous year ?}
          date.month := date.month + 12;
          date.year := date.year - 1;
          end;
        i := month_days[date.month];   {make days in this new month}
        if (date.month = 1) and then leap_year(date.year)
          then i := i + 1;
        date.day := date.day + i;      {update day offset to new month}
        until date.day >= 0;           {back until day is within the month}
      end
    ;
{
*   YEAR, MONTH, and DAY have been initialized.  SEC contains the remaining
*   offset into this day in seconds.
}
  date.hour := trunc(sec / sec_hour);
  sec := sec - (date.hour * sec_hour);

  date.minute := trunc(sec / sec_min);
  sec := sec - (date.minute * sec_min);

  date.second := trunc(sec);
  date.sec_frac := sec - date.second;
{
*   The time in DATE is for the standard time of the timzone.  Modify it for
*   daylight savings time if appropriate.  If so, the time is changed and the
*   HOURS_WEST field updated accordingly.
}
  daysave_check (date, hw, date.daysave_on); {get daylight savings state}
  if not date.daysave_on then return;  {daylight savings not in effect ?}

  sec := (date.hours_west - hw) * sec_hour; {make offset to add in seconds}
  date.hours_west := hw;               {set adjusted timezone offset in effect}
  date.sec_frac := date.sec_frac + sec; {add the offset}
  sys_date_clean (date, date);         {sanitize all the fields after the adjustment}
  end;
{
********************************************************************************
*
*   Function SYS_CLOCK_FROM_DATE (DATE)
*
*   Return a clock descriptor given a date descriptor.
}
function sys_clock_from_date (         {return absolute clock value from a date}
  in      date: sys_date_t)            {input date descriptor}
  :sys_clock_t;                        {clock value resulting from the input date}
  val_param;

begin
  sys_clock_from_date :=
    sys_clock_from_fp_abs( sys_date_to_sec(date) );
  end;
{
********************************************************************************
*
*   Subroutine SYS_CLOCK_TO_DATE (CLOCK, TZONE, HOURS_WEST, DAYSAVE, DATE)
*
*   Completely fill in a date descriptor, given a clock value and other
*   information.  CLOCK is the clock value that uniquely identifies the
*   point in time.  TZONE identifies the time zone of the date to create.
*   It is one of the values SYS_TZONE_xxx_K.  This explicitly identifies
*   a time zone or specifies OTHER.  HOURS_WEST indicates the number of
*   hours west of CUT the time zone is when no daylight savings time is
*   applied.  This parameter is ignored, except when TZONE is set to
*   SYS_TZONE_OTHER_K.  DAYSAVE indicates the daylight savings time
*   strategy for the time zone.  It must have one of the values
*   SYS_DAYSAVE_xxx_K.  DATE is the returned date descriptor.  All fields
*   in DATE are set and will be within the normal range.
}
procedure sys_clock_to_date (          {make expanded date from absolute clock value}
  in      clock: sys_clock_t;          {input clock value, must be absolute}
  in      tzone: sys_tzone_k_t;        {time zone to convert into}
  in      hours_west: real;            {for OTHER tz, hours west of CUT without DST}
  in      daysave: sys_daysave_k_t;    {daylight savings time strategy}
  out     date: sys_date_t);           {completely filled in date descriptor}
  val_param;

begin
  sys_date_from_sec (
    sys_clock_to_fp2(clock),
    tzone,
    hours_west,
    daysave,
    date);
  end;
{
********************************************************************************
*
*   Subroutine SYS_DATE_CLEAN (DATE_IN, DATE_OUT)
*
*   DATE_OUT will be a "cleaned" version of DATE_IN.  DATE_IN may contain
*   field values that are out of range.  This may be the result of doing
*   calculations on the field values.  For example, a program may want to
*   find tomorrow's date by adding one day to a time descriptor for the
*   current time.  This may cause the date field to indicate a calendar date
*   past the end of the month.  SYS_DATE_CLEAN will resolve such out of
*   range values, and convert them to the appropriate real date.
*
*   The HOURS_WEST offset from coordinated universal time is adjusted for
*   daylight savings time if all of the following conditions are met:
*
*     1 - DAYSAVE is set to SYS_DAYSAVE_APPL_K, meaning to apply daylight
*         savings time when appropriate.
*
*     2 - The cleaned time falls within the daylight savings region for the time
*         zone.
}
procedure sys_date_clean (             {wrap over and underflowed fields in date desc}
  in      date_in: sys_date_t;         {input date that may have out of range fields}
  out     date_out: sys_date_t);       {fixed date, may be same variable as DATE_IN}
  val_param;

var
  d: sys_date_t;                       {date descriptor that is edited}
  i: sys_int_machine_t;                {scratch integer}
  minfo: month_info_t;                 {info about a particular month}

begin
  d := date_in;                        {make local editable copy of the input date}
{
*   Adjust SEC_FRAC.
}
  i := trunc(d.sec_frac);              {make whole seconds}
  d.second := d.second + i;
  d.sec_frac := d.sec_frac - i;
  if d.sec_frac < 0.0 then begin
    d.second := d.second - 1;
    d.sec_frac := d.sec_frac + 1.0;
    end;
{
*   Adjust SECOND to be 0-59.
}
  i := d.second div 60;
  d.minute := d.minute + i;
  d.second := d.second - (i * 60);
  if d.second < 0 then begin
    d.minute := d.minute - 1;
    d.second := d.second + 60;
    end;
{
*   Adjust MINUTE to be 0-59.
}
  i := d.minute div 60;
  d.hour := d.hour + i;
  d.minute := d.minute - (i * 60);
  if d.minute < 0 then begin
    d.hour := d.hour - 1;
    d.minute := d.minute + 60;
    end;
{
*   Adjust HOUR to be 0-23.
}
  i := d.hour div hour_day;
  d.day := d.day + i;
  d.hour := d.hour - (i * hour_day);
  if d.hour < 0 then begin
    d.day := d.day - 1;
    d.hour := d.hour + hour_day;
    end;
{
*   Adjust MONTH to be 0-11.
}
  i := d.month div 12;
  d.year := d.year + i;
  d.month := d.month - (i * 12);
  if d.month < 0 then begin
    d.year := d.year - 1;
    d.month := d.month + 12;
    end;
{
*   All the year thru seconds fields have been adjusted except for DAY.  This
*   can only be done knowing the month and year since the number of days vary
*   according to month and year.
}
  while d.day < 0 do begin             {go back whole months until in current month}
    d.month := d.month - 1;            {go back one month}
    if d.month < 0 then begin
      d.year := d.year - 1;
      d.month := d.month + 12;
      end;
    month_info (d.year, d.month, minfo); {get info about this month}
    d.day := d.day + minfo.days_in_month; {adjust days for going back to this month}
    end;

  while true do begin                  {go forward months until day is within curr month}
    month_info (d.year, d.month, minfo); {get info about this month}
    if d.day < minfo.days_in_month then exit; {day is within this month, all done ?}
    d.month := d.month + 1;            {go forwards one month}
    d.day := d.day - minfo.days_in_month;
    if d.month > 11 then begin
      d.year := d.year + 1;
      d.month := d.month - 12;
      end;
    end;                               {back to check day is within this new month}
{
*   Adjust HOURS_WEST for daylight savings time if appropriate.
}
  daysave_check (                      {apply daylight savings adjustment, if any}
    d, d.hours_west, d.daysave_on);

  date_out := d;                       {returned cleaned date descriptor}
  end;
{
********************************************************************************
*
*   Function SYS_DATE_DAYOFWEEK (DATE)
*
*   Return the number of the day within the week.  0 is for Sunday, 6 is for
*   Saturday.
}
function sys_date_dayofweek (          {return number of day within week}
  in      date: sys_date_t)            {descriptor of a complete date}
  :sys_int_machine_t;                  {0-6 day of week, Sunday = 0}
  val_param;

var
  info: month_info_t;                  {info about this month}
  dweek: sys_int_machine_t;            {day of week, 0 = Sunday, 6 = Saturday}
  years4: sys_int_machine_t;           {4 year blocks since start of 400 year block}
  i: sys_int_machine_t;

begin
  month_info (date.year, date.month, info); {get info about this month}

  dweek :=                             {make day of week for 400 year block start}
    dweek0 +                           {day of week at block 0 start}
    dweek_years400 * info.block;       {day of week offset to block start}
  years4 := info.year_in_block div 4;  {number of 4 year group within block}
  dweek := dweek +                     {account for 4 year groups since within block}
    years4 * dweek_years4;
  dweek := dweek -                     {account for centuries that aren't leap years}
    info.year_in_block div 100;
{
*   DWEEK is the unnormalized day of the week for the start of our 4 year group.
}
  i := info.year_in_block - years4 * 4; {whole years into our 4 year group}
  if i > 0 then begin                  {at least one whole year since group start ?}
    dweek := dweek + i * dweek_year;   {account for whole years since group start}
    if leap_year (date.year - i) then begin {first year in group has extra day ?}
      dweek := dweek + 1;
      end;
    end;

  dweek := dweek +                     {add in days since start of year}
    date.day + month_days_ofs[date.month];
  if
      (date.month > 1) and then        {past the end of February ?}
      leap_year (date.year)            {this is a leap year ?}
      then begin
    dweek := dweek + 1;                {add extra day for leap year}
    end;

  dweek := dweek mod 7;                {normalize to 0-6 range}
  if dweek < 0 then dweek := dweek + 7;

  sys_date_dayofweek := dweek;         {pass back 0-6 day of the week}
  end;
{
********************************************************************************
*
*   Function SYS_DATE_DAYOFYEAR (DATE)
*
*   Return the day offset from the start of the year.  The first day (1 Janaury)
*   is returned as 0.  The function value is the Julian date - 1.
}
function sys_date_dayofyear (          {return number of day within year}
  in      date: sys_date_t)            {descriptor of a complete date}
  :sys_int_machine_t;                  {0-365 day offset from year start}
  val_param;

var
  n: sys_int_machine_t;                {day offset accumulator}

begin
  n := date.day + month_days_ofs[date.month]; {make offset assuming no leap year}
  if
      (date.month > 1) and then        {past the end of February ?}
      leap_year (date.year)            {this is a leap year ?}
      then begin
    n := n + 1;                        {add extra day for leap year}
    end;
  sys_date_dayofyear := n;
  end;
