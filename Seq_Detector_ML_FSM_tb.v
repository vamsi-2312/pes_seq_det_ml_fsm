module pes_seq_det_ml_fsm_tb;
reg sequence_in,clock,reset;
wire detector_out;
iiitb_SDM m1(sequence_in,clock,reset,detector_out);
initial
begin
$dumpfile("sqnsdet_tb.vcd");
$dumpvars(0);
clock=0;sequence_in=0;
reset=1;
#10 reset=1;
#10 reset =0;
$monitor($time, , ,"c=%b",clock,,"y=%b",detector_out,,"r=%b",reset,,"d=%b",sequence_in);
#10 sequence_in=0;
#10 sequence_in=1;
#10 sequence_in=0;
#10 sequence_in=1;
#10 sequence_in=0;
#10 sequence_in=1;
#10 sequence_in=1;
#10 sequence_in=0;
#10 sequence_in=1;
#10 sequence_in=0;
#10 sequence_in=0;

end
always
#5 clock=~clock;
initial
#200 $finish ;
endmodule
