`timescale 1ns/1ps

module tb_pwm;

    //------------------------------------------
    // Inputs
    //------------------------------------------
    reg         clk;
    reg         rstn;
    reg         we;
    reg         sel;
    reg [3:0]   addr;
    reg [31:0]  wdata;

    //------------------------------------------
    // Outputs
    //------------------------------------------
    wire [31:0] rdata;
    wire        pwm;

    //------------------------------------------
    // Instantiate PWM IP
    //------------------------------------------
    pwm DUT (
        .clk   (clk),
        .rstn  (rstn),
        .we    (we),
        .addr  (addr),
        .wdata (wdata),
        .sel   (sel),
        .rdata (rdata),
        .pwm   (pwm)
    );

    //------------------------------------------
    // Clock Generation (10 ns period)
    //------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    //------------------------------------------
    // Waveform Dump
    //------------------------------------------
    initial begin
        $dumpfile("pwm.vcd");
        $dumpvars(0, tb_pwm);
    end

    //------------------------------------------
    // Register Write Task
    //------------------------------------------
    task write_reg;
        input [3:0] reg_addr;
        input [31:0] reg_data;
        begin
            @(posedge clk);
            we    = 1;
            addr  = reg_addr;
            wdata = reg_data;

            @(posedge clk);
            we    = 0;
            addr  = 0;
            wdata = 0;
        end
    endtask

    //------------------------------------------
    // Register Read Task
    //------------------------------------------
    task read_reg;
        input [3:0] reg_addr;
        begin
            @(posedge clk);
            we   = 0;
            addr = reg_addr;

            @(posedge clk);
            $display("Time=%0t Addr=%h Read=%h",
                     $time,
                     reg_addr,
                     rdata);
        end
    endtask

    //------------------------------------------
    // Test Sequence
    //------------------------------------------
    initial begin

        rstn  = 0;
        we    = 0;
        sel   = 1;
        addr  = 0;
        wdata = 0;

        //-------------------------------
        // Reset
        //-------------------------------
        #20;
        rstn = 1;

        //-------------------------------
        // PERIOD = 10
        //-------------------------------
        write_reg(4'b0100,10);

        //-------------------------------
        // DUTY = 3
        //-------------------------------
        write_reg(4'b1000,3);

        //-------------------------------
        // Enable PWM
        //-------------------------------
        write_reg(4'b0000,32'h1);

        #200;

        //-------------------------------
        // Read STATUS
        //-------------------------------
        read_reg(4'b1100);

        //-------------------------------
        // Increase Duty
        //-------------------------------
        write_reg(4'b1000,6);

        #200;

        //-------------------------------
        // DUTY = PERIOD
        //-------------------------------
        write_reg(4'b1000,10);

        #150;

        //-------------------------------
        // DUTY = 0
        //-------------------------------
        write_reg(4'b1000,0);

        #150;

        //-------------------------------
        // Active-Low Mode
        //-------------------------------
        write_reg(4'b1000,4);
        write_reg(4'b0000,32'h3);

        #200;

        //-------------------------------
        // Disable PWM
        //-------------------------------
        write_reg(4'b0000,32'h0);

        #100;

        $display("\nSimulation Completed Successfully.");
        $finish;

    end

    //------------------------------------------
    // Monitor
    //------------------------------------------
    initial begin

        $display("---------------------------------------------------------------------");
        $display("Time  EN POL Counter Period Duty PWM");
        $display("---------------------------------------------------------------------");

        $monitor("%4t   %1b   %1b   %3d    %3d    %3d   %1b",
                 $time,
                 DUT.ctl[0],
                 DUT.ctl[1],
                 DUT.cnt,
                 DUT.per,
                 DUT.dut,
                 pwm);

    end

endmodule
