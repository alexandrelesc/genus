module mux4 (
    input  logic [3:0] d,     // 4 entradas
    input  logic [1:0] sel,   // seletor
    output logic       y      // saída
);

    always_comb begin
        case (sel)
            2'b00: y = d[0];
            2'b01: y = d[1];
            2'b10: y = d[2];
            2'b11: y = d[3];
            default: y = 1'b0;
        endcase
    end

endmodule
