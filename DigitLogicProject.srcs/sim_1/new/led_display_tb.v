`timescale 1ns / 1ps
`include "constants.vh"

module led_display_tb();

reg clk = 1'b0;
reg [1:0]led_state = `LED_LEFT;
wire [7:0]led_out;
led_display#(.TIME_COUNT(2)) leds(.clk(clk), .state(led_state), .led_out(led_out));

task led_on(input [1:0]state, input integer clk_period_times);
integer i;
begin
    led_state <= state;
    for (i=0;i<=clk_period_times-1;i=i+1) begin
        clk<=1'b1;
        #1;
        clk<=1'b0;
        #1;
    end
end
endtask

initial begin
    led_on(`LED_LEFT,10);
    led_on(`LED_RIGHT,10);
    led_on(`LED_WARNING,100);
    led_on(`LED_CHASING,50);
    led_on(`LED_LEFT,10);
    $finish;
end

endmodule
