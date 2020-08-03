`timescale 1ns / 1ps

module top(
    input reset,
    input sysclk,
    output [3:0] an,
    output [7:0] cathodes,
    output [7:0] leds
    );
wire ctrlclk, memclk;
clk_wiz_0 c(.clk_in1(sysclk),.clk_out1(ctrlclk),.clk_mem(memclk));
CPU cpu1(.reset(reset),.clk_cpu(ctrlclk),.clk_mem(memclk),.Leds(leds),.cathodes(cathodes),.an(an));

endmodule
