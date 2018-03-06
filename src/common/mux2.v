module mux2(
    input [31:0] data0,
    input [31:0] data1,
    input wire  signal,
    output reg [31:0] data
);

always @(*) 
begin
    case(signal)
        1'b0:
            data = data0;
        1'b1:
            data = data1;
        default:
            data = 32'b0;
    endcase
end
endmodule