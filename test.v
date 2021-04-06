`timescale 1ns / 1ps

module button(
    input btn,clk,
    output reg pulse
);
    reg preBtn;
    always @(posedge clk)
        preBtn<=btn;
    always @(posedge clk)
        if((!preBtn)&&btn)
            pulse=1;
        else
            pulse=0;
endmodule

module fsm #(parameter WIDTH = 7) (
    input [WIDTH-1: 0] d,
    input clk, rst, en,
    output [WIDTH-1: 0] f
);
    parameter START = 0, FIRST = 1, SECOND = 2, NORMAL = 3, HALT = 4;
    reg [2: 0] curState, nextState;
    reg [WIDTH-1: 0] curValue, lastValue;
    wire [WIDTH-1: 0] cur, last, next;
    wire [2: 0] add;
    wire z;
    reg [31: 0] count;
    wire pause;
    button btn(en, clk, pause);
    //part1
    always @(posedge clk) begin
        if (pause) begin
            case (curState)
                START: nextState = FIRST;
                FIRST: nextState = SECOND;
                SECOND: begin
                    nextState = NORMAL;
                end
                default: nextState = NORMAL;
            endcase
        end
        else nextState = curState;
    end
    
    
    
    //part2
    always @(posedge clk, posedge rst) begin
        if (rst) curState <= START;
        else curState <= nextState;
    end

    //part3
    alu alu(last, cur, add, next, z);
    assign add = 3'b000;
    assign last = lastValue;
    assign cur = curValue;
    assign f = curValue;
    always @(posedge clk) begin
        if (pause) begin
            case (curState)
                START: begin
                    curValue <= 0;
                    lastValue <= 0;
                end
                FIRST: begin
                    curValue <= d;
                    lastValue <= d;
                end
                SECOND: begin
                    curValue <= d;
                end
                NORMAL: begin
                    lastValue <= curValue;
                    curValue <= next;
                end
            endcase
        end
    end
endmodule

module alu #(parameter WIDTH = 7) (
    input[WIDTH-1:0] a, b,
    input[2:0] opcode,
    output reg [WIDTH-1:0] y,
    output z
);
    parameter ADD = 3'b000, SUB = 3'b001, AND = 3'b010, OR = 3'b011, XOR = 3'b100;
    assign z = (y == 0) ? 1 : 0;

    always @(*) begin
        case (opcode)
            ADD: y = a + b;
            SUB: y = a - b;
            AND: y = a & b;
            OR:  y = a | b;
            XOR: y = a ^ b;
            default: y = 0;
        endcase
    end
endmodule
