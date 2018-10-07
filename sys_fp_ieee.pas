{   Module of routines that convert between IEEE and native floating point
*   formats.
*
*   This version is the main line of decent, which applies to all systems
*   that have native data types for IEEE 32 and 64 bit floating point numbers.
}
module sys_fp_ieee;
define sys_fp_from_ieee32;
define sys_fp_from_ieee64;
define sys_fp_to_ieee32;
define sys_fp_to_ieee64;
%include 'sys2.ins.pas';
{
***********************************************
}
function sys_fp_from_ieee32 (          {convert from IEEE 32 bit FP number}
  in      ival: sys_fp_ieee32_t)       {IEEE 32 bit floating point input value}
  :sys_fp_max_t;                       {returned native floating point value}
  val_param;

begin
  sys_fp_from_ieee32 := ival;
  end;
{
***********************************************
}
function sys_fp_from_ieee64 (          {convert from IEEE 64 bit FP number}
  in      ival: sys_fp_ieee64_t)       {IEEE 64 bit floating point input value}
  :sys_fp_max_t;                       {returned native floating point value}
  val_param;

begin
  sys_fp_from_ieee64 := ival;
  end;
{
***********************************************
}
function sys_fp_to_ieee32 (            {convert to IEEE 32 bit FP number}
  in      ival: sys_fp_max_t)          {native floating point input value}
  :sys_fp_ieee32_t;                    {returned IEEE 32 bit floating point value}
  val_param;

begin
  sys_fp_to_ieee32 := ival;
  end;
{
***********************************************
}
function sys_fp_to_ieee64 (            {convert to IEEE 64 bit FP number}
  in      ival: sys_fp_max_t)          {native floating point input value}
  :sys_fp_ieee64_t;                    {returned IEEE 64 bit floating point value}
  val_param;

begin
  sys_fp_to_ieee64 := ival;
  end;
