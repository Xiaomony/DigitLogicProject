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
`define KEY_NONE 4'b1110

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

`define DIGIT_0
`define DIGIT_1
`define DIGIT_2
`define DIGIT_3
// ...具体的值待填入，应为8bit(7段光管加上小数点)
// 请将所有数码管可能显示的字符的段选信号写在这里
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
