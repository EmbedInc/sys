{   Program TEST_ORDER
*
*   Test byte order of machine.
}
program test_order;
%include 'sys.ins.pas';

var
  p: ^sys_size1_t;                     {pointer to bytes}
  i: sys_int_machine_t;                {loop counter}
  v: sys_int_max_t;                    {integer value}
  sz: sys_int_adr_t;                   {size of integer value in machine adr units}

begin
  v := 1;                              {put recognizable number into integer}
  sz := sizeof(v);
  writeln ('Integer size is ', sz, ', value is ', v, '.');

  p := univ_ptr(addr(v));
  for i := 0 to sz-1 do begin          {once for each byte in integer}
    writeln ('  Value at offset ', i, ' is ', ord(p^), '.');
    p := univ_ptr(sys_int_adr_t(p) + 1);
    end;
  end.
