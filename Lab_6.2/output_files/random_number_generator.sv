module random_number_generator  (input  logic Clk, Load,
              input  logic D,
              output logic Data_Out);

    always_ff @ (posedge Clk)
    begin
		 if (Load)
			  Data_Out <= (D+1)%2;
    end

endmodule