{   Subroutine SYS_BEEP (SEC_BEEP, SEC_WAIT, N)
*
*   Cause a beep or tone to be made, if possible with current hardware.
*
*   SEC_BEEP - Seconds duration for the beep.  This is not intended to be accurate,
*     and may even be ignored on some hardware.
*
*   SEC_WAIT - Seconds wait after all but the last beep.
*
*   N - Total number of beeps to produce.  This subroutine will loop indefinately
*     if N is set to SYS_BEEP_FOREVER.
*
*   This is a generic version that sounds the tone by sending bell characters
*   to standard output.
}
module sys_BEEP;
define sys_beep;
%include 'sys2.ins.pas';
%include 'sys_sys2.ins.pas';

procedure sys_beep (                   {ring bell or make tone, if possible}
  in      sec_beep: real;              {seconds duration of tone}
  in      sec_wait: real;              {seconds to wait after tone}
  in      n: sys_int_machine_t);       {N times for tone/wait, or SYS_BEEP_FOREVER}
  val_param;

const
  sec_bell = 0.1;                      {duration for one bell character}

var
  i, j: sys_int_machine_t;             {loop counters}
  n_bells: sys_int_machine_t;          {number of bells to satisy SEC_BEEP}
  n_rep: sys_int_machine_t;            {number of times to repeat}

label
  loop;
{
************************************
*
*   Start of main routine.
}
begin
  if n = sys_beep_forever
    then begin                         {supposed to beep in infinite loop ?}
      n_rep := 0;
      end
    else begin                         {repeat a fixed number of times}
      if n <= 0 then return;           {nothing to do or bad repeat count ?}
      n_rep := n;
      end
    ;

  n_bells := max(0,                    {number of bells per beep}
    round(sec_beep / sec_bell));

  i := 1;                              {number of next beep}
loop:                                  {back here each new beep}
  for j := 1 to n_bells do begin       {once for each bell in this beep}
    discard( write(                    {send bell character to error output}
      sys_sys_iounit_errout_k,         {stream ID for error output}
      chr(7),                          {character to send}
      1) );                            {number of characters to send}
    sys_wait (sec_bell - 0.001);       {wait for this bell to complete}
    end;                               {back and do next bell in this beep}
  if i = n_rep then return;            {all done ?}

  sys_wait (sec_wait);                 {wait between beeps}
  if n <> sys_beep_forever
    then i := i + 1;                   {update number of next beep}
  goto loop;
  end;
