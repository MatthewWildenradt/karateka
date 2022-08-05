module   life_counter(input  logic Clk,
				  input  logic Reset, HitH, HitE,
              output logic [8:0] HealthH, HealthE);

	 int HeroHealth,EnemyHealth;
	 assign HealthH = HeroHealth;
	 assign HealthE = EnemyHealth;
				  
    always_ff @ (posedge Clk)
    begin
	 
		if(Reset)
			begin
				HeroHealth <= 0;
				EnemyHealth <= 0;
			end
		else
			HeroHealth <= HeroHealth+HitH;
			EnemyHealth <= HeroHealth+HitE;
			
    end

endmodule