{   Routines that manipulate network addresses.
}
module sys_inetadr;
define sys_inetadr_local;
%include '(cog)lib/sys2.ins.pas';
{
********************************************************************************
*
*   Function SYS_INETADR_LOCAL (ADR)
*
*   Determine whether the network address ADR is a unroutable local address or
*   a possible remote address.  Certain address ranges are reserved for local
*   use, and therefore never appear publicly on the internet.
}
function sys_inetadr_local (           {determine whether network node address is local}
  in      adr: sys_inet_adr_node_t)    {the node address to test}
  :boolean;                            {TRUE for unroutable local, FALSE for remote}
  val_param;

var
  adr3, adr2: sys_int_machine_t;       {bytes 2 and 3 of the address}

begin
  sys_inetadr_local := true;           {init to address is unroutable local}

  adr3 := rshft(adr, 24) & 255;        {make separate dot notation adr components}
  adr2 := rshft(adr, 16) & 255;

  if adr3 = 10 then return;            {local class A address ?}
  if (adr3 = 172) and (adr2 = 16) then return; {local class B address ?}
  if (adr3 = 192) and (adr2 = 168) then return; {local class C address ?}
  if (adr3 = 127) then return;         {on same machine ?}

  sys_inetadr_local := false;          {indicate this is a public address}
  end;
