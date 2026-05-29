`timescale 1ns / 1ps
`include "constants.vh"

module keyboard_input(
        input clk,
        input ps2_clk,
        input ps2_data,
        output reg signal,
        output reg [3:0]keycode
        // ,output reg [1:0]led,
        // output reg [7:0]debug
        );

reg [3:0] i = 4'b0;
reg [7:0] scancode= 1'b0;
reg parity_xor = 1'b0;
reg extended = 1'b0;
reg releasing = 1'b0;

reg [1:0]clk_buffer = 2'b11;
reg [1:0]data_buffer = 2'b11;
wire synced_data = data_buffer[1];

initial begin
    keycode<=`KEY_NONE;
    // led[0] <= 1'b1;
    // led[1] <= 1'b1;
end

// 当ps2_clk下降沿来临的时候读取ps2_data
always @(posedge clk) begin
    // led[0] <= led[0] && ps2_clk;
    // led[1] <= led[1] && ps2_data;

    clk_buffer <= {clk_buffer[0], ps2_clk};
    data_buffer <= {data_buffer[0], ps2_data};
    if (clk_buffer[1] & ~clk_buffer[0]) begin
        // ps2_clk下降沿到来
        if (~synced_data && i == 1'b0) begin
            // start scanning
            i <= 1'b1;
            parity_xor <= 1'b0;
        end else if (i>= 1'b1 && i<= 4'b1000) begin
            scancode[i-1] <= synced_data;
            parity_xor <= parity_xor ^ synced_data;
            i <= i + 1'b1;
        end else if (i == 4'b1001 && (synced_data ^ parity_xor)) begin
            // 奇校验,8位扫描出来的data和奇校验位加起来要是奇数
            i<= 4'b1010;
        end else if (i == 4'b1010 && synced_data) begin
            // debug <= scancode;
            if (releasing) 
                keycode <= `KEY_NONE;
            else
                begin
                    signal <= 1'b1;
                    case (scancode)
                        `SC_EXTEND: begin
                            extended <= 1'b1;
                            signal <= 1'b0;
                         end
                        `SC_RELEASE: begin
                            releasing <= 1'b1;
                            signal <= 1'b0;
                         end
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
                        
                        `SC_J: keycode <= `KEY_DOWN;
                        `SC_K: keycode <= `KEY_UP;
                        `SC_UP: keycode <= `KEY_UP;
                        `SC_DOWN: keycode <= `KEY_DOWN;
                        default: begin
                            keycode <= `KEY_NONE;
                            signal <= 1'b0;
                        end
                    endcase
                end
            
            // stop scanning
            i <= 1'b0;
            if (scancode != `SC_RELEASE && scancode != `SC_EXTEND) begin
                releasing <= 1'b0;
                extended <= 1'b0;
            end
            scancode <= 1'b0;
            parity_xor <= 1'b0;
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
        // keycode <= `KEY_NONE;
    end
end

endmodule
