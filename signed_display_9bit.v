module signed_display_9bit (
    input  wire signed [8:0] value,

    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3
);

    wire [8:0] magnitude;

    wire [3:0] hundreds;
    wire [3:0] tens;
    wire [3:0] ones;

    // Si el numero es negativo, obtenemos su magnitud
    assign magnitude = value[8] ? (~value + 9'd1) : value;

    // Conversion binario -> decimal
    assign hundreds = magnitude / 9'd100;
    assign tens     = (magnitude % 9'd100) / 9'd10;
    assign ones     = magnitude % 9'd10;

    // Decodificadores de 7 segmentos
    sevenseg_decoder u_hex0 (
        .digit(ones),
        .seg(HEX0)
    );

    sevenseg_decoder u_hex1 (
        .digit(tens),
        .seg(HEX1)
    );

    sevenseg_decoder u_hex2 (
        .digit(hundreds),
        .seg(HEX2)
    );

    // HEX3 muestra "-" si el numero es negativo
    // DE10-Lite: segmentos activos en bajo
    assign HEX3 = value[8] ? 7'b0111111 :
                             7'b1111111;

endmodule