/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  walkROM
(
		input [18:0] read_address,
		input Clk,

		output logic [4:0] data_Out
);

// mem has width of 3 bits and a total of 550 addresses
logic [2:0] mem [0:549];

initial
begin
	 $readmemh("scripts/sprite_bytes/Hero_Fighting_1.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];
end

endmodule
