{   Subroutine SYS_NODE_ID (S)
*
*   Return the ID of the machine running this process.  This is a unique ID
*   for this node that was set at manufacturing time.
}
module sys_node_id;
define sys_node_id;
%include 'sys.ins.pas';

procedure sys_node_id (                {return unique ID string for this machine}
  in out  s: univ string_var_arg_t);   {returned node ID string}

begin
  writeln ('Subroutine SYS_NODE_ID is not implemented.');
  sys_bomb;
  end;
