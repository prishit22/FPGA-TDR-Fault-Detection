module PROJECT_tdr_measure (
    input  wire        CLOCK_50,      // 50 MHz FPGA clock
    input  wire        rx_comp,       // Comparator output (reflected pulse input)
    output reg         tx_pulse,      // Transmitted pulse output
    output reg [15:0]  time_ticks,    // Measured round-trip time in clock cycles
    output reg [31:0]  distance_cm,   // Estimated one-way distance in cm
    output reg         detect_valid   // HIGH when a reflection is detected
);

// ------------------------------------------------------------
// Parameters
// ------------------------------------------------------------
parameter [15:0] PERIOD_TICKS = 16'd10000;  // 200 us period at 50 MHz
parameter [15:0] BLANK_TICKS  = 16'd5;      // 5 clocks = 100 ns blanking window

// RG-58 propagation velocity ~= 0.66c.
// At 50 MHz, one 20 ns round-trip timing tick corresponds to
// approximately 1.98 m one-way distance = 198 cm.
parameter [31:0] CM_PER_TICK  = 32'd198;

// ------------------------------------------------------------
// Internal registers
// ------------------------------------------------------------
reg [15:0] period_counter  = 16'd0;
reg [15:0] measure_counter = 16'd0;
reg [15:0] blank_counter   = 16'd0;

reg measuring = 1'b0;
reg blanking  = 1'b0;

// Two-stage synchronizer plus one delayed sample for edge detection.
reg rx_sync_1   = 1'b0;
reg rx_sync_2   = 1'b0;
reg rx_sync_2_d = 1'b0;

wire rx_rising;
assign rx_rising = rx_sync_2 & ~rx_sync_2_d;

// Initialize outputs for deterministic FPGA power-up behavior.
initial begin
    tx_pulse    = 1'b0;
    time_ticks  = 16'd0;
    distance_cm = 32'd0;
    detect_valid = 1'b0;
end

// ------------------------------------------------------------
// Main logic
// ------------------------------------------------------------
always @(posedge CLOCK_50) begin

    // Synchronize asynchronous comparator input to FPGA clock.
    rx_sync_1   <= rx_comp;
    rx_sync_2   <= rx_sync_1;
    rx_sync_2_d <= rx_sync_2;

    // Default transmit pulse LOW. It is asserted for one clock below.
    tx_pulse <= 1'b0;

    // --------------------------------------------------------
    // Start a new TDR cycle every PERIOD_TICKS clocks.
    // Giving this branch priority prevents an old unfinished
    // measurement from overwriting the new cycle's reset values.
    // --------------------------------------------------------
    if (period_counter == PERIOD_TICKS - 16'd1) begin
        period_counter <= 16'd0;

        // 20 ns transmit pulse.
        tx_pulse <= 1'b1;

        // Start timing at the transmit instant.
        measuring       <= 1'b1;
        measure_counter <= 16'd0;
        detect_valid    <= 1'b0;

        // Ignore comparator activity during initial ringing.
        blanking      <= 1'b1;
        blank_counter <= 16'd0;
    end
    else begin
        period_counter <= period_counter + 16'd1;

        // ----------------------------------------------------
        // Blanking window.
        // Timing continues during blanking, but reflections are
        // ignored until the window has expired.
        // ----------------------------------------------------
        if (blanking) begin
            if (blank_counter == BLANK_TICKS - 16'd1) begin
                blanking      <= 1'b0;
                blank_counter <= 16'd0;
            end
            else begin
                blank_counter <= blank_counter + 16'd1;
            end
        end

        // ----------------------------------------------------
        // Measurement phase.
        // ----------------------------------------------------
        if (measuring) begin
            measure_counter <= measure_counter + 16'd1;

            // Accept only the first synchronized rising edge
            // after the blanking interval.
            if (!blanking && rx_rising) begin
                measuring    <= 1'b0;
                detect_valid <= 1'b1;

                // Store measured round-trip time in clock ticks.
                time_ticks <= measure_counter;

                // One-way distance estimate for RG-58.
                distance_cm <= measure_counter * CM_PER_TICK;
            end
        end
    end
end

endmodule
