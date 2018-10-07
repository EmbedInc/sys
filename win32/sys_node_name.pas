{   Subroutine SYS_NODE_NAME (S)
*
*   Return the network name of the machine running this process.
}
module sys_node_name;
define sys_node_name;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';
%include 'string.ins.pas';

procedure sys_node_name (              {return network name of this machine}
  in out  s: univ string_var_arg_t);   {returned node name string}

var
  name: array[1..1024] of char;        {name returned by system routine}
  len: win_dword_t;                    {string length}
  ok: win_bool_t;                      {system call success flag}
  stat: sys_err_t;

begin
  len := size_char(name);              {indicate max chars allowed to write to NAME}
  ok := GetComputerNameA (name, len);  {get the name of this machine}
  if ok = win_bool_false_k then begin  {system call failed ?}
    sys_error_none (stat);
    stat.sys := GetLastError;
    sys_error_abort (stat, 'sys', 'node_name_get', nil, 0);
    end;

  string_vstring (s, name, len);       {return name as var string}
  string_downcase (s);                 {always pass back name in lower case}
  end;
