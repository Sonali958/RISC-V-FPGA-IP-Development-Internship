module pwm(
    input  wire        i_clk,
    input  wire        i_rst,
    input  wire        i_we,

    // Register Select
    input  wire [1:0]  i_addr,

    // CPU Write Data
    input  wire [31:0] i_wdata,

    // CPU Read Data
    output reg  [31:0] o_rdata,

    // PWM Output
    output wire        o_pwm
);

    // --------------------------------------------------
    // Internal Registers
    // --------------------------------------------------

    reg [31:0] ctrl_reg;
    reg [31:0] period_reg;
    reg [31:0] duty_reg;
    reg [31:0] status_reg;

    reg [31:0] pwm_counter;
    reg        pwm_raw;

    // --------------------------------------------------
    // Register Write Logic
    // --------------------------------------------------

    always @(posedge i_clk) begin
        if(i_rst) begin
            ctrl_reg    <= 32'b0;
            period_reg  <= 32'd1;      // Minimum valid period
            duty_reg    <= 32'b0;
            pwm_counter <= 32'b0;
        end
        else if(i_we) begin
            case(i_addr)
                2'b00: ctrl_reg   <= i_wdata;   // CTRL
                2'b01: period_reg <= i_wdata;   // PERIOD
                2'b10: duty_reg   <= i_wdata;   // DUTY
                2'b11: ;                        // STATUS is read-only
                default: ;
            endcase
        end
    end

    // --------------------------------------------------
    // PWM Counter
    // --------------------------------------------------

    always @(posedge i_clk) begin
        if(i_rst) begin
            pwm_counter <= 32'd0;
        end
        else if(ctrl_reg[0]) begin

            if(period_reg <= 1)
                pwm_counter <= 32'd0;
            else if(pwm_counter >= period_reg - 1)
                pwm_counter <= 32'd0;
            else
                pwm_counter <= pwm_counter + 1;

        end
        else begin
            pwm_counter <= 32'd0;
        end
    end

    // --------------------------------------------------
    // PWM Raw Signal Generation
    // --------------------------------------------------

    always @(*) begin
        if(duty_reg == 0)
            pwm_raw = 1'b0;
        else if(duty_reg >= period_reg)
            pwm_raw = 1'b1;
        else
            pwm_raw = (pwm_counter < duty_reg);
    end

    // --------------------------------------------------
    // PWM Output
    // --------------------------------------------------

    assign o_pwm = ctrl_reg[0] ?
                   (ctrl_reg[1] ? ~pwm_raw : pwm_raw)
                   : 1'b0;

    // --------------------------------------------------
    // STATUS Register Update
    // --------------------------------------------------

    always @(*) begin
        status_reg = 32'b0;

        // Bit 0 : RUNNING
        status_reg[0] = ctrl_reg[0];

        // Bits [31:16] : Current Counter Value
        status_reg[31:16] = pwm_counter[15:0];
    end

    // --------------------------------------------------
    // Read Logic
    // --------------------------------------------------

    always @(*) begin
        case(i_addr)
            2'b00: o_rdata = ctrl_reg;
            2'b01: o_rdata = period_reg;
            2'b10: o_rdata = duty_reg;
            2'b11: o_rdata = status_reg;
            default: o_rdata = 32'b0;
        endcase
    end

endmodule
