{   System-independent routines that manipulate Cognivision clock descriptors.
*
*   The system-dependent clock routines are in SYS_CLOCK_SYS.PAS.
}
module sys_clock;
define sys_clock_add;
define sys_clock_compare;
define sys_clock_from_fp_abs;
define sys_clock_from_fp_rel;
define sys_clock_sub;
define sys_clock_to_fp2;
%include 'sys2.ins.pas';

const
  mask = 16#3FFFFFFF;                  {mask for valid bits in LOW/SEC/HIGH fields}
{
***************************************************
*
*   Local subroutine SEC_CLOCK (S, HIGH, SEC, LOW)
*
*   Convert a floating point seconds value to the HIGH, SEC, and LOW fields
*   of a clock descriptor.
}
procedure sec_clock (
  in      s: sys_fp2_t;                {input floating point seconds value}
  out     high, sec, low: sys_int_conv32_t); {values for fields in clock descriptor}
  val_param;

var
  f: sys_fp2_t;                        {local copy of FP time value}
  neg: boolean;                        {TRUE when time value is negative}
  c: 0..1;                             {carry to next higher field}

begin
  if s >= 0.0
    then begin                         {input value is positive}
      f := s / 1073741824.0;
      neg := false;
      end
    else begin                         {input value is negative}
      f := -s / 1073741824.0;
      neg := true;
      end
    ;
{
*   F is scaled to contain the value for the HIGH field.
}
  high := trunc(f);                    {get HIGH field value}
  f := (f - high) * 1073741824.0;      {remove HIGH part, scale to SEC part}
  sec := trunc(f);                     {get SEC field value}
  f := (f - sec) * 1073741824.0;       {remove SEC part, scale to LOW part}
  low := trunc(f);                     {get LOW field value}

  if neg then begin                    {need to flip sign of clock value ?}
    low := ((~low) & mask) + 1;
    c := rshft(low, 30);               {save carry bit for next field}
    low := low & mask;                 {mask off carry bit}

    sec := ((~sec) & mask) + c;
    c := rshft(sec, 30);               {save carry bit for next field}
    sec := sec & mask;                 {mask off carry bit}

    high := ((~high) & mask) + c;
    high := high & mask;               {carry bits get lost}
    end;
  end;
{
***************************************************
*
*   Function SYS_CLOCK_ADD (CLOCK1, CLOCK2)
*
*   Return the sum of the two clock values.  At least one of the values must
*   be relative.
}
function sys_clock_add (               {add two clock values}
  in      clock1, clock2: sys_clock_t) {two clock values to add, at least one rel}
  :sys_clock_t;                        {resulting clock value}
  val_param;

var
  low, sec: sys_int_conv32_t;          {local copies of returned field values}
  c: 0..1;                             {carry value to next higher field}

begin
  if clock1.rel and clock2.rel
    then begin                         {both input values are relative}
      sys_clock_add.rel := true;
      end
    else begin                         {at least one input value is absolute}
      if (not clock1.rel) and (not clock2.rel) then begin {both values absolute ?}
        sys_message_bomb ('sys', 'clock_abs_both_add', nil, 0);
        end;
      sys_clock_add.rel := false;
      end
    ;

  low := clock1.low + clock2.low;      {make raw LOW field value}
  c := rshft(low, 30);                 {save carry, if any}
  sys_clock_add.low := low & mask;

  sec := clock1.sec + clock2.sec + c;  {make raw SEC field value}
  c := rshft(sec, 30);                 {save carry, if any}
  sys_clock_add.sec := sec & mask;

  sys_clock_add.high :=
    (clock1.high + clock2.high + c) & mask;
  end;
{
***************************************************
*
*   Function SYS_CLOCK_COMPARE (CLOCK1, CLOCK2)
*
*   Compare two clock values.  The clock values must be either both relative
*   or both absolute.  The possible returned values are:
*
*   SYS_COMPARE_LT_K  -  CLOCK1 is less than or before CLOCK2.
*
*   SYS_COMPARE_EQ_K  -  CLOCK1 is equal to CLOCK2.
*
*   SYS_COMPARE_GT_K  -  CLOCK1 is greater than or after CLOCK2.
}
function sys_clock_compare (           {compare two clock values}
  in      clock1: sys_clock_t;         {first clock value}
  in      clock2: sys_clock_t)         {second clock value}
  :sys_compare_k_t;                    {less / equal / greater comparison result}
  val_param;

var
  h1, h2: sys_int_conv32_t;            {sign-extended copies of HIGH fields}

begin
  if clock1.rel <> clock2.rel then begin {not both relative or both absolute ?}
    sys_message_bomb ('sys', 'clock_compare_relabs', nil, 0);
    end;

  if (clock1.high & 16#20000000) = 0   {make sign-extended CLOCK1.HIGH}
    then h1 := clock1.high             {value is positive}
    else h1 := clock1.high ! ~mask;    {value is negative}

  if (clock2.high & 16#20000000) = 0   {make sign-extended CLOCK2.HIGH}
    then h2 := clock2.high             {value is positive}
    else h2 := clock2.high ! ~mask;    {value is negative}

  if h1 = h2
    then begin
      if clock1.sec = clock2.sec
        then begin
          if clock1.low = clock2.low
            then begin
              sys_clock_compare := sys_compare_eq_k;
              end
            else begin
              if clock1.low > clock2.low
                then sys_clock_compare := sys_compare_gt_k
                else sys_clock_compare := sys_compare_lt_k;
              end
            ;
          end
        else begin
          if clock1.sec > clock2.sec
            then sys_clock_compare := sys_compare_gt_k
            else sys_clock_compare := sys_compare_lt_k;
          end
        ;
      end
    else begin
      if h1 > h2
        then sys_clock_compare := sys_compare_gt_k
        else sys_clock_compare := sys_compare_lt_k;
      end
    ;
  end;
{
***************************************************
*
*   Function SYS_CLOCK_FROM_FP_ABS (SEC)
*
*   Convert floating point seconds to an absolute clock value.  Time
*   0.0 is the start of 1 January 2000.  Positive values indicate a later
*   time.
}
function sys_clock_from_fp_abs (       {convert FP seconds to absolute clock value}
  in      s: sys_fp2_t)                {input in seconds}
  :sys_clock_t;                        {returned clock descriptor}
  val_param;

var
  low, sec, high: sys_int_conv32_t;    {local copies of returned fields}

begin
  sec_clock (s, high, sec, low);

  sys_clock_from_fp_abs.low := low;    {pass back final clock descriptor}
  sys_clock_from_fp_abs.sec := sec;
  sys_clock_from_fp_abs.high := high;
  sys_clock_from_fp_abs.rel := false;
  end;
{
***************************************************
*
*   Function SYS_CLOCK_FROM_FP_REL (SEC)
*
*   Convert floating point seconds to a relative clock value.  SEC may be
*   signed.
}
function sys_clock_from_fp_rel (       {convert FP seconds to relative clock value}
  in      s: sys_fp2_t)                {input in seconds}
  :sys_clock_t;                        {returned clock descriptor}
  val_param;

var
  low, sec, high: sys_int_conv32_t;    {local copies of returned fields}

begin
  sec_clock (s, high, sec, low);

  sys_clock_from_fp_rel.low := low;    {pass back final clock descriptor}
  sys_clock_from_fp_rel.sec := sec;
  sys_clock_from_fp_rel.high := high;
  sys_clock_from_fp_rel.rel := true;
  end;
{
***************************************************
*
*   Function SYS_CLOCK_SUB (CLOCK_START, CLOCK_DELTA)
*
*   Subtract the clock value in CLOCK_DELTA from CLOCK_START.  The two clock
*   values can be various combinations of absolute and relative as shown:
*
*   CLOCK_START   CLOCK_DELTA      result
*           abs           abs         rel
*           abs           rel         abs
*           rel           abs     illegal
*           rel           rel         rel
}
function sys_clock_sub (               {subtract one clock value from another}
  in      clock_start: sys_clock_t;    {starting clock value, may be absolute}
  in      clock_delta: sys_clock_t)    {amount to subtract, must be relative}
  :sys_clock_t;                        {time value after subtraction}
  val_param;

var
  low, sec: sys_int_conv32_t;          {local copies of returned fields}
  c: 0..1;                             {carry to next higher field}

begin
  if clock_start.rel
    then begin
      if clock_delta.rel
        then begin                     {rel rel}
          sys_clock_sub.rel := true;
          end
        else begin                     {rel abs}
          sys_message_bomb ('sys', 'clock_abs_subtract', nil, 0);
          end
        ;
      end
    else begin
      if clock_delta.rel
        then begin                     {abs rel}
          sys_clock_sub.rel := false;
          end
        else begin                     {abs abs}
          sys_clock_sub.rel := true;
          end
        ;
      end
    ;

  low := clock_start.low + (~clock_delta.low & mask) + 1;
  c := rshft(low, 30);                 {save carry bit}
  sys_clock_sub.low := low & mask;

  sec := clock_start.sec + (~clock_delta.sec & mask) + c;
  c := rshft(sec, 30);                 {save carry bit}
  sys_clock_sub.sec := sec & mask;

  sys_clock_sub.high := mask &
    (clock_start.high + ~clock_delta.high + c);
  end;
{
***************************************************
*
*   Function SYS_CLOCK_TO_FP2 (CLOCK)
*
*   Convert the value in a clock descriptor to floating point seconds.
}
function sys_clock_to_fp2 (            {convert clock to floating point seconds}
  in      clock: sys_clock_t)          {input clock descriptor}
  :sys_fp2_t;                          {output value in seconds}
  val_param;

begin
  if (clock.high & 16#20000000) = 0
    then begin                         {value is positive}
      sys_clock_to_fp2 :=
        (clock.low / 1073741824.0) +
        clock.sec +
        (clock.high * 1073741824.0);
      end
    else begin                         {value is negative}
      sys_clock_to_fp2 := -(
        ((1073741824 - clock.low) / 1073741824.0) +
        (1073741823 - clock.sec) +
        ((1073741823 - clock.high) * 1073741824.0)
        );
      end
    ;
  end;
