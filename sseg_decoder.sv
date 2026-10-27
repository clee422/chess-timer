// Seven-segment display
`define ZERO    7'b1000000
`define ONE     7'b1111001
`define TWO     7'b0100100
`define THREE   7'b0110000 
`define FOUR    7'b0011001
`define FIVE    7'b0010010
`define SIX     7'b0000010
`define SEVEN   7'b1111000
`define EIGHT   7'b0000000
`define NINE    7'b0010000

module sseg_decoder
(
    input   logic [3:0] digit,
    output  logic [6:0] display
);
    always @(*) begin
        case(digit)
            4'd0: display = `ZERO;
            4'd1: display = `ONE;
            4'd2: display = `TWO;
            4'd3: display = `THREE;
            4'd4: display = `FOUR;
            4'd5: display = `FIVE;
            4'd6: display = `SIX;
            4'd7: display = `SEVEN;
            4'd8: display = `EIGHT;
            4'd9: display = `NINE;
            default: display = 7'b1111111;
        endcase
    end
endmodule