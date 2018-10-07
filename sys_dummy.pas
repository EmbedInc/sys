{   Subroutine SYS_DUMMY (ARG)
*
*   This subroutine does nothing, but is used to prevent some compiler
*   optimizations around the call, since the compiler can not assume anything
*   about what happens to ARG.
}
module sys_DUMMY;
define sys_dummy;
%include 'sys2.ins.pas';

procedure sys_dummy (                  {does nothing but, prevents compiler opts}
  in out  arg: univ char);             {argument is not altered}

begin
  end;
