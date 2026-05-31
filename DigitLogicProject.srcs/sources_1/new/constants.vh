// 自定义键码
`ifndef KEY_CODES
`define KEY_CODES

`define KEY_ESC 4'b0
`define KEY_BACKSPACE 4'b1
`define KEY_0 4'b10
`define KEY_1 4'b11
`define KEY_2 4'b100
`define KEY_3 4'b101
`define KEY_4 4'b110
`define KEY_5 4'b111
`define KEY_6 4'b1000
`define KEY_7 4'b1001
`define KEY_8 4'b1010
`define KEY_9 4'b1011
`define KEY_UP 4'b1100
`define KEY_DOWN 4'b1101
`define KEY_ENTER 4'b1110
`define KEY_NONE 4'b1111

`endif

// LED状态
`ifndef LED_STATES
`define LED_STATES

`define LED_LEFT 2'b0       // 最左侧LED亮起，表示销售模式
`define LED_RIGHT 2'b1      // 最右侧LED亮起，表示管理模式
`define LED_WARNING 2'b10   // LED闪烁，报错模式
`define LED_CHASING 2'b11   // LED流水灯，等待取货
`endif

// 饮料列表模块的操作
`ifndef DRINK_LIST_OPERATION
`define DRINK_LIST_OPERATION

`define OP_NONE 3'b0                // 无操作
`define OP_CONFIRM 3'b1             // 确认购买
`define OP_UP 3'b10                 // 向下翻
`define OP_DOWN 3'b11               // 向上翻
`define OP_MOD_INVENTORY 3'b100     // 修改剩余库存
`define OP_MOD_SALE_STATE 3'b101    // 反转在售/停售状态
`define OP_MOD_PRICE 3'b110         // 修改单价
`define OP_JUMP 3'b111              // 跳转
`endif

// 各个数字/字母对应的数码管段选信号
`ifndef DIGIT_SEG
`define DIGIT_SEG

`define DIGIT_0 8'b11111100  
`define DIGIT_1 8'b01100000  
`define DIGIT_2 8'b11011010  
`define DIGIT_3 8'b11110010  
`define DIGIT_4 8'b01100110  
`define DIGIT_5 8'b10110110  
`define DIGIT_6 8'b10111110  
`define DIGIT_7 8'b11100000  
`define DIGIT_8 8'b11111110  
`define DIGIT_9 8'b11110110  

`define DIGIT_A 8'b11101110  
`define DIGIT_b 8'b00111110  
`define DIGIT_C 8'b10011100  
`define DIGIT_c 8'b00011010  
`define DIGIT_d 8'b01111010  
`define DIGIT_E 8'b10011110  
`define DIGIT_F 8'b10001110  
`define DIGIT_g 8'b11110110  
`define DIGIT_G 8'b10111100 
`define DIGIT_H 8'b01101110  
`define DIGIT_h 8'b00101110  
`define DIGIT_i 8'b00001000  
`define DIGIT_I 8'b00001100  
`define DIGIT_j 8'b01110000  
`define DIGIT_L 8'b00011100  
`define DIGIT_l 8'b00001100  
`define DIGIT_n 8'b00101010  
`define DIGIT_N 8'b11101100  
`define DIGIT_O 8'b11111100  
`define DIGIT_o 8'b00111010  
`define DIGIT_p 8'b11001110  
`define DIGIT_P 8'b11001110  
`define DIGIT_q 8'b11100110  
`define DIGIT_r 8'b00001010  
`define DIGIT_S 8'b10110110  
`define DIGIT_t 8'b00011110  
`define DIGIT_U 8'b01111100  
`define DIGIT_u 8'b00111000  
`define DIGIT_y 8'b01110110  

`define DIGIT_UNDERLINE 8'b00010000  
`define DIGIT_DASH      8'b00000010  
`define DIGIT_DP_ON     8'b00000001  
`define DIGIT_OFF       8'b00000000  

`endif

// 输入模式下的操作
`ifndef INPUT_MOD
`define INPUT_MOD

`define INPUT_0 4'd0        // 输入数字
`define INPUT_1 4'd1
`define INPUT_2 4'd2
`define INPUT_3 4'd3
`define INPUT_4 4'd4
`define INPUT_5 4'd5
`define INPUT_6 4'd6
`define INPUT_7 4'd7
`define INPUT_8 4'd8
`define INPUT_9 4'd9
`define INPUT_BACKSPACE 4'd10   // 删除最后一位
`define INPUT_CLEAN 4'd11       // 清除输入
`endif

// 扫描码, 只应当被keyboard_input.v使用
`ifndef SCAN_CODES
`define SCAN_CODES

`define SC_RELEASE     8'hF0
`define SC_EXTEND      8'hE0

`define SC_ESC         8'h08
`define SC_BACKSPACE   8'h66
`define SC_ENTER       8'h5A
`define SC_KP_ENTER    8'h79

`define SC_0           8'h45
`define SC_1           8'h16
`define SC_2           8'h1E
`define SC_3           8'h26
`define SC_4           8'h25
`define SC_5           8'h2E
`define SC_6           8'h36
`define SC_7           8'h3D
`define SC_8           8'h3E
`define SC_9           8'h46
`define SC_KP0         8'h70
`define SC_KP1         8'h69
`define SC_KP2         8'h72
`define SC_KP3         8'h7A
`define SC_KP4         8'h6B
`define SC_KP5         8'h73
`define SC_KP6         8'h74
`define SC_KP7         8'h6C
`define SC_KP8         8'h75
`define SC_KP9         8'h7D


`define SC_UP          8'h63
`define SC_DOWN        8'h60
`define SC_J           8'h3B
`define SC_K           8'h42

`endif