{   Module of routines to manipulate the floating point trap mode.
*
*   This is the generic Unix version.
}
module sys_fpmode;
define sys_fpmode_get;
define sys_fpmode_set;
define sys_fpmode_traps_none;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
{
**********************************************************************
*
*   Subroutine SYS_FPMODE_GET (FPMODE)
*
*   Get the current modes used in handling floating point issues, like overflow,
*   etc.
}
procedure sys_fpmode_get (             {get current FP handling modes state}
  out     fpmode: sys_fpmode_t);       {returned handle to FP handling modes}

begin
  fpmode.sys := nil;                   {not implemented yet}
  end;
{
**********************************************************************
*
*   Subroutine SYS_FPMODE_SET (FPMODE)
*
*   Set new modes for handling floating point issues (like overflow, etc.).
}
procedure sys_fpmode_set (             {set new FP handling modes}
  in      fpmode: sys_fpmode_t);       {descriptor for new modes}
  val_param;

begin                                  {not implemented yet}
  end;
{
**********************************************************************
*
*   Subroutine SYS_FPMODE_TRAPS_NONE
*
*   Disable all floating point exception traps.  If an exception occurrs
*   (such as divide by zero), then execution continues but the number contains
*   garbage.
}
procedure sys_fpmode_traps_none;       {disable all FP exception traps}

begin                                  {not implemented yet}
  end;
