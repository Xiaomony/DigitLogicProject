`timescale 1ns / 1ps
`include "constants.vh"

module digital_display#(parameter PERIOD=250_000)(input clk,
                       input [7:0]digit0, input [7:0]digit1, input [7:0]digit2, input [7:0]digit3,
                       input [7:0]digit4, input [7:0]digit5, input [7:0]digit6, input [7:0]digit7,
                       output reg [7:0]seg0, output reg [7:0]seg1, output reg [7:0]fragment);
reg [1:0] i = 1'b1;
wire devided_clk;
devide_frequency#(.PERIOD(PERIOD)) dev(.clk(clk), .tick(devided_clk));

initial begin
    seg0 <= digit0;
    seg1 <= digit4;
    fragment <= 8'b00010001;
end

always @(posedge clk) begin
    if (devided_clk) begin
        fragment <= 8'b0;
        fragment[i] <= 1'b1;
        fragment[i+4] <= 1'b1;
        i <= i+1;
        
        case (i)
            2'b00: begin
                seg0 <= digit0;
                seg1 <= digit4;
            end
            2'b01: begin
                seg0 <= digit1;
                seg1 <= digit5;
            end
            2'b10: begin
                seg0 <= digit2;
                seg1 <= digit6;
            end
            2'b11: begin
                seg0 <= digit3;
                seg1 <= digit7;
            end
        endcase
    end
end

endmodule
