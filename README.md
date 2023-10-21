# Sequence Detector Using Mealy FSM
## Top module name : pes_seq_det_ml_fsm

**In this repository we are going to see the flow from design to tapeout.**<br>
We have divided it into 3 parts.
1. Synthesis and GLS.
2. Physical Design.
3. GDS Tapeout.

## What is Sequence Detector?
#### **A sequence detector is a digital circuit or algorithm that identifies specific patterns or sequences within a data stream. It takes an input stream, defines a target sequence, and produces an output when the input matches the defined pattern. Sequence detectors use sequential logic to process and recognize various sequences, serving applications like data communication error detection, barcode scanning, and speech recognition.**<br>

### We are using Mealy FSM to implement our Sequence Detector, we can also implement it using Moore FSM.

### Mealy FSM
#### A Mealy Finite State Machine (FSM) is a type of sequential digital circuit where the output depends not only on the current state but also on the input. It transitions between states based on input and produces output simultaneously. Mealy FSMs are often used in applications where real-time responses are required.<br>

![Screenshot from 2023-10-21 08-30-55](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/b85db39a-87eb-4594-9c05-c4606c6885c5)

## Code for Sequence Detector (Design)
```
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
```

## Code for Test Bench
```
module pes_seq_det_ml_fsm_tb;
reg sequence_in,clock,reset;
wire detector_out;
pes_seq_det_ml_fsm m1(sequence_in,clock,reset,detector_out);
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
```

### RTL
![Screenshot from 2023-10-21 08-24-34](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/63ee40ef-e36e-4bed-840b-9f33c2ca3c18)

### FSM
![Screenshot from 2023-10-21 08-25-04](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/164a3638-8a50-42be-95ae-000c4356611f)

#### Transition Table
![Screenshot from 2023-10-21 08-25-23](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/21d736b8-73ea-414b-993d-aed30033fff0)

#### Encoding Table
![Screenshot from 2023-10-21 08-25-37](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/78a39789-7c9f-4387-ac1e-16b5dcb6900e)



# Synthesis and GLS
Open terminal
```
cd ~/sky130RTLDesignAndSynthesisWorkshop/verilog_files
```
```
iverilog Seq_detector_ML_FSM.v Seq_Detector_ML_FSM_tb.v -o Seq_Detector_ML_FSM.out
```
```
./Seq_Detector_ML_FSM.out 
```
```
gtkwave sqnsdet_tb.vcd
```
![2](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/836c1b94-475c-4f88-b1e2-0c23efede492)

![1](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/fe72c7e4-61fa-47c8-885f-3bf2cf00711d)

```
yosys
```
```
read_liberty -lib ../my_lib/lib/sky130_fd_sc_hd__tt_025C_1v80.lib 
```
```
read_verilog Seq_detector_ML_FSM.v
```
![3](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/04dbea6b-13e1-4dd9-b956-769c9940f588)

```
synth -top pes_seq_det_ml_fsm
```
![4](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/ef9c1a11-62f8-4304-8d22-c13c92a94af3)

```
dfflibmap -liberty ../my_lib/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
```
```
abc -liberty ../my_lib/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
```
![after abc](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/61204c6e-9edb-4895-bdad-5507add7fee5)

```
show
```
![2](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/f8088dbf-8026-4b5d-a6bc-a33b305e788a)

```
write_verilog -noattr Seq_Detector_ML_FSM_netlist.v
```
![3](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/5e441837-a644-4ed0-9cd1-08b36906d48c)

```
exit
```
```
iverilog ../my_lib/verilog_model/primitives.v ../my_lib/verilog_model/sky130_fd_sc_hd.v Seq_Detector_ML_FSM_netlist.v Seq_Detector_ML_FSM_tb.v
```
```
./a.out
```
```
gtkwave sqnsdet_tb.vcd
```
![4](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/3c7300dc-c351-4ecd-b1ae-91ebae311d0c)

![5](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/3f584b06-0f44-4f67-8dda-f89b61badd3c)

# Physical Design

# GDS Tapeout
