`timescale 1ns / 1ps
`include "constants.vh"

module led_display #(parameter TIME_COUNT=10000000)(input clk, input [1:0]state, output reg [7:0]led_out);
reg blink_state = 1'b0;
reg [7:0] chasing_led = 8'b11100000;

wire devided_freq_2Hz;
devide_frequency#(.PERIOD(TIME_COUNT * 5)) dev_2Hz(.clk(clk), .tick(devided_freq_2Hz));
wire devided_freq_10Hz;
devide_frequency#(.PERIOD(TIME_COUNT)) dev_10Hz(.clk(clk), .tick(devided_freq_10Hz));

always @(posedge clk) begin
    case (state)
        `LED_LEFT: led_out <= 8'b10000000;
        `LED_RIGHT: led_out <= 8'b1;
        `LED_WARNING: begin
            if (devided_freq_2Hz) begin
                blink_state <= ~blink_state;
                if (blink_state)
                    led_out <= 8'b11111111;
                else
                    led_out <= 8'b0;
            end
         end
         `LED_CHASING: begin
            led_out <= chasing_led;
            if (devided_freq_10Hz)
                chasing_led <= {chasing_led[0],chasing_led[7:1]};
         end
    endcase
    if (state != `LED_CHASING)
        chasing_led <= 8'b11100000;
end

endmodule
