# Sequence Detector Using Mealy FSM
## Top module name : pes_seq_det_ml_fsm

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
```
show
```
```
write_verilog -noattr Seq_Detector_ML_FSM_netlist.v
```
```
exit
```
```
iverilog ../my_lib/verilog_model/primitives.v ../my_lib/verilog_model/sky130_fd_sc_hd.v Seq_Detector_ML_FSM_netlist.v Seq_detector_ML_FSM.v
```
```
./a.out
```
```
gtkwave sqnsdet_tb.vcd
```
