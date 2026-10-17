
`timescale 1ns/1ps

module TB_counter_9bit_top;

    reg CLOCK_50;
    reg BTN_RESET_N;
    reg BTN_PAUSE_N;
    reg BTN_INC_N;
    reg BTN_DEC_N;
    reg SW_FREQ;

    wire [6:0] HEX0, HEX1, HEX2, HEX3;
    wire [9:0] LEDR;

    // Senales internas para observar en waveform
    wire signed [8:0] count;
    wire [1:0] state;
    wire tick;

    // Instancia del TOP
    
	top DUT (
        .CLOCK_50(CLOCK_50),
        .BTN_RESET_N(BTN_RESET_N),
        .BTN_PAUSE_N(BTN_PAUSE_N),
        .BTN_INC_N(BTN_INC_N),
        .BTN_DEC_N(BTN_DEC_N),
        .SW_FREQ(SW_FREQ),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .LEDR(LEDR)
    );

    // Conectar senales internas al testbench
    assign count = DUT.count;
    assign state = DUT.state;
    assign tick  = DUT.tick;

    // Reloj de 50 MHz
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    // Pulsacion del boton INC
    task press_inc;
    begin
        @(negedge CLOCK_50);
        BTN_INC_N = 0;
        repeat (4) @(negedge CLOCK_50);
        DUT.u_inc.counter = 19'd499_999;
        repeat (3) @(negedge CLOCK_50);

        BTN_INC_N = 1;
        repeat (4) @(negedge CLOCK_50);
        DUT.u_inc.counter = 19'd499_999;
        repeat (3) @(negedge CLOCK_50);
    end
    endtask

    // Pulsacion del boton DEC
    task press_dec;
    begin
        @(negedge CLOCK_50);
        BTN_DEC_N = 0;
        repeat (4) @(negedge CLOCK_50);
        DUT.u_dec.counter = 19'd499_999;
        repeat (3) @(negedge CLOCK_50);

        BTN_DEC_N = 1;
        repeat (4) @(negedge CLOCK_50);
        DUT.u_dec.counter = 19'd499_999;
        repeat (3) @(negedge CLOCK_50);
    end
    endtask

    // Pulsacion del boton PAUSA
    task press_pause;
    begin
        @(negedge CLOCK_50);
        BTN_PAUSE_N = 0;
        repeat (4) @(negedge CLOCK_50);
        DUT.u_pause.counter = 19'd499_999;
        repeat (3) @(negedge CLOCK_50);

        BTN_PAUSE_N = 1;
        repeat (4) @(negedge CLOCK_50);
        DUT.u_pause.counter = 19'd499_999;
        repeat (3) @(negedge CLOCK_50);
    end
    endtask

    // Acelerar tick solo durante simulacion
    task fast_tick;
    begin
        @(negedge CLOCK_50);

        if (SW_FREQ)
            DUT.u_tick.counter = 26'd4_999_999;
        else
            DUT.u_tick.counter = 26'd49_999_999;

        repeat (3) @(negedge CLOCK_50);
    end
    endtask

    // Monitorear cambios en el contador
    initial begin
        $monitor(
            "Tiempo=%0t | count=%0d | state=%0d | tick=%b | SW=%b",
            $time, count, state, tick, SW_FREQ
        );
    end

    // Secuencia de pruebas
    initial begin

        BTN_RESET_N = 0;
        BTN_PAUSE_N = 1;
        BTN_INC_N   = 1;
        BTN_DEC_N   = 1;
        SW_FREQ     = 0;

        // RESET
        repeat (5) @(negedge CLOCK_50);
        BTN_RESET_N = 1;
        repeat (3) @(negedge CLOCK_50);

        // ASCENDENTE: 0 -> 3
        press_inc();
        fast_tick();
        fast_tick();
        fast_tick();

        // PAUSA: mantener 3
        press_pause();
        repeat (5) @(negedge CLOCK_50);

        // DESCENDENTE: 3 -> -1
        press_dec();
        fast_tick();
        fast_tick();
        fast_tick();
        fast_tick();

        // VELOCIDAD RAPIDA: -1 -> -3
        SW_FREQ = 1;
        fast_tick();
        fast_tick();

        // RESET FINAL
        BTN_RESET_N = 0;
        repeat (5) @(negedge CLOCK_50);
        BTN_RESET_N = 1;
        repeat (5) @(negedge CLOCK_50);

        $display("FIN DE LA SIMULACION");
        $stop;

    end

endmodule
