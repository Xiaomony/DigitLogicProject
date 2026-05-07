1. [用户操作行为](#用户操作行为)
2. [模块规划](#模块规划)
3. [分工](#分工)

# 用户操作行为

1. 使用键盘通过USB数据线连接并操作FPGA
2. FPGA启动后，进入主菜单页面，此时8个数码管分别显示`1SAL 2SUP`，最左侧和最右侧的LED亮起，按下数字键1进入销售模式(Sale)，按下数字键2进入管理模式(Supervisor)
3. 进入销售模式后，最左侧的LED灯亮起代表销售模式，此时8个数码管显示无管理权限的[饮料列表](#饮料列表)，用户按下`Esc`则返回主菜单
4. 进入管理模式后：
    - 最右侧的LED亮起，代表管理模式
    - 进入[输入状态](#输入状态)，用户输入密码，并检查，正确密码硬编码在代码里，为`12345678`，输入错误则进入[报错状态](#报错状态) (此部分为Bonus部分，可留到最后有时间再做)
    - 密码正确则进入正式的管理模式：左侧4个数码管显示当前的销售额，按`Esc`反回主菜单
    - 此时用户按下`Enter`则进入有管理权限的[饮料列表](#饮料列表)，在饮料列表中按`Esc`则返回显示销售额的状态

## 饮料列表

饮料列表状态分为有管理权限和无管理权限两种

- 共有行为：
  一共八个数码管，一次显示一种饮料的信息
    1. 最左侧两个显示饮料编号(最小为0，最大为99)
    2. 第3-4个显示饮料的英文简写，如co(cola)、ju(juice)……
    3. 第5-6个显示饮料的单价(最小为0，最大为99)
    4. 最右边两个显示剩余库存(最小为0，最大为99)，如果当前饮料为停售则显示两个下划线(`__`)
    5. 按下键盘的上下键翻动，显示上一个/下一个饮料
    6. 用户按下数字键，进入[输入状态](#输入状态)，确认后跳转到对应的饮料编号(若编号无效则进入[报错状态](#报错状态))
- 无管理权限：
    1. 用户按下`Enter`键后，判断是否停售，以及是否有库存，如果停售或者无库存，进入[报错状态](#报错状态)
    2. 如果未停售且有库存，则进入[输入状态](#输入状态)，用户输入自己的账户余额，若余额不足，进入[报错状态](#报错状态)
    3. 如果账户余额足够，则显示扣款后的余额1秒，然后进入取货状态
    4. 取货状态：
        - LED进入流水灯模式，等待5秒，如果用户按下`Enter`，则取货成功，将刚才的扣款纳入总收入，饮料库存量减1
        - 若5秒后仍未按下`Enter`，则进入[报错状态](#报错状态)，并且刚才的扣款不纳入总收入，饮料库存量不变
- 有管理权限：
    1. 按下数字1键，进入[输入状态](#输入状态)，修改剩余库存
    2. 按下数字2键，反转在售/停售状态
    3. 按下数字3键，进入[输入状态](#输入状态)，修改单价

## 输入状态

输入状态用于获取用户的数字输入，进入状态后，8个数码管全灭，用户按数字键则在最右侧亮起一个数字，再次按数字键则将前面的数字都左移一位，在最右侧数码管显示刚刚按下的数字，但按下`Backspace`的时候则删除最右侧的数字，按下`Enter`键确认输入，按`Esc`取消输入
例如，用户如果依次按下`123<Backspace>4`，则数码管应该顺次显示：

```
        1
        ↓
       12
        ↓
      123
        ↓
       12
        ↓
      124
```

## 报错状态

报错状态下，LED灯闪烁1秒

# 模块规划

## 全局常量

以下为全局常量，在其他文件中直接引用该文件(`` `include "constants.vh"``)
判断相等：``if keycode == `KEY_ESC begin ... end ``, 注意KEY_ESC前面有一个反引号
其中`KEYCODES`最后一个`KEY_NONE`为方便输入状态下无按键按下时定义的键码，`keyboard_input`的signal为0时也应该将keycode设置为`KEY_NONE`

```verilog
// constants.vh
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
```

## 主要逻辑

### 顶层模块

整个项目的顶层模块，输入参数视子模块所需要用的引脚决定，负责调度键盘的输入，判断模式和状态，决定LED和数码管的输出
主体思路参见[用户操作行为](#用户操作行为)

```verilog
module drink_machine(input clk, ...);
endmodule
```

### 饮料列表模块

其中`clk`为系统时钟，`manager`为1则拥有管理权限，`operation`为当前需要进行的操作(见[全局常量](#全局常量)，所有操作都应当只持续一个周期，然后置为`OP_NONE`)
`op_detail`(7bit, 最大为127):

1. 当修改库存时`op_detail`设置为新库存
2. 当修改单价时`op_detail`设置为新单价
3. 当跳转时`op_detail`为要跳转到的编号
4. 当确认购买时，`op_detail`为用户余额
5. 其余状态下忽略

`profit`为总销售额(12bit, 最小为0，最大为8191),`warning`为是否报错(报错时将其设置为1，且只持续一个时钟周期)
`digit0`~`digit7`为当前8个数码管需要显示的段信号(见[全局常量](#全局常量))

```verilog
module drink_list(input clk, input manager, input [2:0] operation, input [6:0]op_detail,
                  output [12:0]profit, output warning,
                  output [7:0]digit0, output [7:0]digit1, output [7:0]digit2, output [7:0]digit3,
                  output [7:0]digit4, output [7:0]digit5, output [7:0]digit6, output [7:0]digit7);
endmodule
```

### 输入模式

其中`clk`为系统时钟，`operation`为需要进行的操作(见[全局常量](#全局常量))
`digit0`~`digit7`为输入模式时8个数码管需要显示的段信号(见[全局常量](#全局常量))

```verilog
module input_mode(input clk, input [3:0] operation,
                  output [7:0]digit0, output [7:0]digit1, output [7:0]digit2, output [7:0]digit3,
                  output [7:0]digit4, output [7:0]digit5, output [7:0]digit6, output [7:0]digit7);
endmodule
```

## 输入输出与硬件交互

### 键盘输入

其中，`clk`为系统时钟，`ps2_clk`和`ps2_data`分别绑定FPGA的K5、L4引脚，当读取到有效的按键的时候，`signal`将在接下来的一个时钟周期被变为1，且`keycode`变为读取到的按键的自定义键码（见下方）

```verilog
module keyboard_input(input clk, input ps2_clk, input ps2_data, output signal, output [3:0]keycode);
endmodule
```

### 数码管显示

其中`clk`为系统时钟，`digit0`~`digit7`为8个数码管要显示的数字的段信号
而`seg0`对应FPGA的左侧4个数码管的段信号，`seg1`对应FPGA的右侧4个数码管的段信号，`fragment`对应片选信号

```verilog
module digital_display(input clk,
                       input [7:0]digit0, input [7:0]digit1, input [7:0]digit2, input [7:0]digit3,
                       input [7:0]digit4, input [7:0]digit5, input [7:0]digit6, input [7:0]digit7,
                       output [7:0]seg0, output [7:0]seg1, output [7:0]fragment);
endmodule
```

### LED状态

其中`clk`为系统时钟，`led_out`对应从左到右8个大LED的引脚，`state`为LED状态(见[全局常量](#全局常量))：

```verilog
module led_display(input clk, input [1:0]state, output [7:0]led_out);
endmodule
```

# 分工

1. 输入输出与硬件交互由一个人负责
2. 饮料列表和输入模式由一个人负责
3. 顶层模块以及引脚约束由一个人负责
