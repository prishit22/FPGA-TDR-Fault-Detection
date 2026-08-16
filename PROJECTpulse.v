module PROJECTpulse (
    input wire CLOCK_50,      // 50 MHz system clock
    output reg pulse_out      // Output pulse signal
);

// 14-bit counter (counts from 0 to 9999)
reg [13:0] counter = 14'd0;

always @(posedge CLOCK_50) begin

    // Counter logic: period of 10,000 clock cycles
    if (counter == 14'd9999)
        counter <= 14'd0;
    else
        counter <= counter + 14'd1;

    // Generate a HIGH pulse for one clock cycle (20 ns)
    if (counter == 14'd0)
        pulse_out <= 1'b1;
    else
        pulse_out <= 1'b0;

end

endmodule