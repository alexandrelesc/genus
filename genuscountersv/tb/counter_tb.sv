`timescale 1ns/1ps

module counter_tb;

    logic clk;
    logic rst;
    logic m;
    logic [15:0] count;

    counter dut (
        .clk(clk),
        .rst(rst),
        .m(m),
        .count(count)
    );

    always #5 clk = ~clk;

    initial begin
        $display("==== Teste do Counter ====");
        clk = 0;
        rst = 0;
        m   = 1;

        #10;
        rst = 1;

        m = 1;
        #100;

        m = 0;
        #100;

        rst = 0;
        #10;
        rst = 1;

        #50;

        $display("==== Fim da simulação ====");
        $finish;
    end

    initial begin
        $monitor("Time=%0t | rst=%b m=%b count=%0d", 
                  $time, rst, m, count);
    end

endmodule
