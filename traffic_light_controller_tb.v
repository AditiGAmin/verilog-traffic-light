`timescale 1ns / 1ps

module traffic_light_controller_tb;

    reg clk;
    reg reset;
    reg sensor_ns;
    reg sensor_ew;
    wire [1:0] light_ns;
    wire [1:0] light_ew;
    wire [1:0] pedestrian_signal;
    
    // Instantiate the traffic light controller
    traffic_light_controller uut (
        .clk(clk),
        .reset(reset),
        .sensor_ns(sensor_ns),
        .sensor_ew(sensor_ew),
        .light_ns(light_ns),
        .light_ew(light_ew),
        .pedestrian_signal(pedestrian_signal)
    );

    initial begin
    $dumpfile("traffic_light_controller_tb.vcd");
    $dumpvars(0,traffic_light_controller_tb);
end
    
    // Clock generation: Toggle every 5 ns (10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus: Initialize inputs and drive sensor signals.
    initial begin
        // Start with reset active, sensors off.
        reset = 1;
        sensor_ns = 0;
        sensor_ew = 0;
        
        // Hold reset for 10 ns
        #10;
        reset = 0;
        
        // Normal operation without sensor disturbances.
        #1000;
        
        // Activate heavy North–South traffic: extend NS green time.
        sensor_ns = 1;
        #600;
        sensor_ns = 0;
        #200;
        // Activate heavy East–West traffic: extend EW green time.
        sensor_ew = 1;
        #600;
        sensor_ew = 0;
        
        // Let simulation run for additional cycles.
        #500;
        
        $finish;
    end

    // Monitor output signals during simulation.
    initial begin
        $monitor("Time %0t | NS Light: %b | EW Light: %b | Pedestrian Signal: %b",
                 $time, light_ns, light_ew, pedestrian_signal);
    end

endmodule
