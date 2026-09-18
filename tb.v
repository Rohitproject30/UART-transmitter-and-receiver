`timescale 1ns / 1ps



module tb();
reg clk;
reg rst;
reg tx_start;
reg[7:0]data_in;
wire txrx;
wire tx_busy;
wire [7:0]rx_out;
wire rx_done;

rx_tx uut(.clk(clk),.rst(rst),.tx_start(tx_start),.data_in(data_in),.tx(txrx),.rx(txrx),.tx_busy(tx_busy),.rx_out(rx_out),.rx_done(rx_done));

initial begin
clk =0;
end 
always #10 clk =~clk;
initial begin
       rst =1;tx_start=0;
       #20;
       rst=0;tx_start=1;
       #10;
       data_in=35;
       @(posedge rx_done);
       data_in=44;
       @(posedge rx_done);
        data_in=15;
         tx_start = 0; #20; tx_start = 1;
       @(posedge rx_done);
       data_in=14;
       @(posedge rx_done);
       rst=1;
       tx_start=0;
       $finish;
       
       
       end
endmodule

