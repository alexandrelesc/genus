module mux4_tb;

    // Sinais de teste (testbench)
    logic [3:0] d;
    logic [1:0] sel;
    logic       y;

    // Instância do DUT (Device Under Test)
    mux4 dut (
        .d(d),
        .sel(sel),
        .y(y)
    );

    // Geração de estímulos
    initial begin
        $display("==== Teste do MUX 4:1 ====");
        $display(" time | sel | d    | y ");
        $display("--------------------------");

        // Caso 1
        d = 4'b0001; sel = 2'b00; #10;
        $display("%4t | %b  | %b | %b", $time, sel, d, y);

        // Caso 2
        d = 4'b0010; sel = 2'b01; #10;
        $display("%4t | %b  | %b | %b", $time, sel, d, y);

        // Caso 3
        d = 4'b0100; sel = 2'b10; #10;
        $display("%4t | %b  | %b | %b", $time, sel, d, y);

        // Caso 4
        d = 4'b1000; sel = 2'b11; #10;
        $display("%4t | %b  | %b | %b", $time, sel, d, y);

        // Teste adicional com valores variados
        d = 4'b1101; sel = 2'b00; #10;
        $display("%4t | %b  | %b | %b", $time, sel, d, y);

        d = 4'b1101; sel = 2'b01; #10;
        $display("%4t | %b  | %b | %b", $time, sel, d, y);

        d = 4'b1101; sel = 2'b10; #10;
        $display("%4t | %b  | %b | %b", $time, sel, d, y);

        d = 4'b1101; sel = 2'b11; #10;
        $display("%4t | %b  | %b | %b", $time, sel, d, y);

        $display("==== Fim do teste ====");
        $finish;
    end

endmodule
