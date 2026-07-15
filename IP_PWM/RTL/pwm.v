module pwm(
    input  wire        clk,
    input  wire        rstn,
    input  wire        we,

    // Register Select
    input  wire [3:0]  addr,

    // CPU Write Data
    input  wire [31:0] wdata,

    input  wire        sel,

    // CPU Read Data
    output reg  [31:0] rdata,

    // PWM Output
    output wire        pwm
);

    // --------------------------------------------------
    // Internal Registers
    // --------------------------------------------------

    reg [31:0] ctl;
    reg [31:0] per;
    reg [31:0] dut;
    reg [31:0] sta;

    reg [31:0] cnt;
    reg        pwm_raw;

    // --------------------------------------------------
    // Register Write Logic
    // --------------------------------------------------

    always @(posedge clk) begin
        if (!rstn) begin
            ctl <= 32'b0;
            per <= 32'd1;      // Minimum valid period
            dut <= 32'b0;
        end
        else if (we && sel) begin
            case (addr)
                4'b0000: ctl <= wdata;   // CTRL
                4'b0100: per <= wdata;   // PERIOD
                4'b1000: dut <= wdata;   // DUTY
                4'b1100: ;               // STATUS is read-only
                default: ;
            endcase
        end
    end

    // --------------------------------------------------
    // PWM Counter
    // --------------------------------------------------

    always @(posedge clk) begin
        if (!rstn) begin
            cnt <= 32'd0;
        end
        else if (ctl[0]) begin
            if (per <= 1)
                cnt <= 32'd0;
            else if (cnt >= (per - 1))
                cnt <= 32'd0;
            else
                cnt <= cnt + 1;
        end
        else begin
            cnt <= 32'd0;
        end
    end

    // --------------------------------------------------
    // PWM Raw Signal Generation
    // --------------------------------------------------

    always @(*) begin
        if (dut == 0)
            pwm_raw = 1'b0;
        else if (dut >= per)
            pwm_raw = 1'b1;
        else
            pwm_raw = (cnt < dut);
    end

    // --------------------------------------------------
    // PWM Output
    // --------------------------------------------------

    assign pwm = ctl[0] ?
                 (ctl[1] ? ~pwm_raw : pwm_raw)
                 : 1'b0;

    // --------------------------------------------------
    // STATUS Register Update
    // --------------------------------------------------

    always @(*) begin
        sta = 32'b0;

        // Bit 0 : RUNNING
        sta[0] = ctl[0];

        // Bits [31:16] : Current Counter Value
        sta[31:16] = cnt[15:0];
    end

    // --------------------------------------------------
    // Read Logic
    // --------------------------------------------------

    always @(*) begin
        rdata = 32'b0;

        if (sel && !we) begin
            case (addr)
                4'b0000: rdata = ctl;
                4'b0100: rdata = per;
                4'b1000: rdata = dut;
                4'b1100: rdata = sta;
                default: rdata = 32'b0;
            endcase
        end
    end


endmodule
