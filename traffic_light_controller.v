module traffic_light_controller (
    input clk,                      // Clock input
    input reset,                    // Asynchronous reset
    input sensor_ns,                // Sensor input for North–South traffic density
    input sensor_ew,                // Sensor input for East–West traffic density
    output reg [1:0] light_ns,      // North–South traffic light (using color parameters)
    output reg [1:0] light_ew,      // East–West traffic light (using color parameters)
    output reg [1:0] pedestrian_signal // Pedestrian crossing signal (using color parameters)
);

    // Define FSM States (as parameters)
    parameter STATE_NS_GREEN   = 3'd0,
              STATE_NS_YELLOW  = 3'd1,
              STATE_EW_GREEN   = 3'd2,
              STATE_EW_YELLOW  = 3'd3,
              STATE_PEDESTRIAN = 3'd4;

    // Define Color Codes for Clarity
    parameter RED    = 2'b00,
              GREEN  = 2'b01,
              YELLOW = 2'b10,
              WALK   = 2'b11;  // Pedestrian "Walk" signal

    // Define Time Durations (in clock cycles)
    parameter NS_GREEN_TIME_DEFAULT   = 30;
    parameter NS_GREEN_TIME_EXTENDED  = 45;   // Extended if sensor_ns is active
    parameter NS_YELLOW_TIME          = 5;
    parameter EW_GREEN_TIME_DEFAULT   = 30;
    parameter EW_GREEN_TIME_EXTENDED  = 45;   // Extended if sensor_ew is active
    parameter EW_YELLOW_TIME          = 5;
    parameter PED_TIME                = 15;   // Duration for pedestrian crossing

    // Internal Registers
    reg [2:0] current_state;   // Current state of the FSM
    reg [8:0] timer;           // Timer counter to hold state durations
    reg last_from_ns;          // Flag: 1 if NS was last active, 0 if EW was last active

    // State and Timer Update (Sequential Logic)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= STATE_NS_GREEN; // Start with NS green on reset
            timer         <= 0;
            last_from_ns  <= 1;             // Default (unused until needed)
        end
        else begin
            case (current_state)
                // NS Green Phase: Extend time if heavy NS traffic is sensed.
                STATE_NS_GREEN: begin
                    if (timer < (sensor_ns ? NS_GREEN_TIME_EXTENDED : NS_GREEN_TIME_DEFAULT))
                        timer <= timer + 1;
                    else begin
                        timer         <= 0;
                        current_state <= STATE_NS_YELLOW;
                    end
                end

                // NS Yellow Phase: A fixed duration for yellow.
                STATE_NS_YELLOW: begin
                    if (timer < NS_YELLOW_TIME)
                        timer <= timer + 1;
                    else begin
                        timer         <= 0;
                        last_from_ns  <= 1;  // Mark that NS phase ended
                        current_state <= STATE_PEDESTRIAN;
                    end
                end

                // EW Green Phase: Extend time if heavy EW traffic is sensed.
                STATE_EW_GREEN: begin
                    if (timer < (sensor_ew ? EW_GREEN_TIME_EXTENDED : EW_GREEN_TIME_DEFAULT))
                        timer <= timer + 1;
                    else begin
                        timer         <= 0;
                        current_state <= STATE_EW_YELLOW;
                    end
                end

                // EW Yellow Phase: Fixed yellow period.
                STATE_EW_YELLOW: begin
                    if (timer < EW_YELLOW_TIME)
                        timer <= timer + 1;
                    else begin
                        timer         <= 0;
                        last_from_ns  <= 0;  // Mark that EW phase ended
                        current_state <= STATE_PEDESTRIAN;
                    end
                end

                // Pedestrian Crossing Phase: Both directions red, pedestrian walk active.
                STATE_PEDESTRIAN: begin
                    if (timer < PED_TIME)
                        timer <= timer + 1;
                    else begin
                        timer <= 0;
                        // Alternate the subsequent green based on which side just completed.
                        if (last_from_ns)
                            current_state <= STATE_EW_GREEN;
                        else
                            current_state <= STATE_NS_GREEN;
                    end
                end

                default: begin
                    current_state <= STATE_NS_GREEN;
                    timer         <= 0;
                end
            endcase
        end
    end

    // Combinational Logic: Output Generation Based on the Current State
    always @(*) begin
        case (current_state)
            // NS Green: North–South is GREEN; therefore, East–West is explicitly RED.
            STATE_NS_GREEN: begin
                light_ns          = GREEN;  // GREEN using our defined parameter
                light_ew          = RED;    // Explicit RED
                pedestrian_signal = RED;    // Pedestrian signal off (RED means "Don't Walk" here)
            end

            // NS Yellow: North–South is YELLOW; East–West remains RED.
            STATE_NS_YELLOW: begin
                light_ns          = YELLOW; // YELLOW signal
                light_ew          = RED;    // Explicit RED
                pedestrian_signal = RED;
            end

            // EW Green: East–West is GREEN; North–South gets explicit RED.
            STATE_EW_GREEN: begin
                light_ns          = RED;    // Explicit RED
                light_ew          = GREEN;  // GREEN
                pedestrian_signal = RED;
            end

            // EW Yellow: East–West shows YELLOW; North–South is explicitly RED.
            STATE_EW_YELLOW: begin
                light_ns          = RED;    // Explicit RED
                light_ew          = YELLOW; // YELLOW signal
                pedestrian_signal = RED;
            end

            // Pedestrian Crossing: Both directions are RED to allow safe crossing & pedestrian signal is "WALK".
            STATE_PEDESTRIAN: begin
                light_ns          = RED;    // Explicit RED
                light_ew          = RED;    // Explicit RED
                pedestrian_signal = WALK;   // Pedestrian signal active for Walk
            end

            // Default case: Set all signals to RED.
            default: begin
                light_ns          = RED;
                light_ew          = RED;
                pedestrian_signal = RED;
            end
        endcase
    end

endmodule
