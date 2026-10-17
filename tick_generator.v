module tick_generator (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire [2:0] speed_sel,
    output reg tick
);


// o.15 ms = 7500 ciclos
// 3 s =150 000 000 ciclos
reg [27:0] counter;

wire [27:0] terminal_count =
    28'd7_499 +
    (speed_sel * 28'd21_427_500); //aumento por nivel

always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 28'd0;
        tick <= 1'b0;
    end
    else if (!enable) begin
        counter <= 28'd0;
        tick <= 1'b0;
    end
    else if (counter >= terminal_count) begin
        counter <= 28'd0;
        tick <= 1'b1;
    end
    else begin
        counter <= counter + 28'd1;
        tick <= 1'b0;
    end
end

endmodule