#============================================================
# Timing constraints for TDR FPGA Pulse Generator
#============================================================

# DE10-Lite onboard CLOCK_50 = 50 MHz
# 50 MHz => 20 ns period
create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]

derive_clock_uncertainty
