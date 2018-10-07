{   Subroutine SYS_TIMEZONE_HERE (TZONE, HOURS_WEST, DAYSAVE)
*
*   Return information about the current time zone.  TZONE is the time zone ID.
*   HOURS_WEST is the number of hours this standard time zone is west of
*   coordinated universal time when daylight savings time is not applied.
*   DAYSAVE is the daylight savings time strategy for this time zone.
*
*   The returned values are in the correct format to be directly passed to
*   SYS_CLOCK_TO_DATE to convert to a date in the local time zone.
}
module sys_timezone_here;
define sys_timezone_here;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
%include 'string.ins.pas';

procedure sys_timezone_here (          {get information about the current time zone}
  out     tzone: sys_tzone_k_t;        {time zone ID}
  out     hours_west: real;            {hours west of CUT without daylight save time}
  out     daysave: sys_daysave_k_t);   {daylight savings time strategy}
  val_param;

var
  zone: time_zone_info_t;              {system time zone info}
  opt: time_zone_k_t;                  {time zone options in effect}
  bias: win_long_t;                    {minutes to add to make coor univ time}
  name: string_var32_t;                {full standard time zone name from system}
  token: string_var32_t;               {token parsed from time zone name}
  p: string_index_t;                   {parse index}
  pick: sys_int_machine_t;             {number of entry picked from list}
  stat: sys_err_t;

label
  use_curr;

begin
  name.max := size_char(name.str);     {init local var string}
  token.max := size_char(token.str);

  opt := GetTimeZoneInformation (zone); {get info about current time zone}

  if ord(opt) = func_fail_k then begin {system call failed ?}
    sys_error_none (stat);             {init descriptor to indicate no error}
    stat.sys := GetLastError;          {set system error status}
    sys_error_print (stat, '', '', nil, 0);
    sys_message_bomb ('sys', 'timezone_get', nil, 0);
    end;

  if (zone.time_std.month = 0) or (zone.time_day.month = 0)
    then begin                         {not enough daylight savings info available ?}
      daysave := sys_daysave_no_k;
      end
    else begin                         {this time zone seems to have day save time}
      daysave := sys_daysave_appl_k;
      end
    ;
  hours_west := zone.bias_curr / 60.0; {init hours west of CUT for this timezone}

  case opt of                          {what time zone options are in effect}
time_zone_std_k: begin                 {we are currently within standard time}
      if zone.time_std.month = 0       {no standard time info available ?}
        then goto use_curr;
      bias := zone.bias_curr + zone.bias_std; {make current bias}
      end;
time_zone_day_k: begin                 {we are currently in daylight savings time}
      if (zone.time_std.month = 0) or (zone.time_day.month = 0)
        then goto use_curr;
      bias := zone.bias_curr + zone.bias_day; {make current bias}
      end;
otherwise                              {we don't know any more than just the bias}
use_curr:
    daysave := sys_daysave_no_k;       {don't try to apply day save time here}
    tzone := sys_tzone_other_k;        {unknown time zone}
    return;
    end;
{
*   BIAS is set to the bias we are currently set to.  ZONE.BIAS_CURR is the
*   generic bias for this time zone with no options applied.
}
  unicode_ascii (name, zone.name_std, sizeof(zone.name_std) div 2); {make var string}
  p := 1;                              {init parse index}
  string_token (name, p, token, stat); {parse first word from time zone name}
  string_upcase (token);               {make upper case for keyword matching}
  string_tkpick80 (token,              {pick name from list}
    'EASTERN CENTRAL MOUNTAIN PACIFIC'(0),
    pick);                             {number of entry picked from list}
  case pick of                         {which time zone name got picked ?}
1: tzone := sys_tzone_east_usa_k;
2: tzone := sys_tzone_cent_usa_k;
3: tzone := sys_tzone_mount_usa_k;
4: tzone := sys_tzone_pacif_usa_k;
otherwise
    tzone := sys_tzone_other_k;        {unknown time zone}
    daysave := sys_daysave_no_k;       {don't try to apply day save time here}
    hours_west := bias / 60.0;         {hours west of CUT currently using}
    end;
  end;
