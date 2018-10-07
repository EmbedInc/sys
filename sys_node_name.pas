{   Subroutine SYS_NODE_NAME (S)
*
*   Return the network name of the machine running this process.
}
module sys_node_name;
define sys_node_name;
%include 'sys.ins.pas';

procedure sys_node_name (              {return network name of this machine}
  in out  s: univ string_var_arg_t);   {returned node name string}

begin
  writeln ('Subroutine SYS_NODE_NAME is not implemented.');
  sys_bomb;
  end;
