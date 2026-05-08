`timescale 1ns / 1ps

module digit_display_tb();
reg clk = 1'b0;
reg [7:0]digit0 = 8'b00000001;
reg [7:0]digit1 = 8'b00000010;
reg [7:0]digit2 = 8'b00000100;
reg [7:0]digit3 = 8'b00001000;
reg [7:0]digit4 = 8'b00010000;
reg [7:0]digit5 = 8'b00100000;
reg [7:0]digit6 = 8'b01000000;
reg [7:0]digit7 = 8'b10000000;

wire [7:0]seg0;
wire [7:0]seg1;
wire [7:0]fragment;

digital_display#(.PERIOD(5)) digits(.clk(clk),
                .digit0(digit0), .digit1(digit1), .digit2(digit2), .digit3(digit3),
                .digit4(digit4), .digit5(digit5), .digit6(digit6), .digit7(digit7),
                .seg0(seg0), .seg1(seg1), .fragment(fragment));
integer i;
initial begin
    for (i=0;i<100;i=i+1) begin
        clk<=1'b1;
        #1;
        clk<=1'b0;
        #1;
    end
    $finish;
end

endmodule
