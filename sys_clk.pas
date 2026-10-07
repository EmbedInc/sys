{   Implementation of "small" clock time formats.  These formats have lower
*   resolution and/or smaller range than the full SYS_CLOCK_T clock time, but
*   also require less storage.  These formats are intended for storage only.
*   Routines that perform actions on these formats are therefore not provided,
*   other than to convert to/from the full SYS_CLOCK_T format.
*
*   All the small clock time format data types are named SYS_CLKxxx_T.
}
module sys_clk;
define sys_clock_to_clksec32;
define sys_clock_from_clksec32;
define sys_clock_to_clkmin32;
define sys_clock_from_clkmin32;
%include 'sys2.ins.pas';
{
********************************************************************************
*
*   Convert a full system clock value to the CLKSEC32 format.
}
function sys_clock_to_clksec32 (       {abs clock value to CLKSEC32 format}
  in      clock: sys_clock_t)          {full clock value}
  :sys_clksec32_t;                     {returned time in CLKSEC32 format}
  val_param;

var
  clk: sys_clksec32_t;                 {clock value being built}
  ii: sys_int_conv32_t;                {scratch integer}

begin
  ii := rshft(clock.high, 29);         {extract sign bit}
  if ii <> 0 then begin                {before our time range ?}
    sys_clock_to_clksec32 := 0;        {return earliest representable time}
    return;
    end;

  ii := rshft(clock.high, 2);          {extract upper bits that must be 0}
  if ii <> 0 then begin                {after our time range ?}
    sys_clock_to_clksec32 := 16#FFFFFFFF; {return latest representable time}
    return;
    end;

  clk := clock.sec;                    {init with low 30 bits of result}
  ii := lshft(clock.high & 2#11, 30);  {get high 2 bits into place}
  clk := clk ! ii;                     {merge all 32 bits together}
  sys_clock_to_clksec32 := clk;        {return unsigned seconds since year 2000}
  end;
{
********************************************************************************
*
*   Function SYS_CLOCK_FROM_CLKSEC32 (CLK)
*
*   Convert from the absolute CLKSEC32 time format to the general clock format.
}
function sys_clock_from_clksec32 (     {CLKSEC32 time to absolute clock value}
  in      clk: sys_clksec32_t)         {input time in CLKSEC32 seconds format}
  :sys_clock_t;                        {returned clock descriptor}
  val_param;

var
  fp: sys_fp2_t;                       {high resolution FP time value}

begin
  fp := clk;                           {make high resolution FP seconds}
  sys_clock_from_clksec32 := sys_clock_from_fp_abs (fp);
  end;
{
********************************************************************************
*
*   Convert a full system clock value to the CLKSEC32 format.
}
function sys_clock_to_clkmin32 (       {abs clock value to CLKMIN32 format}
  in      clock: sys_clock_t)          {full clock value}
  :sys_clkmin32_t;                     {returned time in CLKMIN32 format}
  val_param;

var
  fp: sys_fp2_t;                       {high resolution FP time value}

begin
  fp := sys_clock_to_fp2 (clock);      {make high resolution seconds since 2000}
  fp := fp / 60.0;                     {convert to minutes}

  if fp < -2147483648.0 then begin     {before our time range ?}
    sys_clock_to_clkmin32 := 16#10000000; {return earliest representable time}
    return;
    end;
  if fp > 2147483647.0 then begin      {after our time range ?}
    sys_clock_to_clkmin32 := 16#7FFFFFFF; {return latest representable time}
    return;
    end;

  sys_clock_to_clkmin32 := round(fp);  {return unsigned minutes from start of 2000}
  end;
{
********************************************************************************
*
*   Function SYS_CLOCK_FROM_CLKMIN32 (CLK)
*
*   Convert from the absolute CLKMIN32 time format to the general clock format.
}
function sys_clock_from_clkmin32 (     {CLKMIN32 time to absolute clock value}
  in      clk: sys_clkmin32_t)         {input time in CLKMIN32 minutes format}
  :sys_clock_t;                        {returned clock descriptor}
  val_param;

var
  fp: sys_fp2_t;                       {high resolution FP time value}

begin
  fp := clk;                           {make high resolution FP minutes}
  fp := fp * 60.0;                     {convert to seconds}
  sys_clock_from_clkmin32 := sys_clock_from_fp_abs (fp);
  end;
