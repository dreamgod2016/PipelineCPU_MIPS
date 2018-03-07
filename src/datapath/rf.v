module rf(
    //input clk,
    input RegWrite,//写入信号
    
    input [4:0] ReadAddr1,
    input [4:0] ReadAddr2,
    input [4:0] WriteAddr,
    input [31:0] WriteData,

    output [31:0] ReadData1,
    output [31:0] ReadData2

);

    reg[31:0] register[31:0];
    integer i; 

    initial
    begin
        
        for(i = 0; i<32; i=i+1)
            register[i] = 0;
    end

    always @(*) begin
        if (WriteAddr!=0 && RegWrite) 
        begin
            // 有写入
            register[WriteAddr] = WriteData;
        end
    end

    assign ReadData1 = register[ReadAddr1] ;
    assign ReadData2 = register[ReadAddr2] ;

endmodule