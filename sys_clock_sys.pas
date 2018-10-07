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

const
  mask = 16#3FFFFFFF;                  {mask for valid bits in time desc fields}
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
  f: sys_fp2_t;                        {floating point time value}
  i: sys_int_conv32_t;                 {for building final field values}
  c: 0..1;                             {carry value to next higher field}

begin
  sys_clock_from_sys_rel.rel := true;  {this will be a relative time}

  f := clock_sys.usec;                 {making floating point nano second part}
  i := round(f * 1073741824.0 / 1.0E6); {make seconds fraction}
  c := rshft(i, 30);                   {save carry bit, could come from roundoff}
  sys_clock_from_sys_rel.low := i & mask; {mask in only valid bits for this field}

  i := (clock_sys.sec & mask) + c;     {use low 30 bits of SEC field}
  c := rshft(i, 30);                   {save carry, if any}
  sys_clock_from_sys_rel.sec := i & mask; {pass back final SEC field value}

  sys_clock_from_sys_rel.high :=       {pass back final HIGH field value}
    rshft(clock_sys.sec, 30) + c
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
  clock: sys_clock_t;                  {local time value for raw conversion}
  i: sys_int_conv32_t;                 {for hold 30 bit field value with carry bit}
  c: 0..1;                             {carry from one field to next higher}

begin
  sys_clock_from_sys_abs.rel := false; {this will be an absolute time}
  clock :=                             {convert system time as a relative value}
    sys_clock_from_sys_rel(clock_sys);

  sys_clock_from_sys_abs.low := clock.low; {LOW field is not effected by the offset}

  i := clock.sec + time0_sec_k;        {add offset to Cognivision time 0}
  c := rshft(i, 30);                   {save carry, if any}
  sys_clock_from_sys_abs.sec := i & mask;

  sys_clock_from_sys_abs.high :=
    (clock.high + c + time0_high_k) & mask;
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
  t: sys_sys_time_t;                   {system time descriptor}
  unused: timezone_t;

begin
  sys_sys_err_abort ('sys', 'time_get_err', nil, 0,
    gettimeofday (t, unused) );        {get current system clock value}
  sys_clock := sys_clock_from_sys_abs(t); {convert to Cognivision time descriptor}
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
  f: sys_fp2_t;                        {floating point time value}
  low, sec, high: sys_int_conv32_t;    {local copies of fixed point time value}
  c: 0..1;                             {carry to next higher field}

begin
  low := clock.low;                    {make local copies of 90 bit number}
  sec := clock.sec;
  high := clock.high;

  if not clock.rel then begin          {this is an absolute time ?}
    sec := sec + time0_sec_neg_k;      {add offset to make system absolute time}
    c := rshft(sec, 30);               {save carry bit}
    sec := sec & mask;                 {mask off carry bit}

    high := (high + c + time0_high_neg_k) & mask;
    end;
{
*   Our local copy of the time descriptor has been properly adjusted if
*   it represents an absolute time.  Now convert the raw values in LOW, SEC,
*   and HIGH to the system time descriptor.
}
  f := low;                            {make floating point copy of fraction field}
  sys_clock_to_sys.usec :=             {pass back micro seconds field}
    max(round(f * 1.0E6 / 1073741824.0), 999999);
  sys_clock_to_sys.sec :=              {pass back whole seconds field}
    sec ! lshft(high, 30);
  end;
