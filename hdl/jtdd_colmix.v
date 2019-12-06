/*  This file is part of JTDD.
    JTDD program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTDD program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTDD.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 2-12-2017 */


module jtdd_colmix(
    input              clk,
    input              rst,
    (*direct_enable*) input pxl_cen,
    input      [7:0]   cpu_dout,
    output reg [7:0]   pal_dout,
    input [9:0]        cpu_AB,
    // blanking
    input              VBL,
    input              HBL,
    // Pixel inputs
    input [6:0]        char_pxl,  // called mcol in schematics
    input [6:0]        obj_pxl,  // called ocol in schematics
    input [6:0]        scr_pxl,  // called bcol in schematics
    input              pal_cs,
    // PROM programming
    input [7:0]        prog_addr,
    input [3:0]        prom_din,
    input              prom_prio_we,
    // Pixel output
    output reg [3:0]   red,
    output reg [3:0]   green,
    output reg [3:0]   blue
);

parameter SIM_PRIO="../../rom/21j-k-0";

wire [7:0] pal_gr;
wire [3:0] pal_b;
reg        pal_gr_we, pal_b_we;
reg  [8:0] pal_addr;
reg  [7:0] seladdr;
wire [1:0] prio;

always @(posedge clk) begin
    pal_gr_we <= pal_cs && !cpu_AB[9];
    pal_b_we  <= pal_cs &&  cpu_AB[9];
    pal_dout  <= cpu_AB[9] ? pal_b : pal_gr;
    if( pal_cs )
        pal_addr <= cpu_AB[8:0];
    else 
        case( prio )
            default: pal_addr <= { 2'b00, char_pxl };
            2'd2:    pal_addr <= { 2'b01, obj_pxl };
            2'd3:    pal_addr <= { 2'b10, scr_pxl };
        endcase

end

wire BL = VBL | HBL;

always @(posedge clk) if(pxl_cen) begin
    { blue, green, red } <= BL ? 12'd0 : { pal_b, pal_gr };
end

jtframe_ram #(.aw(9),.simfile("pal_gr.bin")) u_pal_gr(
    .clk    ( clk         ),
    .cen    ( 1'b1        ),
    .data   ( cpu_dout    ),
    .addr   ( pal_addr    ),
    .we     ( pal_gr_we   ),
    .q      ( pal_gr      )
);

jtframe_ram #(.aw(9),.dw(4),.simfile("pal_b.bin")) u_pal_b(
    .clk    ( clk           ),
    .cen    ( 1'b1          ),
    .data   ( cpu_dout[3:0] ),
    .addr   ( pal_addr      ),
    .we     ( pal_b_we      ),
    .q      ( pal_b         )
);

jtframe_prom #(.aw(8),.dw(2),.simfile(SIM_PRIO)) u_prio(
    .clk    ( clk           ),
    .cen    ( 1'b1          ),
    .data   ( prom_din[1:0] ),
    .rd_addr( seladdr       ),
    .wr_addr( prog_addr     ),
    .we     ( prom_prio_we  ),
    .q      ( prio          )
);

endmodule