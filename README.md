# FPGA TDR Fault Detection

A proof-of-concept **Time Domain Reflectometry (TDR)** system for locating faults in underground/coaxial cables using an **Intel DE10-Lite FPGA**, high-speed pulse generation, a gate-driver stage, a Schottky-diode sampling network, and reflected-pulse timing.

This project was developed as an **EELE-2939 Capstone Design Project** at Lakehead University.

## Project Overview

The system launches a nanosecond-scale electrical pulse into an RG-58 transmission line. An impedance discontinuity - such as an open or short circuit - produces a reflected pulse. The round-trip delay between the transmitted and reflected signals is used to estimate the fault distance:

```text
d = v * t / 2
```

where:

- `d` = one-way distance to the fault
- `v` = propagation velocity in the cable
- `t` = measured round-trip time

For RG-58 cable, a velocity factor of approximately `0.66c` was used.

## System Architecture

![TDR system-level architecture](images/page_06_image_01.png)

The main stages are:

1. **FPGA pulse generation** - DE10-Lite generates a 20 ns pulse.
2. **Gate driver** - UCC27511 increases voltage/current drive capability.
3. **Schottky diode sampling network** - routes the pulse and conditions reflected signals.
4. **RG-58 transmission line** - acts as the cable under test.
5. **Measurement stage** - oscilloscope measurements were used during hardware validation; comparator-based FPGA timing was designed as an extension.

## FPGA Pulse Generator

The DE10-Lite operates from a **50 MHz clock**, giving a 20 ns clock period. A counter-based Verilog design produces:

- Pulse width: **20 ns**
- Pulse period: **200 us**
- Repetition rate: **5 kHz**
- Duty cycle: **0.01%**

The low duty cycle gives reflected signals enough time to return before the next pulse is transmitted.

## Distance Measurement Logic

The extended Verilog design adds:

- comparator-input synchronization
- an initial blanking window to reject transmit feedthrough/ringing
- rising-edge detection of the reflected pulse
- round-trip clock-cycle measurement
- automatic distance calculation

At 50 MHz, one clock tick is 20 ns. With RG-58 propagation velocity approximated as `0.66c`, one timing tick represents approximately:

```text
1.98 m = 198 cm
```

of one-way distance.

## Hardware

- Intel/Terasic **DE10-Lite FPGA**
- **UCC27511** high-speed gate driver
- Fast **Schottky diodes**
- RG-58 coaxial cable, approximately 50 ohm characteristic impedance
- Protoboard implementation
- BNC connectors
- Oscilloscope
- External DC supply for the gate-driver stage

## Experimental Results

Testing demonstrated the basic TDR principle and showed reflected signals for open- and short-circuit conditions.

| Cable / Test | Theoretical Delay | Measured Delay | Estimated Distance | Observation |
|---|---:|---:|---:|---|
| 20 ft | ~61 ns | Not reliable in one test | Not reliable | Reflection overlapped with ringing |
| 40 ft | ~123 ns | ~120 ns | ~39 ft | Reflection partially visible |
| 50 ft | ~154 ns | ~150 ns | ~48.7 ft | Reflection visible; ringing present |
| 20 ft validation | ~61 ns | ~61 ns | ~20 ft | Clearest time-delay measurement |

For the 50 ft test, the timing error was approximately **2.6%**.

## Experimental Setup

![Final TDR experimental setup](images/page_55_image_01.jpeg)

The prototype integrated the DE10-Lite, gate driver, diode sampling network, RG-58 cable, oscilloscope, and external power supply.

## Key Engineering Challenges

The largest practical issue was **signal integrity at nanosecond time scales**. The prototype exhibited ringing and pulse distortion caused by:

- protoboard parasitic capacitance
- long-wire inductance
- impedance discontinuities
- grounding limitations
- fast gate-driver switching edges

Although the FPGA generated a 20 ns pulse, the measured pulse after the gate driver was approximately **40 ns**, reducing the practical spatial resolution to roughly **4 m**.

## Future Improvements

- Implement the high-speed comparator stage in hardware.
- Integrate automatic reflection timing and distance output fully on the FPGA.
- Replace the protoboard with a controlled-impedance PCB.
- Improve FPGA I/O protection and signal conditioning.
- Use a narrower pulse / higher-frequency timing architecture for better spatial resolution.
- Calibrate fixed hardware delays and cable-specific velocity factors.

## Repository Structure

A suggested repository layout is:

```text
FPGA-TDR-Fault-Detection/
├── PROJECTpulse.v
├── PROJECT_tdr_measure.v
├── TDR_FINAL.qpf
├── TDR_FINAL.qsf
├── TDR_FINAL.sdc
├── images/
│   ├── page_06_image_01.png
│   ├── page_55_image_01.jpeg
│   └── ...
└── README.md
```

## Sample Image Links for GitHub

If the extracted images are stored in an `images` folder, these Markdown lines can be pasted directly into the README:

```markdown
![TDR system architecture](images/page_06_image_01.png)
![Final experimental setup](images/page_55_image_01.jpeg)
```

## Authors

- Prishit Kumar
- Selim Sanni

**Project period:** January 7, 2026 - April 8, 2026

## Notes

The hardware implementation was developed as a proof of concept. Oscilloscope-based reflection measurements were experimentally validated. The comparator-based automatic FPGA distance-measurement logic was developed as an extension; the report identifies full comparator integration as future work.
