
module top (
    input  wire CLOCK_50,

    input  wire [1:0] KEY,
    input  wire [4:0] SW,  //	ahora usamos SW0 a SW4

    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,

    output wire [9:0] LEDR
);

    wire reset;

    wire pause_pulse;
    wire inc_pulse;
    wire dec_pulse;

    wire tick;
    wire enable;

    wire signed [8:0] count;
    wire [1:0] state;

    // KEY0: reset activo en bajo
    assign reset = ~KEY[0];

    // Habilitar ticks solo fuera de PAUSA
    assign enable = (state != 2'd0);

    // KEY1: PAUSA
    button_onepulse u_pause (
        .clk(CLOCK_50),
        .reset(reset),
        .button_n(KEY[1]),
        .press_pulse(pause_pulse)
    );

    //  SW3 ahora controla UP
    button_onepulse u_inc (
        .clk(CLOCK_50),
        .reset(reset),
        .button_n(~SW[3]),
        .press_pulse(inc_pulse)
    );

    // SW4 ahora controla DOWN
    button_onepulse u_dec (
        .clk(CLOCK_50),
        .reset(reset),
        .button_n(~SW[4]),
        .press_pulse(dec_pulse)
    );

    // tres switches controlan velocidad
    tick_generator u_tick (
        .clk(CLOCK_50),
        .reset(reset),
        .enable(enable),
        .speed_sel(SW[2:0]),
        .tick(tick)
    );

    signed_counter_fsm u_fsm (
        .clk(CLOCK_50),
        .reset(reset),
        .tick(tick),
        .pause_pulse(pause_pulse),
        .inc_pulse(inc_pulse),
        .dec_pulse(dec_pulse),
        .count(count),
        .state(state)
    );

    // Displays
    signed_display_9bit u_display (
        .value(count),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3)
    );

    // LED de estado
    assign LEDR[0] = (state == 2'd0);
    assign LEDR[1] = (state == 2'd1);
    assign LEDR[2] = (state == 2'd2);

    // CAMBIO 5: mostrar los 3 switches de velocidad
    assign LEDR[5:3] = SW[2:0];

    assign LEDR[8:6] = 3'b000;
    assign LEDR[9] = ~reset;

endmodule
