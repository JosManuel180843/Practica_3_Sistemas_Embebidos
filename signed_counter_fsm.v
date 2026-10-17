
module signed_counter_fsm (
    input wire clk,
    input wire reset,
    input wire tick,

    input wire pause_pulse,
    input wire inc_pulse,
    input wire dec_pulse,

    output reg signed [8:0] count,
    output reg [1:0] state
);

    localparam [1:0]
        S_PAUSE = 2'd0,
        S_UP    = 2'd1,
        S_DOWN  = 2'd2;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= -9'sd123;
            state <= S_PAUSE;
        end
        else begin

            // Prioridad de botones
            if (pause_pulse)
                state <= S_PAUSE;
            else if (inc_pulse)
                state <= S_UP;
            else if (dec_pulse)
                state <= S_DOWN;

            // Actualizar contador en cada tick
            if (tick) begin
                case (state)
                    S_UP:
                        count <= count + 9'sd1;

                    S_DOWN:
                        count <= count - 9'sd2;

                    default:
                        count <= count;
                endcase
            end
        end
    end

endmodule
