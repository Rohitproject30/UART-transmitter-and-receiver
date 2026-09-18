`timescale 1ns / 1ps

module rx_tx( 
    input clk,
    input rst,
    input tx_start,
    input [7:0] data_in,
    input rx,
    output reg tx,
    output reg tx_busy,
    output [7:0] rx_out,
    output rx_done
);

    parameter clk_freq    = 10_0000;
    parameter baud_rate   = 9600;
    parameter data_width  = 8;
    parameter idle        = 2'b00;
    parameter start       = 2'b01;
    parameter data        = 2'b10;
    parameter stop        = 2'b11;
    parameter wait_count  = clk_freq / baud_rate;

    reg baud_tick;
    reg [9:0] data_inn;
    integer counter=0;
    reg [7:0] shift_reg;    
    integer state;    
    integer count;

    // Baud rate generator block
    always @(posedge clk) begin 
        if (state == idle)
            counter <= 0; 
        else begin
            if (counter == wait_count) begin
                counter   <= 0;
                baud_tick <= 1;
            end else begin
                counter   <= counter + 1;
                baud_tick <= 0;
            end 
        end 
    end 

    // Transmitter FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= idle;
            tx        <= 1'b1;
            tx_busy   <= 1'b0;
            shift_reg <= 8'd0;
            count<=0;
        end else begin
            case (state)
                idle: begin
                    tx      <= 1'b1; // Fixed 1'b10 to 1'b1
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        shift_reg <= data_in;
                        tx        <= 1'b0;
                        tx_busy   <= 1'b1;
                        state     <= start;
                    end
                end

                start: begin
                    tx <= 1'b0;
                    
                    if(baud_tick)
                    state <= data;
                    
                end

                data: begin
                 
                    if (baud_tick) begin
                      if (count < data_width) begin
                        
                             tx <= shift_reg[count];
                             count <= count+1;
                        end else begin
                            tx    <= 1'b1;
                            count <=0;
                            state <= stop;
                        end
                    end
                end

                stop: begin
                    tx <= 1'b1;
                    if (baud_tick) begin
                        tx_busy <= 1'b0;
                        state   <= idle;
                    end
                end

                default: state <= idle;
            endcase
        end
    end

    ////////////////////////////////////////////////// Receiver 
    integer rcounter=0, rindex;
    //reg [9:0] rdata;
    reg [7:0] rshift_reg;
    reg [1:0] rstate;
    reg [3:0] rcount;
    reg [9:0] rxdata;

    parameter ridle = 2'b00;
    parameter rwait = 2'b01;
    parameter recv  = 2'b10;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rcount   <= 0;
            rcounter <= 0;
            rindex   <= 0;
            rxdata    <= 0;
            rstate   <= ridle;
        end else begin
            case (rstate)
                ridle: begin
                    if (rx == 1'b0) begin
                        rstate <= rwait;
                    end else begin
                        rstate <= ridle;
                    end 
                end

                rwait: begin
                //rx<=rshift_reg[rcounter];
                    //if (baud_tick) begin
                        if (rcounter <wait_count/2) begin
                        rstate   <= rwait;
                            rcounter <= rcounter + 1;
                           
                        end else begin
                         rxdata    <= {rx, rxdata[9:1]};
                            rcounter <= 0;
                            rstate   <= recv;
                            
                        end
                    end
                

                recv: begin
                    if (rindex <= 9) begin
                        if (baud_tick == 1'b1) begin
                            rindex <= rindex + 1;
                            rstate <= rwait;
                        end 
                    end
                     else begin
                       rstate <= ridle;
                       rindex<=0;
                   end
                end

                default: rstate <= ridle;
            endcase
        end
    end

    assign rx_done = (rindex == 9 && baud_tick == 1'b1) ? 1'b1 : 1'b0;     
    assign rx_out  = rxdata[8:1];

endmodule
