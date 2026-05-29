`timescale 1ns / 1ps
`include "constants.vh"

module input_mode(
    input clk,
    input [3:0] operation,

    output reg [31:0] value,

    output reg [7:0] digit0,
    output reg [7:0] digit1,
    output reg [7:0] digit2,
    output reg [7:0] digit3,
    output reg [7:0] digit4,
    output reg [7:0] digit5,
    output reg [7:0] digit6,
    output reg [7:0] digit7
);

    reg [3:0] digit_buffer [0:7];

    integer i;

    function [7:0] to_seg;
        input [3:0] num;
        begin
            case(num)
                4'd0: to_seg = `DIGIT_0;
                4'd1: to_seg = `DIGIT_1;
                4'd2: to_seg = `DIGIT_2;
                4'd3: to_seg = `DIGIT_3;
                4'd4: to_seg = `DIGIT_4;
                4'd5: to_seg = `DIGIT_5;
                4'd6: to_seg = `DIGIT_6;
                4'd7: to_seg = `DIGIT_7;
                4'd8: to_seg = `DIGIT_8;
                4'd9: to_seg = `DIGIT_9;
                default: to_seg = `DIGIT_OFF;
            endcase
        end
    endfunction

    initial begin

        value = 0;

        for(i = 0; i < 8; i = i + 1)
            digit_buffer[i] = 4'hF;

    end

    always @(posedge clk) begin

        case(operation)

            `INPUT_0,
            `INPUT_1,
            `INPUT_2,
            `INPUT_3,
            `INPUT_4,
            `INPUT_5,
            `INPUT_6,
            `INPUT_7,
            `INPUT_8,
            `INPUT_9:
            begin

                for(i = 7; i > 0; i = i - 1)
                    digit_buffer[i] <= digit_buffer[i - 1];

                digit_buffer[0] <= operation;

                value <= value * 10 + operation;

            end

            `INPUT_BACKSPACE:
            begin

                for(i = 0; i < 7; i = i + 1)
                    digit_buffer[i] <= digit_buffer[i + 1];

                digit_buffer[7] <= 4'hF;

                value <= value / 10;

            end

            `INPUT_CLEAN:
            begin

                for(i = 0; i < 8; i = i + 1)
                    digit_buffer[i] <= 4'hF;

                value <= 0;

            end

        endcase

    end

    always @(*) begin

        digit0 = (digit_buffer[0] == 4'hF) ? `DIGIT_OFF : to_seg(digit_buffer[0]);
        digit1 = (digit_buffer[1] == 4'hF) ? `DIGIT_OFF : to_seg(digit_buffer[1]);
        digit2 = (digit_buffer[2] == 4'hF) ? `DIGIT_OFF : to_seg(digit_buffer[2]);
        digit3 = (digit_buffer[3] == 4'hF) ? `DIGIT_OFF : to_seg(digit_buffer[3]);
        digit4 = (digit_buffer[4] == 4'hF) ? `DIGIT_OFF : to_seg(digit_buffer[4]);
        digit5 = (digit_buffer[5] == 4'hF) ? `DIGIT_OFF : to_seg(digit_buffer[5]);
        digit6 = (digit_buffer[6] == 4'hF) ? `DIGIT_OFF : to_seg(digit_buffer[6]);
        digit7 = (digit_buffer[7] == 4'hF) ? `DIGIT_OFF : to_seg(digit_buffer[7]);

    end

endmodule
