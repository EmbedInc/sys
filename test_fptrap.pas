{   Pprogram TEST_FPTRAP
*
*   Test ability to disable floating point exception traps.
}
program test_fptrap;
%include 'sys.ins.pas';

var
  fpmode: sys_fpmode_t;                {saved state of default FP trap enables}
  a: real;                             {scratch floating point number}

begin
  writeln ('Turning off floating point traps.');
  sys_wait (0.5);
  sys_fpmode_get (fpmode);             {save current FP trap enable state}
  sys_fpmode_traps_none;               {FP exeptions will now be ignored}

  writeln ('Causing floating point exception.');
  sys_wait (0.5);
  a := -1.0;                           {do something illegal (sqrt of -1)}
  sys_dummy (a);
  a := sqrt(a);
  sys_dummy (a);

  writeln ('Restoring floating point trap state.');
  sys_wait (0.5);
  sys_fpmode_set (fpmode);

  writeln ('Causing floating point exception.');
  sys_wait (0.5);
  a := -1.0;                           {do something illegal (sqrt of -1)}
  sys_dummy (a);
  a := sqrt(a);
  sys_dummy (a);

  writeln ('All done.');
  end.
