# Sequence Detector Using Mealy FSM
## Top module name : pes_seq_det_ml_fsm

**In this repository we are going to see the flow from design to tapeout.**<br>
We have divided it into 3 parts.
1. Synthesis and GLS.
2. Physical Design.
3. GDS Tapeout.

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
