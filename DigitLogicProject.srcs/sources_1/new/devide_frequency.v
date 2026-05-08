`timescale 1ns / 1ps

module devide_frequency #(parameter PERIOD=250_000)(input clk, output tick);
integer counter = 0;
assign tick = counter >= PERIOD;

always @(posedge clk) begin
    if (counter >= PERIOD) begin
        counter <= 0;
    end else counter <= counter + 1; 
end

endmodule
