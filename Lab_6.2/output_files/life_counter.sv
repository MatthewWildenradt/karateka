module life_counter( input logic Clk, 
							input logic HitH, 
							input logic HitE, 
							output logic [7:0] HealthH, 
							output logic [7:0] HealthE, 
							output logic DeathH, 
							output logic DeathE );	
	
always_ff @ (posedge HitE)  
    begin
		
		/*HealthH<=10;
		
		HealthE<=5;
			
		if(HealthH>=20)
			DeathH<=1'b1;
		else
			DeathH<=1'b0;*/
		DeathE<=1'b0;
			
	 end
							
endmodule