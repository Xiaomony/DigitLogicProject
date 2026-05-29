`timescale 1ns / 1ps

`include "constants.vh"

module top(
    input clk,
    input ps2_clk,
    input ps2_data,
    output [7:0] seg0,
    output [7:0] seg1,
    output [7:0] fragment,
    output [7:0] led_out
);
    reg manager_mode;
    reg [7:0] digit0;
    reg [7:0] digit1;
    reg [7:0] digit2;
    reg [7:0] digit3;
    reg [7:0] digit4;
    reg [7:0] digit5;
    reg [7:0] digit6;
    reg [7:0] digit7;

    parameter STATE_MENU = 0;
    parameter STATE_SALE = 1;
    parameter STATE_MANAGER = 2;
    parameter STATE_INPUT = 3;

    reg [2:0] state;
    reg [2:0] return_state;
    reg [2:0] pending_operation;

    reg [2:0] list_operation;
    reg [6:0] list_detail;

    wire [12:0] profit;
    wire warning;

    wire buy_success;
    wire [6:0] current_price;

    wire [31:0] input_value;

    wire [7:0] list_digit0;
    wire [7:0] list_digit1;
    wire [7:0] list_digit2;
    wire [7:0] list_digit3;
    wire [7:0] list_digit4;
    wire [7:0] list_digit5;
    wire [7:0] list_digit6;
    wire [7:0] list_digit7;

    wire [7:0] input_digit0;
    wire [7:0] input_digit1;
    wire [7:0] input_digit2;
    wire [7:0] input_digit3;
    wire [7:0] input_digit4;
    wire [7:0] input_digit5;
    wire [7:0] input_digit6;
    wire [7:0] input_digit7;

    reg [3:0] input_operation;

    wire key_signal;
    wire [3:0] keycode;

    reg [1:0] led_state;

    keyboard_input ki(
        .clk(clk),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .signal(key_signal),
        .keycode(keycode)
    );

    drink_list dl(
        .clk(clk),
        .manager(manager_mode),
        .operation(list_operation),
        .op_detail(list_detail),
        .profit(profit),
        .warning(warning),
        .buy_success(buy_success),
        .current_price(current_price),
        .digit0(list_digit0),
        .digit1(list_digit1),
        .digit2(list_digit2),
        .digit3(list_digit3),
        .digit4(list_digit4),
        .digit5(list_digit5),
        .digit6(list_digit6),
        .digit7(list_digit7)
    );

    input_mode im(
        .clk(clk),
        .operation(input_operation),
        .value(input_value),
        .digit0(input_digit0),
        .digit1(input_digit1),
        .digit2(input_digit2),
        .digit3(input_digit3),
        .digit4(input_digit4),
        .digit5(input_digit5),
        .digit6(input_digit6),
        .digit7(input_digit7)
    );

    digital_display #(.PERIOD(250_000)) dd(
        .clk(clk),
        .digit0(digit0),
        .digit1(digit1),
        .digit2(digit2),
        .digit3(digit3),
        .digit4(digit4),
        .digit5(digit5),
        .digit6(digit6),
        .digit7(digit7),
        .seg0(seg0),
        .seg1(seg1),
        .fragment(fragment)
    );

    led_display #(.TIME_COUNT(10_000_000)) ld(
        .clk(clk),
        .state(led_state),
        .led_out(led_out)
    );

    initial begin

        state = STATE_MENU;
        return_state = STATE_MENU;
        pending_operation = `OP_NONE;

        manager_mode = 0;

        list_operation = `OP_NONE;
        input_operation = `INPUT_CLEAN;

    end

    always @(posedge clk) begin

        list_operation <= `OP_NONE;
        input_operation <= 4'b1111;

        if(key_signal) begin

            case(state)

                STATE_MENU:
                begin

                    if(keycode == `KEY_1) begin
                        state <= STATE_SALE;
                        manager_mode <= 0;
                    end

                    else if(keycode == `KEY_2) begin
                        state <= STATE_MANAGER;
                        manager_mode <= 1;
                    end

                end

                STATE_SALE:
                begin

                    case(keycode)

                        `KEY_ESC:
                            state <= STATE_MENU;

                        `KEY_UP:
                            list_operation <= `OP_UP;

                        `KEY_DOWN:
                            list_operation <= `OP_DOWN;

                        `KEY_0,
                        `KEY_1,
                        `KEY_2,
                        `KEY_3,
                        `KEY_4,
                        `KEY_5,
                        `KEY_6,
                        `KEY_7,
                        `KEY_8,
                        `KEY_9:
                        begin
                            list_operation <= `OP_JUMP;
                            list_detail <= keycode - `KEY_0;
                        end

                        `KEY_ENTER:
                        begin
                            return_state <= STATE_SALE;
                            pending_operation <= `OP_CONFIRM;
                            input_operation <= `INPUT_CLEAN;
                            state <= STATE_INPUT;
                        end

                    endcase

                end

                STATE_MANAGER:
                begin

                    case(keycode)

                        `KEY_ESC:
                            state <= STATE_MENU;

                        `KEY_UP:
                            list_operation <= `OP_UP;

                        `KEY_DOWN:
                            list_operation <= `OP_DOWN;

                        `KEY_1:
                        begin
                            return_state <= STATE_MANAGER;
                            pending_operation <= `OP_MOD_INVENTORY;
                            input_operation <= `INPUT_CLEAN;
                            state <= STATE_INPUT;
                        end

                        `KEY_2:
                            list_operation <= `OP_MOD_SALE_STATE;

                        `KEY_3:
                        begin
                            return_state <= STATE_MANAGER;
                            pending_operation <= `OP_MOD_PRICE;
                            input_operation <= `INPUT_CLEAN;
                            state <= STATE_INPUT;
                        end

                    endcase

                end

                STATE_INPUT:
                begin

                    case(keycode)

                        `KEY_ESC:
                        begin
                            input_operation <= `INPUT_CLEAN;
                            state <= return_state;
                        end

                        `KEY_ENTER:
                        begin
                            list_operation <= pending_operation;
                            list_detail <= input_value[6:0];
                            input_operation <= `INPUT_CLEAN;
                            state <= return_state;
                        end

                        `KEY_BACKSPACE:
                            input_operation <= `INPUT_BACKSPACE;

                        `KEY_0,
                        `KEY_1,
                        `KEY_2,
                        `KEY_3,
                        `KEY_4,
                        `KEY_5,
                        `KEY_6,
                        `KEY_7,
                        `KEY_8,
                        `KEY_9:
                            input_operation <= keycode - `KEY_0;

                    endcase

                end

            endcase

        end

    end

    always @(posedge clk) begin

        if (warning)
            led_state <= `LED_WARNING;
        else if (buy_success)
            led_state <= `LED_LEFT;
        else case(state)
            STATE_MENU:    led_state <= `LED_CHASING;
            STATE_SALE:    led_state <= `LED_LEFT;
            STATE_MANAGER: led_state <= `LED_RIGHT;
//            STATE_INPUT:   led_state <= `LED_RIGHT;
        endcase

    end

    always @(*) begin

        case(state)

            STATE_MENU:
            begin

                digit7 = `DIGIT_1;
                digit6 = `DIGIT_S;
                digit5 = `DIGIT_A;
                digit4 = `DIGIT_L;

                digit3 = `DIGIT_2;
                digit2 = `DIGIT_S;
                digit1 = `DIGIT_U;
                digit0 = `DIGIT_p;

            end

            STATE_INPUT:
            begin

                digit0 = input_digit0;
                digit1 = input_digit1;
                digit2 = input_digit2;
                digit3 = input_digit3;
                digit4 = input_digit4;
                digit5 = input_digit5;
                digit6 = input_digit6;
                digit7 = input_digit7;

            end

            default:
            begin

                digit0 = list_digit0;
                digit1 = list_digit1;
                digit2 = list_digit2;
                digit3 = list_digit3;
                digit4 = list_digit4;
                digit5 = list_digit5;
                digit6 = list_digit6;
                digit7 = list_digit7;

            end

        endcase

    end

endmodule
