module chess_timer
(
    input logic CLOCK_50,
    input logic [3:0] KEY,
    input logic [9:0] SW,
    output logic [6:0] HEX0,
    output logic [6:0] HEX1,
    output logic [6:0] HEX2,
    output logic [6:0] HEX3,
    output logic [6:0] HEX4,
    output logic [6:0] HEX5,
    output logic [9:0] LEDR
);
    // States
    parameter SETUP         = 3'b000;
    parameter PLAYER1_TURN  = 3'b001;
    parameter PLAYER2_TURN  = 3'b010;
    parameter PLAYER1_WIN   = 3'b011;
    parameter PLAYER2_WIN   = 3'b100;


    logic [25:0] clk_count = 0;
    logic  [17:0] set_seconds = 0;

    logic [2:0] state = 3'b000;

    // Display digits in setup
    logic [3:0] setup_digit_hundred_thousands;
    logic [3:0] setup_digit_ten_thousands;
    logic [3:0] setup_digit_thousands;
    logic [3:0] setup_digit_hundreds;
    logic [3:0] setup_digit_tens;
    logic [3:0] setup_digit_ones;

    // Total time remaining for player
    logic [17:0] player1_seconds_remaining;
    logic [17:0] player2_seconds_remaining;

    // Time remaining digit for players in hours, minutes, seconds
    logic [3:0] player1_digit_hours_tens;
    logic [3:0] player1_digit_hours_ones;
    logic [3:0] player2_digit_hours_tens;
    logic [3:0] player2_digit_hours_ones;
    
    logic [3:0] player1_digit_minutes_tens;
    logic [3:0] player1_digit_minutes_ones;
    logic [3:0] player2_digit_minutes_tens;
    logic [3:0] player2_digit_minutes_ones;

    logic [3:0] player1_digit_seconds_tens;
    logic [3:0] player1_digit_seconds_ones;
    logic [3:0] player2_digit_seconds_tens;
    logic [3:0] player2_digit_seconds_ones;

    // Signal sent to seven-segment display
    logic [3:0] display_hundred_thousands;
    logic [3:0] display_ten_thousands;
    logic [3:0] display_thousands;
    logic [3:0] display_hundreds;
    logic [3:0] display_tens;
    logic [3:0] display_ones;


    always_ff @(posedge CLOCK_50) begin
        if (!KEY[1]) begin
            state <= SETUP;
        end
        else begin
            case(state)
                SETUP:          begin
                                    if (!KEY[0] || !KEY[3]) begin
                                        player1_seconds_remaining <= SW[9:0] * 60;
                                        player2_seconds_remaining <= SW[9:0] * 60;

                                        if (!KEY[0])
                                            state <= PLAYER1_TURN;
                                        else if (!KEY[3])
                                            state <= PLAYER2_TURN;
                                    end
                                    else begin
                                        state <= SETUP;
                                    end
                                    display_hundred_thousands <=    setup_digit_hundred_thousands;
                                    display_ten_thousands <=        setup_digit_ten_thousands;
                                    display_thousands <=            setup_digit_thousands;
                                    display_hundreds <=             setup_digit_hundreds;
                                    display_tens <=                 setup_digit_tens;
                                    display_ones <=                 setup_digit_ones;
                                    LEDR[9:0] = SW[9:0];
                                    clk_count <=                    0;
                                end
                PLAYER1_TURN:   begin
                                    if (clk_count == 49_999_999) begin
                                        clk_count <= 0;
                                        player1_seconds_remaining <= player1_seconds_remaining - 1;
                                    end
                                    if (!KEY[0])
                                        state <= PLAYER2_TURN;
                                    else if (player1_seconds_remaining == 0)
                                        state <= PLAYER2_WIN;
                                    else
                                        state <= PLAYER1_TURN;
                                    display_hundred_thousands <=    player1_digit_hours_tens;
                                    display_ten_thousands <=        player1_digit_hours_ones;
                                    display_thousands <=            player1_digit_minutes_tens;
                                    display_hundreds <=             player1_digit_minutes_ones;
                                    display_tens <=                 player1_digit_seconds_tens;
                                    display_ones <=                 player1_digit_seconds_ones;
                                    LEDR[9:0] = 10'b0000000001;
                                    clk_count <= clk_count + 1;
                                end
                PLAYER2_TURN:   begin
                                    if (clk_count == 49_999_999) begin
                                        clk_count <= 0;
                                        player2_seconds_remaining <= player2_seconds_remaining - 1;
                                    end
                                    if (!KEY[3])
                                        state <= PLAYER1_TURN;
                                    else if (player2_seconds_remaining == 0)
                                        state <= PLAYER1_WIN;
                                    else
                                        state <= PLAYER2_TURN;
                                    display_hundred_thousands <=    player2_digit_hours_tens;
                                    display_ten_thousands <=        player2_digit_hours_ones;
                                    display_thousands <=            player2_digit_minutes_tens;
                                    display_hundreds <=             player2_digit_minutes_ones;
                                    display_tens <=                 player2_digit_seconds_tens;
                                    display_ones <=                 player2_digit_seconds_ones;
                                    LEDR[9:0] = 10'b1000000000;
                                    clk_count <= clk_count + 1;
                                end
                PLAYER1_WIN:    begin
                                    display_hundred_thousands <=    4'd0;
                                    display_ten_thousands <=        4'd0;
                                    display_thousands <=            4'd0;
                                    display_hundreds <=             4'd1;
                                    display_tens <=                 4'd1;
                                    display_ones <=                 4'd1;
                                    LEDR[9:0] = 10'b0000011111;
                                end
                PLAYER2_WIN:    begin
                                    display_hundred_thousands <=    4'd1;
                                    display_ten_thousands <=        4'd1;
                                    display_thousands <=            4'd1;
                                    display_hundreds <=             4'd0;
                                    display_tens <=                 4'd0;
                                    display_ones <=                 4'd0;
                                    LEDR[9:0] = 10'b1111100000;
                                end
                default: begin
                    display_hundred_thousands <=    4'd0;
                    display_ten_thousands <=        4'd0;
                    display_thousands <=            4'd0;
                    display_hundreds <=             4'd0;
                    display_tens <=                 4'd0;
                    display_ones <=                 4'd0; 
                    state <= SETUP;
                end
            endcase
        end
    end

    always_comb begin
        setup_digit_hundred_thousands = (SW[9:0] / 100000) % 10;
        setup_digit_ten_thousands =     (SW[9:0] / 10000) % 10;
        setup_digit_thousands =         (SW[9:0] / 1000) % 10;
        setup_digit_hundreds =          (SW[9:0] / 100) % 10;
        setup_digit_tens =              (SW[9:0] / 10) % 10;
        setup_digit_ones =              SW[9:0] % 10;

        player1_digit_hours_tens = player1_seconds_remaining / 36000;
        player1_digit_hours_ones = (player1_seconds_remaining / 3600) % 10;
        player2_digit_hours_tens = player2_seconds_remaining / 36000;
        player2_digit_hours_ones = (player2_seconds_remaining / 3600) % 10;

        player1_digit_minutes_tens = ((player1_seconds_remaining / 60) % 60) / 10;
        player1_digit_minutes_ones = ((player1_seconds_remaining / 60) % 60) % 10;
        player2_digit_minutes_tens = ((player2_seconds_remaining / 60) % 60) / 10;
        player2_digit_minutes_ones = ((player2_seconds_remaining / 60) % 60) % 10;

        player1_digit_seconds_tens = (player1_seconds_remaining % 60) / 10;
        player1_digit_seconds_ones = (player1_seconds_remaining % 60) % 10;
        player2_digit_seconds_tens = (player2_seconds_remaining % 60) / 10;
        player2_digit_seconds_ones = (player2_seconds_remaining % 60) % 10;
    end

    sseg_decoder hundred_thousands_decoder(
        .digit      (display_hundred_thousands),
        .display    (HEX5)
    );
    sseg_decoder ten_thousands_decoder(
        .digit      (display_ten_thousands),
        .display    (HEX4)
    );
    sseg_decoder thousands_decoder(
        .digit      (display_thousands),
        .display    (HEX3)
    );
    sseg_decoder hundreds_decoder(
        .digit      (display_hundreds),
        .display    (HEX2)
    );
    sseg_decoder tens_decoder(
        .digit      (display_tens),
        .display    (HEX1)
    );
    sseg_decoder ones_decoder(
        .digit      (display_ones),
        .display    (HEX0)
    );
endmodule