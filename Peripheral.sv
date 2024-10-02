/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 # Author : Srimanth Tenneti
 # Version : 0.01 
 # File : Simple Interconnect Model
 # Component : Peripheral 
 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/

module Interconnect (
  
  // Clock and Reset 
  input         logic         clk, 
  input         logic         resetn, 
  
  // Address 
  input         logic [2:0]   address, 
  
  // Write Data 
  input         logic [3:0]   wdata,
  
  // Write and Read Signals 
  input         logic         wr, 
  input         logic         rd, 
  input         logic [2:0]   length, 
  
  // Read Data
  output        logic [3:0]   rdata
  
); 
 
  logic [3:0] counter; 
  
  logic [2:0] aphase_length; 
  logic [2:0] aphase_addr; 
  logic       aphase_wr; 
  logic       aphase_rd; 
  
  localparam addr  = 2'b00; 
  localparam burst = 2'b01; 
  localparam noseq = 2'b10; 
  
  logic [1:0] state, next_state; 
  
  always_ff @ (posedge clk or negedge resetn) begin
    if (~resetn) begin
      state         <= addr;  
    end else begin
      state         <= next_state; 
    end
  end 
  
  
  logic    transfer; 
  assign transfer   =  ((length == 3'd1) && (rd || wr)); 
  
  logic    burst_tf; 
  assign   burst_tf =  ((length > 3'd1) && (rd || wr));
  
  
  always_comb begin
        next_state  = addr; 
    case(state) 
       addr   : begin
         if (transfer) next_state = noseq; 
         else if (burst_tf) next_state = burst; 
         else next_state = addr;
       end 
       burst  : begin
         if (aphase_length > 3'd1) next_state = burst; 
         else next_state = addr; 
       end 
       noseq  : begin
         next_state = addr; 
       end
    endcase
  end
  
  always_ff @ (posedge clk or negedge resetn) begin
    if (~resetn) begin
       aphase_addr     <= 0; 
       aphase_length   <= 0; 
       counter         <= 0;
       rdata           <= 0; 
       aphase_wr       <= 0; 
       aphase_rd       <= 0;  
    end else begin
      if (state == addr) begin
        aphase_addr     <= addr; 
        aphase_length   <= length; 
        aphase_wr       <= wr; 
        aphase_rd       <= rd; 
      end 
      if (state == noseq || state == burst) begin
          if (aphase_wr) begin
             counter        <= wdata; 
            if (aphase_length != 0) 
             aphase_length  <= aphase_length - 1; 
          end 
          if (aphase_rd) begin
             rdata     <= counter; 
             counter   <= counter - 1; 
            if (aphase_length != 0)
              aphase_length   <= aphase_length - 1;   
          end
        end 
    end
  end 
  
endmodule
