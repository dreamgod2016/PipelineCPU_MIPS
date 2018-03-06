module pc (
    input clk,
    input PCReSet,
    input[31:0] data,
    input isPCWrite,
    output reg[31:0] PC
);


    always @(posedge clk) 
    begin
        if (PCReSet) 
        begin
            // reset
            PC <= 32'h0000_3000;//？
        end
        else begin
            if(isPCWrite)
                PC = data[31:0];
        end
        //PC就是PC，不要加4这么奇葩了。
        // PC = PC + 4;
        // if (PCSet==1)
        //这里是跳转指令需要用的，左移拿过来了
        //所以这个控制信号应该是Branch和Zero同时控制的。
        //不过感觉这个不够明显，还是按照书上的图来吧。
        // begin
        //         for( i=0; i<30 ; i=i+1)
        //                 temp[31-i] = Address[29-i];
        //                 temp[0] = 0;
        //                 temp[1] = 0;
        //                 PC = PC + temp;
        // end
    end
    endmodule