`timescale 1ns / 1ps
`include "constants.vh"

module keyboard_input_tb();
reg clk = 1'b0;
reg ps2_clk = 1'b1;
reg ps2_data;
wire signal;
wire [3:0] keycode;
keyboard_input keyboard(
                    .clk(clk), .ps2_clk(ps2_clk), .ps2_data(ps2_data),
                    .signal(signal), .keycode(keycode));

//reg [10:0] data;
task send_bits;
input [10:0]data;
integer i,j;
begin
    for (i=0;i<=10;i=i+1) begin
        ps2_data<=data[i];
        ps2_clk<=1'b1;
        
        clk<=1'b1;
        #1;
        clk<=1'b0;
        #1;
        
        ps2_clk<=1'b0;
        
        for (j=1;j<=4;j=j+1) begin
            clk<=1'b1;
            #1;
            clk<=1'b0;
            #1;
        end
    end
end
endtask

initial begin
    // test key 0
    send_bits({2'b10, `SC_0, 1'b0});
    #20;
    // test key uparrow
    send_bits({2'b10, `SC_EXTEND, 1'b0});
    send_bits({2'b10, `SC_UP, 1'b0});
    #20;
    // test release key (signal shouldn't be triggered this time)
    send_bits({2'b10, `SC_EXTEND, 1'b0});
    send_bits({2'b11, `SC_RELEASE, 1'b0});
    send_bits({2'b10, `SC_UP, 1'b0});
    #20;
    $finish;
end

endmodule
