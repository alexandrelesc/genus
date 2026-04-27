`timescale 1ns/1ps

module counter (
    input  logic        clk,
    input  logic        m,
    input  logic        rst,
    output logic [15:0] count
);

    always_ff @(posedge clk or negedge rst) begin
        if (!rst)
            count <= 16'd0;
        else if (m)
            count <= count + 16'd1;
        else
            count <= count - 16'd1;
    end

endmodule
