{   Subroutine SYS_ORDER_FLIP (ARG, SIZE)
*
*   Flip the address order of ARG.  SIZE if the number of system address units
*   occupied by ARG.
}
module sys_order_flip;
define sys_order_flip;
%include 'sys2.ins.pas';

procedure sys_order_flip (             {flip "byte" order of of data object}
  in out  arg: univ sys_arg_any_t;     {data object to flip order of}
  in      size: sys_int_adr_t);        {size of data object to flip}
  val_param;

var
  i: sys_int_machine_t;                {loop counter}
  p1, p2: sys_size1_p_t;               {pointers to bytes to exchange}
  hold: sys_size1_t;                   {temp save area while swapping data values}

begin
  p1 := sys_size1_p_t(addr(arg));      {init pointer to first byte}
  p2 := sys_size1_p_t(sys_int_adr_t(p1) + size - 1); {init pointer to last byte}

  for i := 1 to size div 2 do begin    {once for each exchange to do}
    hold := p2^;                       {exchange data P1 and P2 are pointing at}
    p2^ := p1^;
    p1^ := hold;
    p1 := univ_ptr(sys_int_adr_t(p1) + 1);
    p2 := univ_ptr(sys_int_adr_t(p2) - 1);
    end;
  end;
