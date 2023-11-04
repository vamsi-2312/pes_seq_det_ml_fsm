# Sequence Detector Using Mealy FSM
## Top module name : pes_seq_det_ml_fsm

**In this repository we are going to see the flow from design to tapeout.**<br>
We have divided it into 3 parts.
1. Synthesis and GLS.
2. Physical Design.
3. GDS Tapeout.

## What is Sequence Detector?
A sequence detector is a digital circuit or algorithm that serves the purpose of recognizing specific sequences within an input stream. These sequences could be composed of binary digits, symbols, or events and can be continuous or discrete, depending on the application.

Key elements of sequence detectors include:

Sequence Specification: Designers specify the particular sequence or pattern they want the detector to identify. This sequence is defined through a set of rules, conditions, or a pattern description.

Output: When the input stream matches the specified sequence, the sequence detector generates an output signal or triggers a predefined action, indicating that the desired pattern has been found.

Sequential Logic: Sequence detectors employ sequential logic circuits or algorithms to keep track of the current state and transition as new symbols in the input stream are processed. This enables the detector to identify sequences of varying lengths and complexity.

Sequence detectors find applications in various fields, including data communication for error detection and correction, barcode scanning for retail and logistics, speech recognition in voice command systems, and more. The complexity and design of a sequence detector depend on the specific requirements of the task and the nature of the input data it is meant to process.<br>

### We are using Mealy FSM to implement our Sequence Detector, we can also implement it using Moore FSM.

### Mealy FSM
A Mealy Finite State Machine (FSM) is a digital circuit known for its real-time responsiveness. It differs from the more common Moore FSM by generating outputs not only based on the current state but also on the immediate input. This means the outputs can change in real-time as the machine transitions between states, making it suitable for applications where immediate, input-sensitive responses are essential. Mealy FSMs find applications in various areas such as control systems and communication protocols, where dynamic and context-aware behavior is needed for efficient and adaptive operation.<br>

![Screenshot from 2023-10-21 08-30-55](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/b85db39a-87eb-4594-9c05-c4606c6885c5)

### We are Detecting the pattern 101011.<br>

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

First we will be performing Synthesis of the Design and Test Bench just using "Iverilog".<br>
Then we will compare with the results obtained by "YOSYS" and "GLS".<br>

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

Next, Let's invoke YOSYS.<br>
```
yosys
```
Read the Library file.<br>
```
read_liberty -lib ../my_lib/lib/sky130_fd_sc_hd__tt_025C_1v80.lib 
```
Read the Design File.<br>
```
read_verilog Seq_detector_ML_FSM.v
```
![3](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/04dbea6b-13e1-4dd9-b956-769c9940f588)

Perform Synthesis of the Design File(here we have given the top module name as the Design module name).<br>
```
synth -top pes_seq_det_ml_fsm
```
![4](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/ef9c1a11-62f8-4304-8d22-c13c92a94af3)

The we need to map the D Flip-Flops.<br>
```
dfflibmap -liberty ../my_lib/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
```
```
abc -liberty ../my_lib/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
```
![after abc](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/61204c6e-9edb-4895-bdad-5507add7fee5)

To see the Netlist.<br>
```
show
```
![2](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/f8088dbf-8026-4b5d-a6bc-a33b305e788a)

Writing the netlist into Seq_Detector_ML_FSM_netlist.v<br>
```
write_verilog -noattr Seq_Detector_ML_FSM_netlist.v
```
![3](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/5e441837-a644-4ed0-9cd1-08b36906d48c)

Come outside Yosys.<br>
```
exit
```
Now let's perform GLS using the netlist generated from the yosys.<br>
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

This is the image from the GLS.<br>
![5](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/3f584b06-0f44-4f67-8dda-f89b61badd3c)

Comparing the Output before and after GLS.<br>
Left - Before GLS<br>
Right - After GLS
![Screenshot from 2023-10-21 08-53-26](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/286213f9-cbce-4349-99ec-aff2299560b1)

# Physical Design

Creating a new Virtual Machine.<br>

### Installing Openlane

Installation of required packages
```
sudo apt-get update
```
```
sudo apt-get upgrade
```
```
sudo apt install -y build-essential python3 python3-venv python3-pip make git
```
Docker Installation
```
# Remove old installations
sudo apt-get remove docker docker-engine docker.io containerd runc
# Installation of requirements
sudo apt-get update
sudo apt-get install \
   ca-certificates \
   curl \
   gnupg \
   lsb-release
# Add the keyrings of docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# Add the package repository
echo \
   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Update the package repository
sudo apt-get update

# Install Docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Check for installation
sudo docker run hello-world
```
A successful installation of Docker would have this output:
```
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
1. The Docker client contacted the Docker daemon.
2. The Docker daemon pulled the "hello-world" image from the Docker Hub. (amd64)
3. The Docker daemon created a new container from that image which runs the executable that produces the output you are currently reading.
4. The Docker daemon streamed that output to the Docker client, which sent it to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
$ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
https://hub.docker.com/

For more examples and ideas, visit:
https://docs.docker.com/get-started/
```
Making Docker available without root (Linux)
```
sudo groupadd docker
sudo usermod -aG docker $USER
sudo reboot # REBOOT!
```
Checking the Docker Installation
```
# After reboot
docker run hello-world
```
You will get a little happy message of Hello world, once again, but this time without root.
```
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
1. The Docker client contacted the Docker daemon.
2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
   (amd64)
3. The Docker daemon created a new container from that image which runs the
   executable that produces the output you are currently reading.
4. The Docker daemon streamed that output to the Docker client, which sent it
   to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
$ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
https://hub.docker.com/

For more examples and ideas, visit:
https://docs.docker.com/get-started/
```
Checking Installation Requirements
```
git --version
docker --version
python3 --version
python3 -m pip --version
make --version
python3 -m venv -h
```
Successful output will look like this:
```
git --version
docker --version
python3 --version
python3 -m pip --version
make --version
python3 -m venv -h
git version 2.36.1
Docker version 20.10.16, build aa7e414fdc
Python 3.10.5
pip 21.0 from /usr/lib/python3.10/site-packages/pip (python 3.10)
GNU Make 4.3
Built for x86_64-pc-linux-gnu
Copyright (C) 1988-2020 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
usage: venv [-h] [--system-site-packages] [--symlinks | --copies] [--clear]
            [--upgrade] [--without-pip] [--prompt PROMPT] [--upgrade-deps]
            ENV_DIR [ENV_DIR ...]

Creates virtual Python environments in one or more target directories.
...
Once an environment has been created, you may wish to activate it, e.g. by
sourcing an activate script in its bin directory.
```
Download and Install OpenLane
```
git clone --depth 1 https://github.com/The-OpenROAD-Project/OpenLane.git
cd OpenLane/
make
make test
```
Successful test will output the following line:
```
Basic test passed
```

Installing magic
```
git clone https://github.com/RTimothyEdwards/magic  
sudo apt-get install m4  
sudo apt-get install tcl-dev  
sudo apt-get install tk-dev  
sudo apt-get install blt  
sudo apt-get install freeglut3  
sudo apt-get install libglut3  
sudo apt-get install libglu1-mesa-dev  
sudo apt-get install libgl1-mesa-dev  
sudo apt-get install csh
cd magic
./configure
make  
make install
sudo apt install magic
```

## Flow

Step 1 : run_synthesis<br>
Step 2 : run_floorplan<br>
Step 3 : run_placement<br>
Step 4 : run_cts<br>
Step 5 : run_routing<br>
Step 6 : run_magic<br>
Step 7 : run_magic_spice_export<br>
Step 8 : run_magic_drc<br>
Step 9 : run_lvs<br>
Step 10 : run_antenna_check<br>

```
cd Openlane
```
```
make mount
```
```
./flow.tcl -interactive
```
```
package require openlane
```
![1](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/883c16e5-7f54-43cd-afe4-e6b11b4e043a)

```
prep -design pes_seq_det_ml_fsm -tag final
```
```
run_synthesis
```
```
run_floorplan
```
```
run_placement
```
![2](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/53ef7369-e3a2-445d-92e4-3ac83a07e2b9)

open new terminal
```
cd ~/OpenLane/designs/pes_seq_det_ml_fsm/runs/final/results/placement
```
```
magic -T /home/vamsi/Desktop/sky130A.tech lef read ../../tmp/merged.nom.lef def read pes_seq_det_ml_fsm.def &
```
![3](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/0725564d-7cc2-4f1a-be42-32a8642cdf6e)

we can observe that design is using only very small part in the entire chip.

![4](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/f66260b6-4da1-41fa-87ad-243f1e41e734)

now let's change the floorplan sizing from absolute to relative.
```
set ::env(FP_SIZING) "relative"
```
![5](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/0eafcb6e-2262-4700-9a77-3bf8100218eb)

```
run_floorplan
```
```
run_placement
```
![6](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/f3468173-bb47-488a-8fdf-1b6f8ea58a89)

![7](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/320a281a-893f-450d-b56b-9cfd74a6464b)

we can see the dimensions of the chip is reduced.
```
magic -T /home/vamsi/Desktop/sky130A.tech lef read ../../tmp/merged.nom.lef def read pes_seq_det_ml_fsm.def &
```
![8](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/e296fb55-3e1d-4d81-a8c4-5ecc58ea2836)

Now let try to reduce the chip size even more.
```
set ::env(DIE_AREA) "25 25 75 75"
```
```
set ::env(CORE_AREA) "30 35 70 65"
```

![9](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/b7aa0cea-5585-418a-add6-3174fcca2480)

```
run_flooplan
```
```
run_placement
```
![10](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/2d579c4c-beb2-4473-8644-3db3213ec20d)

```
magic -T /home/vamsi/Desktop/sky130A.tech lef read ../../tmp/merged.nom.lef def read pes_seq_det_ml_fsm.def &
```
![11](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/f985a5b3-b009-4a6c-9665-bda87b34825f)


![12](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/ca4fe9db-4591-4dbc-93c2-ca8cbe9a92a2)


let's go to the next steps
```
run_cts
```
```
run_routing
```
![13](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/5bc204e3-53cf-4905-a3f4-7118a094573e)

```
cd
```
```
cd ~/OpenLane/designs/pes_seq_det_ml_fsm/runs/final/results/routing
```
```
magic -T /home/vamsi/Desktop/sky130A.tech lef read ../../tmp/merged.nom.lef def read pes_seq_det_ml_fsm.def &
```
![14](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/19efdd79-0c8e-4ab6-8fdf-56aef53a2ff4)

![15](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/99375f9d-d8bc-4503-be7f-676ef8c79765)

```
run_magic
```
```
run_magic_spice_export
```
```
run_magic_drc
```
```
run_lvs
```
```
run_antenna_check
```
![16](https://github.com/vamsi-2312/pes_seq_det_ml_fsm/assets/142248038/045bbec4-fbfa-4d9a-b782-08c3e92772fa)

# GDS Tapeout
