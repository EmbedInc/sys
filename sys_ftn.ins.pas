{
*  This include file contains data type definitions, const, and data type
*  conversion routines needed for bounce routines written in PASCAL
*  and called from FORTRAN.
}
%include 'sys_ftn_sys.ins.pas';

type
{
*  The following data types build off of the system dependent data types
*  defined above.
}
  sys_ftn_integer_arr_t =              {equivalent INTEGER array declaration in FORTRAN}
    array[1..1] of sys_ftn_integer_t;

  sys_ftn_real_arr_t =                 {equivalent REAL array declaration in FORTRAN}
    array[1..1] of sys_ftn_real_t;

  sys_ftn_logical_arr_t =              {equivalent LOGICAL array declaration in FORTRAN}
    array[1..1] of sys_ftn_logical_t;

  sys_ftn_double_arr_t =               {equivalent DOUBLE array declaration in FORTRAN}
    array[1..1] of sys_ftn_double_t;

{
*  The following functions are used to convert from a fortran data type to
*  a pascal data type or vice versa.
}
function sys_ftn_logical_t_pas_boolean ( {convert FORTRAN logical to PASCAL boolean}
  in      val: sys_ftn_logical_t):     {value of FORTRAN logical}
  boolean;
  val_param; extern;

function sys_pas_boolean_t_ftn_logical ( {convert PASCAL boolean to FORTRAN logical}
  in      val: boolean):               {value of PASCAL boolean}
  sys_ftn_logical_t;
  val_param; extern;

