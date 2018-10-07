{   Subroutine SYS_NODE_ID (S)
*
*   Return the ID of the machine running this process.  This is a unique ID
*   for this node that was set at manufacturing time.
}
module sys_node_id;
define sys_node_id;
%include 'sys2.ins.pas';
%include 'string.ins.pas';
%include 'sys_sys2.ins.pas';

procedure sys_node_id (                {return unique ID string for this machine}
  in out  s: univ string_var_arg_t);   {returned node ID string}

var
  name: string_leafname_t;             {root drive directory name, machine name}
  i: sys_int_machine_t;                {scratch integer and loop counter}
  id: win_dword_t;                     {numerical node ID}
  acc, acc_add, acc_xor: sys_int_conv32_t; {hash algorithm accumulators}
  ok: win_bool_t;                      {not WIN_BOOL_FALSE_K on system call success}
  unused_len: win_dword_t;
  unused_flags: filesys_t;
  unused_vname, unused_fsname: win_path_t;
  stat: sys_err_t;

label
  fnd_fixed, got_id;

begin
  name.max := sizeof(name.str);        {init local var string}

  sys_sys_rootdir (name);              {get system root directory name like "C:\"}
  string_terminate_null (name);
  if GetDriveTypeA (name.str) = drivetype_fixed_k {root dir is on fixed drive ?}
    then goto fnd_fixed;
{
*   This system has no fixed disk drives.  Hash up the node name
*   to make a unique string.
}
  sys_node_name (name);                {get name (hopefully) unique to this machine}

  acc := 305419896;                    {init hash algorithm seeds}
  acc_add := 0;
  acc_xor := 0;

  for i := 1 to name.len do begin      {once for each character in node name}
    acc := lshft(acc, 1) + ord(name.str[i]); {add in contribution for this byte}
    acc_add := acc_add + acc;
    acc_xor := xor(acc_xor, acc);
    end;                               {back for next node name character}
  id := xor(acc_xor, acc_add) & 16#FFFFFFFF; {make final 32 bit hashed value}
  goto got_id;                         {ID all set}
{
*   NAME is the name of the first fixed drive on this system.  The numerical
*   node ID will be its serial number.
}
fnd_fixed:
  ok := GetVolumeInformationA (        {get info about file system volume}
    name.str,                          {drive name inquiring about}
    unused_vname, win_max_path_k,      {volume name}
    id,                                {returned volume serial number}
    unused_len,                        {max length of file name components}
    unused_flags,                      {additional flags about this file system}
    unused_fsname, win_max_path_k);    {file system type name}
  if ok = win_bool_false_k then begin  {system call error ?}
    sys_sys_error_bomb ('', '', nil, 0);
    end;
{
*   ID is an integer set to the numeric ID of this node.
}
got_id:
  string_f_int_max_base (              {convert numeric ID to string}
    s,                                 {output string}
    id,                                {input integer}
    16,                                {number base}
    8,                                 {always create 8 characters}
    [ string_fi_unsig_k,               {input number is unsigned}
      string_fi_leadz_k],              {write leading zeros to fill field}
    stat);
  sys_error_abort (stat, '', '', nil, 0);
  end;
