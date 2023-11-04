module pes_seq_det_ml_fsm(sequence_in,clock,reset,detector_out);
input clock; // clock signal
input reset; // reset input
input sequence_in; // binary input
output reg detector_out; // output of the sequence detector
parameter  Zero=3'b000, // "Zero" State
  One=3'b001, // "One" State
  OneZero=3'b010, // "OneZero" State
  OneZeroOne=3'b011, // "OnceZeroOne" State
  OneZeroOneZero=3'b100,// "OneZeroOneOne" State
  OneZeroOneZeroOne=3'b101;
reg [2:0] current_state, next_state; // current state and next state
// sequential memory of the Moore FSM
always @(posedge clock, posedge reset)
begin
 if(reset==1) 
 current_state <= Zero;// when reset=1, reset the state of the FSM to "Zero" State
 else
 current_state <= next_state; // otherwise, next state
end 
// combinational logic of the Mealy FSM
// to determine next state 
always @(current_state,sequence_in)
begin
 case(current_state) 
 Zero:begin
  if(sequence_in==1)
   next_state <= One;
  else
   next_state <= Zero;
 end
 One:begin
  if(sequence_in==0)
   next_state <= OneZero;
  else
   next_state <= One;
 end
 OneZero:begin
  if(sequence_in==0)
   next_state <= Zero;
  else
   next_state <= OneZeroOne;
 end 
 OneZeroOne:begin
  if(sequence_in==1)
   next_state <= One;
  else
   next_state <= OneZeroOneZero;
 end
 OneZeroOneZero:begin
  if(sequence_in==0)
   next_state <= Zero;
  else
   next_state <= OneZeroOneZeroOne;
 end
 OneZeroOneZeroOne:begin
 if(sequence_in==1)
 next_state <= One;
 else
 next_state=OneZeroOneZero;
 end
 default:next_state <= Zero;
 endcase
end
// combinational logic to determine the output
// of the Mealy FSM, output  depends on current state and present input
always @(posedge clock)
begin 
 if (reset==1) detector_out <= 1'b0;
    else begin
      if (sequence_in & (current_state == OneZeroOneZeroOne)) detector_out <= 1'b1;
      else detector_out <= 1'b0;
    end
end 
endmodule
