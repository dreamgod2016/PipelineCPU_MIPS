module mux(
    input wire [1:0] signal,
    input [31:0] data0,
    input [31:0] data1,
    input [31:0] data2,
    input [31:0] data3,
    output reg [31:0] data
);

always @(*) 
begin
    case(signal)
        2'b00:
            data = data0;
        2'b01:
            data = data1;
        2'b10:
            data = data2;
        2'b11:
            data = data3;
        default:
            data = 32'b0;
    endcase
end
endmodule