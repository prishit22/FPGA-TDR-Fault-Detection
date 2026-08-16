# TDR FPGA Pulse Generator

Quartus/Verilog pulse-generator portion of an FPGA-based Time-Domain Reflectometry (TDR) project.

## Target hardware

- Board: Terasic DE10-Lite
- FPGA: Intel/Altera MAX 10 `10M50DAF484C7G`
- System clock: 50 MHz
- `CLOCK_50`: FPGA pin `P11`

## Pulse behavior

`PROJECTpulse.v` uses a 14-bit counter from 0 to 9999.

- Clock period: 20 ns
- Pulse width: 1 clock cycle = 20 ns
- Pulse interval: 10,000 clock cycles = 200 us
- Repetition frequency: 5 kHz

## Important hardware note

The recovered older Quartus/Terasic files confirm the DE10-Lite device and 50 MHz clock pin, but they do **not** contain the original GPIO location used for `pulse_out`.

Therefore `pulse_out` intentionally has no physical pin location in `TDR_FPGA.qsf`. Assign the correct GPIO pin before programming physical hardware.

## Quartus files

- `PROJECTpulse.v` - HDL source
- `TDR_FPGA.qpf` - Quartus project file
- `TDR_FPGA.qsf` - device/settings/pin assignments
- `TDR_FPGA.sdc` - timing constraint for the 50 MHz clock
