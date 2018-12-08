{   Subroutine SYS_MESSAGE (SUBSYS, MSG)
*
*   Write message.  SUBSYS is the subsystem name to which the message belongs.
*   MSG is the name of the particular message within that subsystem.  The message
*   will be read from a .msg file in the enviroment files directory hierarchy.
*   The file name will be the subsystem name with .msg appended.
*
*   The message from the most local file will be used.
}
module sys_message;
define sys_message;
%include 'sys2.ins.pas';

procedure sys_message (                {write message to user}
  in      subsys: string;              {name of subsystem, used to find message file}
  in      msg: string);                {message name withing subsystem file}

begin
  sys_message_parms (subsys, msg, nil, 0); {message without parameters}
  end;
