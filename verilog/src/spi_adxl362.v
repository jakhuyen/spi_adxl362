module spi_adxl362 (
  input clkIn,
  input rstIn,
  input misoIn,
  input [1:0] spiIntIn,
  output mosiOut,
  output sclkOut,
  output csLowOut
);

  wire rstW, rxRdyW;
  wire [7:0] rxDataW;
  
  reg enR, rdEnR, csR, cntRstR;
  reg [7:0] txDataR;

  reset_sync #(.RST_IN_POLARITY(1'b0), .RST_OUT_POLARITY(1'b1)) reset_sync
  (
    .clkIn(clkIn),
    .rstIn(rstIn),
    .rstOut(rstW)
  );
  
  spi_flash_single #(
    .DATA_WIDTH(0),
    .CPOL(0),
    .CPHA(0),
    .NUM_SS(1),
    .SCLK_FREQ(50000)
  ) spi_flash (
    .clkIn(clkIn),
    .rstIn(rstW),
    .enIn(enR),
    .misoIn(misoIn),
    .rdEnIn(rdEnR),
    .csIn(csR),
    .txDataIn(txDataR),
    .rxDataOut(rxDataW),
    .rxRdyOut(rxRdyW),
    .mosiOut(mosiOut),
    .csLowOut(csLowOut),
    .sclkOut(sclkOut)
  );
  
  counter #(
    .MAX_CNT(50000000),
    .LOOP(1'b1),
    .IS_CNT_DOWN(1'b0))
  (
    .clkIn(clkIn),
    .rstIn(rstRstR),
    .enIn(1'b1),
    .cntDoneOut(),
    .cntValOut(),
  );

  always @ (posedge rstW, posedge clkIn) begin
    if (rstW == 1) begin
      enR     <= 0;
      rdEnR   <= 0;
      csR     <= 0;
      txDataR <= 0;
      cntRstR <= 1;
    end
    
    else if (clkIn == 1) begin
      case (spiFSMR)
        IDLE:
          begin
            if 
            enR     <= 1;
            csR     <= 
            txDataR <= 8'h0A; //8'h2D; // 8'h02; //0x0A for write, 0x0B for read
    end
  end
    
  ila_0 logic_analyzer (
    .clk(clkIn),
    .probe0(rxDataW),
    .probe1(txDataR),
    .probe2()
  );
endmodule

// Whenever enIn is asserted, txDataIn will be captured in a FIFO.

// Whenever rxRdyOut is asserted, data can be pulled out of rxDataOut

// CPOL = 0 (Clock Idle State is low)
// CPOL = 1 (Clock Idle State is high)
// CPHA = 0 (Data sampled on leading edge, data changes on the trailing edge)
// CPHA = 1 (Data changes on the leading edge, data sampled on trailing edge)

// CPHA = 0, MOSI data must be available before first clock edge
// CPHA = 1, MISO data must be held valid until CS is deasserted. I don't have to do anything since the slave takes care of this.
// For CPOL = 0 and CPHA = 0
// MOSI shifts out on falling edge
// MISO samples on rising edge