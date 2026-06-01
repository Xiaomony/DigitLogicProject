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
    parameter WAIT_PICKUP = 4;
    parameter STATE_PROFIT = 5;
    parameter STATE_ERROR = 6;
    parameter STATE_VERIFY_PASSWD = 7;

    parameter ERR_PICK = 0;
    parameter ERR_PAY = 1;
    parameter ERR_OUT_OF_STOCK = 2;
    parameter ERR_OFF_SALE = 3;
    parameter ERR_PASS = 4;

    reg [2:0] error_code = 0;
    reg [2:0] state;
    reg [2:0] return_state;
    reg [2:0] pending_operation;

    reg [2:0] list_operation;
    reg [6:0] list_detail;

    reg [2:0] countdown = 0;
    reg [31:0] wait_counter = 0;
    reg waiting_pickup = 0;
    reg [3:0] pending_drink = 0;
    
    reg confirm_sale;
    reg [3:0] confirm_drink;

    reg [12:0] profit;
    wire warning;


    wire [6:0] current_price;
    wire [3:0] current_drink;
    wire buy_access;

    wire [31:0] input_value;
    reg [31:0] input_value_reg = 0;

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
    reg error_return_flag=0;

    function [7:0] to_seg;
        input [3:0] num;
        begin
            case(num)
                // 0: to_seg = `DIGIT_0;
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

    keyboard_input ki(
        .clk(clk),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .signal(key_signal),
        .keycode(keycode)
    );
    wire inventory;
    wire on_sale;
    drink_list dl(
        .clk(clk),
        .manager(manager_mode),
        .operation(list_operation),
        .op_detail(list_detail),
        .confirm_sale(confirm_sale),
        .confirm_drink(confirm_drink),
        .warning(warning),
        .buy_success(buy_success),

        .crr_have_inventory(inventory),
        .on_sale(on_sale),

        .current_price(current_price),
        .current_drink(current_drink),
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
        profit = 0;
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
         confirm_sale <= 0;

        if(state == WAIT_PICKUP)
        begin
                // 1秒计时
                if(wait_counter < 100_000_000 - 1)
                    begin
                    wait_counter <= wait_counter + 1;
                    end
                else
                    begin
                    wait_counter <= 0;

                    if(countdown > 0)
                    begin
                        countdown <= countdown - 1;
                    end
                    end

                // 用户确认取货
                if(key_signal && keycode == `KEY_ENTER)
                begin

                confirm_sale <= 1;
                confirm_drink <= pending_drink;

                profit <= profit + current_price;

                state <= STATE_SALE;

                end

                // 超时未取货
                else if(countdown == 0)
                begin
                    // TODO: Error
                    wait_counter <= 0;
                    error_code <= ERR_PICK;
                    state <= STATE_ERROR;
                end
        end

        else if (state == STATE_ERROR) begin
                if(wait_counter < 200_000_000 - 1)
                    begin
                        wait_counter <= wait_counter + 1;
                    end
                else
                    begin
                        wait_counter <= 0;
                        if (error_return_flag)
                            state <= STATE_MENU;
                        else
                            state <= STATE_SALE;
                        error_return_flag <= 0;
                    end
        end else if (state == STATE_VERIFY_PASSWD) begin
            if(input_value_reg == 12345678) begin
                state <= STATE_PROFIT;
                manager_mode <= 1;
            end else begin
                wait_counter <= 0;
                error_code <= ERR_PASS;
                error_return_flag <= 1;
                state <= STATE_ERROR;
            end
        end

        else if(key_signal) begin

            case(state)

                STATE_MENU:
                begin

                    if(keycode == `KEY_1) begin
                        state <= STATE_SALE;
                        manager_mode <= 0;
                    end

                    else if(keycode == `KEY_2) begin
                        // state <= STATE_PROFIT;
                        // manager_mode <= 1;
                        
                        return_state <= STATE_VERIFY_PASSWD;
                        pending_operation <= `OP_NONE;
                        input_operation <= `INPUT_CLEAN;
                        state <= STATE_INPUT;
                    end

                end

                // STATE_VERIFY_PASSWD:
                // begin
                //     if(input_value_reg == 12345678) begin
                //         state <= STATE_PROFIT;
                //         manager_mode <= 1;
                //     end else begin
                //         wait_counter <= 0;
                //         error_code <= ERR_PASS;
                //         error_return_flag <= 1;
                //         state <= STATE_ERROR;
                //     end
                // end

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
                            if (inventory && on_sale) begin
                                return_state <= STATE_SALE;
                                pending_operation <= `OP_CONFIRM;
                                input_operation <= `INPUT_CLEAN;
                                state <= STATE_INPUT;
                            end else begin
                                wait_counter <= 0;
                                if (!on_sale)
                                    error_code <= ERR_OFF_SALE;
                                else error_code <= ERR_OUT_OF_STOCK;
                                state <= STATE_ERROR;
                            end
                        end

                    endcase

                end

                STATE_MANAGER:
                begin

                    case(keycode)

                        `KEY_ESC:
                            state <= STATE_PROFIT;

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

                STATE_PROFIT:
                begin
                    if(keycode == `KEY_ESC)
                        state <= STATE_MENU;
                    else if(keycode == `KEY_ENTER)
                        state <= STATE_MANAGER;
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
                            input_value_reg <= input_value;
                            input_operation <= `INPUT_CLEAN;

                            if(pending_operation == `OP_CONFIRM) begin
                                // 支付成功
                                if (input_value[6:0] >= current_price && !warning) begin
                                    pending_drink <= current_drink;

                                    countdown <= 5;
                                    wait_counter <= 0;

                                    state <= WAIT_PICKUP;
                                end else begin
                                    // 余额不足，返回销售界面
                                    wait_counter <= 0;
                                    error_code <= ERR_PAY;
                                    state <= STATE_ERROR;
                                end

                            end else begin
                                state <= return_state;
                            end

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
            // STATE_INPUT:   led_state <= `LED_RIGHT;
            WAIT_PICKUP:  led_state <= `LED_CHASING;
            STATE_ERROR:   led_state <= `LED_WARNING;
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

             WAIT_PICKUP:
             begin
                case(countdown)
                    0: digit0 = `DIGIT_0;
                    1: digit0 = `DIGIT_1;
                    2: digit0 = `DIGIT_2;
                    3: digit0 = `DIGIT_3;
                    4: digit0 = `DIGIT_4;
                    5: digit0 = `DIGIT_5;
                default:
                    digit0 = `DIGIT_OFF;
                endcase

                digit1 = `DIGIT_OFF;
                digit2 = `DIGIT_OFF;
                digit3 = `DIGIT_OFF;
                digit4 = `DIGIT_OFF;
                digit5 = `DIGIT_OFF;
                digit6 = `DIGIT_OFF;
                digit7 = `DIGIT_OFF;
            end

            STATE_PROFIT:
            begin
                digit0 = profit % 10 == 0 ? `DIGIT_0 : to_seg(profit % 10);
                digit1 = to_seg((profit / 10) % 10);
                digit2 = to_seg((profit / 100) % 10);
                digit3 = to_seg((profit / 1000) % 10);
                digit7 = `DIGIT_p;
                digit6 = `DIGIT_r;
                digit5 = `DIGIT_o;
                digit4 = `DIGIT_F;
            end

            STATE_ERROR:
            begin
                if (error_code == ERR_PICK) begin
                    digit7 = `DIGIT_n;
                    digit6 = `DIGIT_o;
                    digit5 = `DIGIT_OFF;
                    digit4 = `DIGIT_OFF;
                end else begin
                    digit7 = `DIGIT_E;
                    digit6 = `DIGIT_r;
                    digit5 = `DIGIT_r;
                    digit4 = `DIGIT_OFF;
                end

                case (error_code)
                    ERR_PICK: begin
                        digit3 = `DIGIT_P;
                        digit2 = `DIGIT_I;
                        digit1 = `DIGIT_C;
                        digit0 = `DIGIT_OFF;
                    end
                    ERR_PAY: begin
                        digit3 = `DIGIT_P;
                        digit2 = `DIGIT_A;
                        digit1 = `DIGIT_y;
                        digit0 = `DIGIT_OFF;
                    end
                    ERR_OUT_OF_STOCK:
                    begin
                        digit3 = `DIGIT_S;
                        digit2 = `DIGIT_t;
                        digit1 = `DIGIT_o;
                        digit0 = `DIGIT_C;
                    end
                    ERR_OFF_SALE:
                    begin
                        digit3 = `DIGIT_O;
                        digit2 = `DIGIT_F;
                        digit1 = `DIGIT_S;
                        digit0 = `DIGIT_A;
                    end
                    ERR_PASS:
                    begin
                        digit3 = `DIGIT_P;
                        digit2 = `DIGIT_A;
                        digit1 = `DIGIT_S;
                        digit0 = `DIGIT_S;
                    end
                    default: 
                    begin
                        digit3 = `DIGIT_OFF;
                        digit2 = `DIGIT_OFF;
                        digit1 = `DIGIT_OFF;
                        digit0 = `DIGIT_OFF;
                    end
                endcase
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
