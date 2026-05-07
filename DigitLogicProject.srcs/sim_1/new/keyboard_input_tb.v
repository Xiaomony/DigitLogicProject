`timescale 1ns / 1ps

module keyboard_input_tb();
reg clk = 1'b0;
reg ps2_clk = 1'b1;
reg ps2_data;
wire signal;
wire [3:0] keycode;
keyboard_input keyboard(
                    .clk(clk), .ps2_clk(ps2_clk), .ps2_data(ps2_data),
                    .signal(signal), .keycode(keycode));
initial begin
    clk <= 1'b1;
    #10;
    clk<= 1'b0;
    #10;
    
    ps2_clk <= 1'b0;
    clk<= 1'b1;
    #10;
    clk<= 1'b0;
    #10;
    
    clk<=1'b1;
    #10;
    
    $finish;
end

endmodule
