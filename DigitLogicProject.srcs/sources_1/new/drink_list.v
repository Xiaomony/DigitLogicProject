`timescale 1ns / 1ps

`include "constants.vh"

module drink_list(
    input clk,
    input manager,
    input [2:0] operation,
    input [6:0] op_detail,
    input confirm_sale,
    input [3:0] confirm_drink,
    output reg warning,

    output reg buy_success,
    output reg [6:0] current_price,
    output reg [3:0] current_drink,

    output reg [7:0] digit0,
    output reg [7:0] digit1,
    output reg [7:0] digit2,
    output reg [7:0] digit3,
    output reg [7:0] digit4,
    output reg [7:0] digit5,
    output reg [7:0] digit6,
    output reg [7:0] digit7
);

    parameter DRINK_NUM = 4;

    reg [6:0] drink_id [0:DRINK_NUM-1];
    reg [6:0] price [0:DRINK_NUM-1];
    reg [6:0] inventory [0:DRINK_NUM-1];
    reg sale_state [0:DRINK_NUM-1];

    reg [7:0] name_left [0:DRINK_NUM-1];
    reg [7:0] name_right [0:DRINK_NUM-1];

    reg [6:0] current;

    integer i;

    function [7:0] to_seg;
        input [3:0] num;
        begin
            case(num)
                0: to_seg = `DIGIT_0;
                1: to_seg = `DIGIT_1;
                2: to_seg = `DIGIT_2;
                3: to_seg = `DIGIT_3;
                4: to_seg = `DIGIT_4;
                5: to_seg = `DIGIT_5;
                6: to_seg = `DIGIT_6;
                7: to_seg = `DIGIT_7;
                8: to_seg = `DIGIT_8;
                9: to_seg = `DIGIT_9;
                default: to_seg = `DIGIT_OFF;
            endcase
        end
    endfunction

    initial begin

        drink_id[0] = 0;
        price[0] = 5;
        inventory[0] = 10;
        sale_state[0] = 1;
        name_left[0] = `DIGIT_c;
        name_right[0] = `DIGIT_o;

        drink_id[1] = 1;
        price[1] = 8;
        inventory[1] = 15;
        sale_state[1] = 1;
        name_left[1] = `DIGIT_j;
        name_right[1] = `DIGIT_u;

        drink_id[2] = 2;
        price[2] = 6;
        inventory[2] = 20;
        sale_state[2] = 1;
        name_left[2] = `DIGIT_t;
        name_right[2] = `DIGIT_E;

        drink_id[3] = 3;
        price[3] = 12;
        inventory[3] = 5;
        sale_state[3] = 1;
        name_left[3] = `DIGIT_n;
        name_right[3] = `DIGIT_L;

        current = 0;

        warning = 0;
        buy_success = 0;
        current_price = 0;

    end

    always @(posedge clk) begin

        warning <= 0;
        buy_success <= 0;
        current_drink = current;

        if(confirm_sale)
            begin
            if(inventory[confirm_drink] > 0)
                begin
                inventory[confirm_drink] <= inventory[confirm_drink] - 1;
                end
            end

        case(operation)

            `OP_UP:
            begin
                if(current == 0)
                    current <= DRINK_NUM - 1;
                else
                    current <= current - 1;
            end

            `OP_DOWN:
            begin
                if(current == DRINK_NUM - 1)
                    current <= 0;
                else
                    current <= current + 1;
            end

            `OP_JUMP:
            begin

                if(op_detail < DRINK_NUM)
                    current <= op_detail;
                else
                    warning <= 1;

            end

            `OP_CONFIRM:
            begin

                if(!sale_state[current])
                    warning <= 1;

                else if(inventory[current] == 0)
                    warning <= 1;

                else if(op_detail < price[current])
                    warning <= 1;

                else begin

                    current_price <= price[current];

                    buy_success <= 1;

                end

            end

            `OP_MOD_INVENTORY:
            begin

                if(manager)
                    inventory[current] <= op_detail;

            end

            `OP_MOD_SALE_STATE:
            begin

                if(manager)
                    sale_state[current] <= ~sale_state[current];

            end

            `OP_MOD_PRICE:
            begin

                if(manager)
                    price[current] <= op_detail;

            end

        endcase

    end

    always @(*) begin

        digit7 = to_seg(drink_id[current] / 10);
        digit6 = to_seg(drink_id[current] % 10);

        digit5 = name_left[current];
        digit4 = name_right[current];

        digit3 = to_seg(price[current] / 10);
        digit2 = to_seg(price[current] % 10);

        if(sale_state[current]) begin

            digit1 = to_seg(inventory[current] / 10);
            digit0 = to_seg(inventory[current] % 10);

        end
        else begin

            digit1 = `DIGIT_UNDERLINE;
            digit0 = `DIGIT_UNDERLINE;

        end

    end

endmodule
