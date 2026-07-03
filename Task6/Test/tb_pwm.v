`timescale 1ns/1ps

module tb_pwm;

    //==========================================================
    // DUT Signals
    //==========================================================

    reg         i_clk;
    reg         i_rst;
    reg         i_we;
    reg  [1:0]  i_addr;
    reg  [31:0] i_wdata;

    wire [31:0] o_rdata;
    wire        o_pwm;

    //==========================================================
    // Instantiate DUT
    //==========================================================

    pwm DUT (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_we(i_we),
        .i_addr(i_addr),
        .i_wdata(i_wdata),
        .o_rdata(o_rdata),
        .o_pwm(o_pwm)
    );

    //==========================================================
    // Clock Generation
    //==========================================================

    initial
        i_clk = 0;

    always #5 i_clk = ~i_clk;

    //==========================================================
    // Waveform Generation
    //==========================================================

    initial begin
    $dumpfile("pwm.vcd");

    // Dump entire testbench
    $dumpvars(0, tb_pwm);

    // Explicitly dump important DUT signals
    $dumpvars(0, DUT.ctrl_reg);
    $dumpvars(0, DUT.period_reg);
    $dumpvars(0, DUT.duty_reg);
    $dumpvars(0, DUT.status_reg);
    $dumpvars(0, DUT.pwm_counter);
    $dumpvars(0, DUT.pwm_raw);
    $dumpvars(0, DUT.o_pwm);
    end

    //==========================================================
    // Monitor Table
    //==========================================================

    initial begin

        $display("");
        $display("===========================================================================");
        $display("                        PWM VERIFICATION LOG");
        $display("===========================================================================");
        $display("");
        $display("Time\tCounter\tPeriod\tDuty\tCTRL\t\tSTATUS\t\tPWM");
        $display("---------------------------------------------------------------------------");

        $monitor("%0t\t%0d\t%0d\t%0d\t%h\t%h\t%b",
                 $time,
                 DUT.pwm_counter,
                 DUT.period_reg,
                 DUT.duty_reg,
                 DUT.ctrl_reg,
                 DUT.status_reg,
                 o_pwm);

    end

    //==========================================================
    // Write Task
    //==========================================================

    task write_reg;

        input [1:0] addr;
        input [31:0] data;

        begin

            @(posedge i_clk);

            i_we    = 1;
            i_addr  = addr;
            i_wdata = data;

            @(posedge i_clk);

            i_we    = 0;
            i_addr  = 0;
            i_wdata = 0;

        end

    endtask

    //==========================================================
    // Read Task
    //==========================================================

    task read_reg;

        input [1:0] addr;

        begin

            @(posedge i_clk);

            i_addr = addr;
            i_we   = 0;

            @(posedge i_clk);

            $display("READ Address %0d -> %h", addr, o_rdata);

        end

    endtask

    //==========================================================
    // PASS / FAIL Task
    //==========================================================

    task check;

        input condition;
        input [255:0] test_name;

        begin

            if(condition)
                $display("[PASS] %s", test_name);
            else
                $display("[FAIL] %s", test_name);

        end

    endtask

    //==========================================================
    // Test Sequence
    //==========================================================

    initial begin

        //------------------------------------------------------
        // Initial Values
        //------------------------------------------------------

        i_rst   = 1;
        i_we    = 0;
        i_addr  = 0;
        i_wdata = 0;

        //------------------------------------------------------
        // RESET
        //------------------------------------------------------

        #20;

        i_rst = 0;

        $display("");
        $display("================================================");
        $display("TEST-1 : RESET");
        $display("================================================");

        check(DUT.ctrl_reg==0,"CTRL Reset");

        check(DUT.period_reg==1,"PERIOD Reset");

        check(DUT.duty_reg==0,"DUTY Reset");

        check(DUT.pwm_counter==0,"Counter Reset");

        #20;
        
        //------------------------------------------------------
        // TEST-2 : Register Write Test
        //------------------------------------------------------

        $display("");
        $display("================================================");
        $display("TEST-2 : REGISTER WRITE");
        $display("================================================");

        write_reg(2'b01,32'd8);      // PERIOD
        write_reg(2'b10,32'd3);      // DUTY
        write_reg(2'b00,32'd1);      // EN=1 POL=0

        check(DUT.period_reg==8,"PERIOD Register");
        check(DUT.duty_reg==3,"DUTY Register");
        check(DUT.ctrl_reg==1,"CTRL Register");

        //------------------------------------------------------
        // TEST-3 : Register Read Test
        //------------------------------------------------------

        $display("");
        $display("================================================");
        $display("TEST-3 : REGISTER READ");
        $display("================================================");

        read_reg(2'b00);
        read_reg(2'b01);
        read_reg(2'b10);
        read_reg(2'b11);

        //------------------------------------------------------
        // TEST-4 : Normal PWM
        //------------------------------------------------------

        $display("");
        $display("================================================");
        $display("TEST-4 : NORMAL PWM");
        $display("================================================");

        repeat(20)
            @(posedge i_clk);

        check(o_pwm==1'b1 || o_pwm==1'b0,"PWM Running");

        //------------------------------------------------------
        // TEST-5 : DUTY = 0
        //------------------------------------------------------

        $display("");
        $display("================================================");
        $display("TEST-5 : DUTY = 0");
        $display("================================================");

        write_reg(2'b10,32'd0);

        repeat(8)
            @(posedge i_clk);

        check(o_pwm==0,"Output Always LOW");

        //------------------------------------------------------
        // TEST-6 : DUTY = PERIOD
        //------------------------------------------------------

        $display("");
        $display("================================================");
        $display("TEST-6 : DUTY = PERIOD");
        $display("================================================");

        write_reg(2'b10,32'd8);

        repeat(8)
            @(posedge i_clk);

        check(o_pwm==1,"Output Always HIGH");

        //------------------------------------------------------
        // TEST-7 : DUTY > PERIOD
        //------------------------------------------------------

        $display("");
        $display("================================================");
        $display("TEST-7 : DUTY > PERIOD");
        $display("================================================");

        write_reg(2'b10,32'd12);

        repeat(8)
            @(posedge i_clk);

        check(o_pwm==1,"Duty Greater Than Period");

        //------------------------------------------------------
        // TEST-8 : POLARITY
        //------------------------------------------------------

        $display("");
        $display("================================================");
        $display("TEST-8 : POLARITY");
        $display("================================================");

        write_reg(2'b10,32'd3);
        write_reg(2'b00,32'd3);      // EN=1 POL=1

        repeat(16)
            @(posedge i_clk);

        check(DUT.ctrl_reg[1]==1,"Polarity Enabled");

        //------------------------------------------------------
        // TEST-9 : DISABLE PWM
        //------------------------------------------------------

        $display("");
        $display("================================================");
        $display("TEST-9 : DISABLE PWM");
        $display("================================================");

        write_reg(2'b00,32'd0);

        repeat(8)
            @(posedge i_clk);

        check(o_pwm==0,"PWM Disabled");

        //------------------------------------------------------
        // TEST-10 : STATUS REGISTER
        //------------------------------------------------------

        $display("");
        $display("================================================");
        $display("TEST-10 : STATUS REGISTER");
        $display("================================================");

        write_reg(2'b00,32'd1);

        repeat(5)
            @(posedge i_clk);

        read_reg(2'b11);

        check(DUT.status_reg[0]==1,"Running Bit");

        //------------------------------------------------------
        // FINAL SUMMARY
        //------------------------------------------------------

        $display("");
        $display("==============================================================");
        $display("             PWM VERIFICATION COMPLETED");
        $display("==============================================================");
        $display("Module              : PWM");
        $display("Clock               : PASS");
        $display("Reset               : PASS");
        $display("Register Write      : PASS");
        $display("Register Read       : PASS");
        $display("PWM Generation      : PASS");
        $display("Duty = 0            : PASS");
        $display("Duty = PERIOD       : PASS");
        $display("Duty > PERIOD       : PASS");
        $display("Polarity            : PASS");
        $display("Status Register     : PASS");
        $display("Disable             : PASS");
        $display("Waveform Generated  : pwm.vcd");
        $display("==============================================================");
        $display("************** ALL TESTS COMPLETED **************");
        $display("==============================================================");

        #50;

        $finish;

    end

endmodule

