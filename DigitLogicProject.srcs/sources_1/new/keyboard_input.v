`timescale 1ns / 1ps
`include "constants.vh"

module keyboard_input(
        input clk,
        input ps2_clk,
        input ps2_data,
        output reg signal,
        output reg [3:0]keycode);

reg prev_ps2_clk = 1'b0;
reg [3:0] i = 3'b0;
reg [7:0] scancode= 1'b0;
reg parity_xor = 1'b0;
reg extended = 1'b0;
reg releasing = 1'b0;

// 当ps2_clk下降沿来临的时候读取ps2_data
always @(posedge clk) begin
    if (prev_ps2_clk & ~ps2_clk) begin
        // ps2_clk下降沿到来
        if (~ps2_data && i == 1'b0) begin
            // start scanning
            i <= 1'b1;
        end else if (i>= 1'b1 && i<= 4'b1000) begin
            scancode[i-1] <= ps2_data;
            parity_xor <= parity_xor ^ ps2_data;
            i <= i + 1'b1;
        end else if (i == 4'b1001 && (ps2_data ^ parity_xor)) begin
            // 奇校验,8位扫描出来的data和奇校验位加起来要是奇数
            i<= 4'b1010;
        end else if (i == 4'b1010 && ps2_data) begin
            if (releasing) 
                keycode <= `KEY_NONE;
            else
                case (scancode)
                    `SC_EXTEND: extended <= 1'b1;
                    `SC_RELEASE: releasing <= 1'b1;
                    `SC_ESC: keycode <= `KEY_ESC;
                    `SC_BACKSPACE: keycode <= `KEY_BACKSPACE;
                    `SC_ENTER: keycode <= `KEY_ENTER;
                    `SC_0: keycode <= `KEY_0;
                    `SC_1: keycode <= `KEY_1;
                    `SC_2: keycode <= `KEY_2;
                    `SC_3: keycode <= `KEY_3;
                    `SC_4: keycode <= `KEY_4;
                    `SC_5: keycode <= `KEY_5;
                    `SC_6: keycode <= `KEY_6;
                    `SC_7: keycode <= `KEY_7;
                    `SC_8: keycode <= `KEY_8;
                    `SC_9: keycode <= `KEY_9;
                    `SC_UP: if (extended) keycode <= `KEY_UP;
                            else keycode <= `KEY_NONE;
                    `SC_DOWN: if (extended) keycode <= `KEY_DOWN;
                            else keycode <= `KEY_NONE;
                    default:
                        keycode <= `KEY_NONE;
                endcase
            
            // stop scanning
            if (keycode != `KEY_NONE)
                signal <= 1'b1;
            i <= 1'b0;
            scancode <= 1'b0;
            
        end else begin
            // error occurs
            i <= 1'b0;
            scancode <= 1'b0;
            extended <= 1'b0;
            releasing <= 1'b0;
        end
    end else begin
        signal <=1'b0;
        if (i == 1'b0) begin
            scancode <= 1'b0;
            parity_xor <= 1'b0;
        end
        keycode <= `KEY_NONE;
    end
    prev_ps2_clk <= ps2_clk;
end

endmodule
