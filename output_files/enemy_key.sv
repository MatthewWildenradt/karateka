//Two-always example for state machine

module enemy_key (input  logic Clk,
					 input  logic A_Clk,
					 input  logic Reset,
					 input  logic [7:0] key, 
					 input  logic [9:0] HeroX,
					 input  logic [9:0] eX,
					 input  logic [7:0] HeroK,
					 input  logic [6:0] HeroS,
					 input  logic [6:0] EnemyS,
					 output logic [7:0] keycode,
					 output int 	HH, 
					 output int 	HE,
					 output logic DEATHH_sig,
					 output logic DEATHE_sig
					 );
	
	 enum logic [5:0] {STAND, FIGHT, WALK, RUN, PUNCH, KICK, VICTORY, DEATH, REVERENCE,
	 SWITCH0_0, SWITCH0_1, SWITCH0_2, SWITCH0_3, SWITCH0_4, SWITCH1_0, SWITCH1_1, SWITCH1_2, SWITCH1_3, SWITCH1_4,
	 WALK1, WALK2, WALK3, WALK4, WALK5, WALK6, WALK7, WALK8, WALK9, RUN1, RUN2, RUN3, RUN4, RUN5, RUN6, RUN7, RUN8,
	 RUN9, REVERENCE1, REVERENCE2, REVERENCE3, REVERENCE4, REVERENCE5, PUNCH1, PUNCH2, PUNCH3, PUNCH4, PUNCH5,
	 PUNCH6, PUNCH7, PUNCH8, PUNCH9, PUNCH10, KICK1, KICK2, KICK3, KICK4, VICTORY1, DEATH1, DEATH2, DEATH3, DEATH4
	 }		curr_state, next_state;  
	 
	 
	 // Cutting clock in half repeatedely 
	 logic clkdiv0, clkdiv1, clkdiv2, clkdiv3, clkdiv4, clkdiv5, clkdiv6, clkdiv7, clkdiv8, clkdiv9, clkdiv10, clkdiv11, clkdiv12;
	 logic [7:0] COUNT, DECIDER;
	 int HeroXint, eXint;
	 assign HeroXint=HeroX;
	 assign eXint=eX;
	 
	 always_ff @ (posedge A_Clk)
    begin 
        clkdiv0 <= ~ (clkdiv0);
    end
	 
	 always_ff @ (posedge clkdiv0)
    begin 
        clkdiv1 <= ~ (clkdiv1);
    end
	 
	 /*always_ff @ (posedge clkdiv1)
    begin 
        clkdiv2 <= ~ (clkdiv2);
    end
	 
	 always_ff @ (posedge clkdiv2)
    begin 
        clkdiv3 <= ~ (clkdiv3);
    end
	 
	 always_ff @ (posedge clkdiv3)
    begin 
        clkdiv4 <= ~ (clkdiv4);
    end
	 
	 always_ff @ (posedge clkdiv4)
    begin 
        clkdiv5 <= ~ (clkdiv5);
    end
	 
	 always_ff @ (posedge clkdiv5)
    begin 
        clkdiv6 <= ~ (clkdiv6);
    end
	 
	 always_ff @ (posedge clkdiv6)
    begin 
        clkdiv7 <= ~ (clkdiv7);
    end
	 
	 always_ff @ (posedge clkdiv7)
    begin 
        clkdiv8 <= ~ (clkdiv8);
    end
	 
	 always_ff @ (posedge clkdiv8)
    begin 
        clkdiv9 <= ~ (clkdiv9);
    end
	 
	 always_ff @ (posedge clkdiv9)
    begin 
        clkdiv10 <= ~ (clkdiv10);
    end
	 
	 always_ff @ (posedge clkdiv10)
    begin 
        clkdiv11 <= ~ (clkdiv11);
    end
	 
	 always_ff @ (posedge clkdiv11)
    begin 
        clkdiv12 <= ~ (clkdiv12);
    end*/
	 
	 //life_counter( .Clk(Clk), .HitH(0), .HitE(EHIT_sig), .HealthH(HH), .HealthE(HE), .DeathH(DEATHH_sig), .DeathE(DEATHE_sig) );
	
	//updates flip flop, current state is the only one
    always_ff @ (posedge clkdiv1)  
    begin
	
	
	//reset part	
		  if(Reset)
					DEATHH_sig<=1'b0;
					
	//if a hit lands	
		  else if ( 60>(eXint-HeroXint) && 10<(eXint-HeroXint) && (EnemyS==PUNCH || EnemyS==KICK) )
					begin
					
					HH<=HH+1;
					if(HH >= 19)
						DEATHH_sig<=1'b1;
					
					end
					
	//just in case				
			else
				DEATHH_sig<=DEATHH_sig;
						
	 end
	
	//updates flip flop, current state is the only one
    always_ff @ (posedge clkdiv1)  
    begin
		   
		  //reset part	
		  if(Reset)
					begin
					DEATHE_sig<=1'b0;
					//HE<=0;
					end
			
		  //if he's dead, stay dead
		  else if((EnemyS==DEATH4) || (HeroS==DEATH4))
					keycode<=8'h00;
				
		  //retreat
		  else if ( 10>(eXint-HeroXint) && !(EnemyS==DEATH4))
					begin
					keycode<=8'h07;
					//DEATHE_sig<=1'b0;
					end
					
		  //if a hit lands on enemy	
		  else if ( 60>(eXint-HeroXint) && 10<(eXint-HeroXint) && (HeroS==PUNCH || HeroS==KICK) )
					begin
					
					HE<=HE+1;
					if(HE >= 19)
						DEATHE_sig<=1'b1;
					
					end
					
		  //punching
		  else if( (60>(eXint-HeroXint)) && (0<(eXint-HeroXint)) )
		  begin
		  
				COUNT<=COUNT+1;
				DECIDER<=COUNT%4;
				case (DECIDER)
				8'h00 : begin
				
							  keycode <= 8'h56;
				
						  end
					        
				8'h01 : begin
								
					        keycode <= 8'h04;

						  end

							  
				8'h02 : begin

					        keycode <= 8'h07;
							  COUNT<=COUNT-1;

						  end
							  
				8'h03 : begin
				
							  keycode <= 8'h57;
							  COUNT<=COUNT-2;
				
						  end
				endcase
				//EHIT_sig<=1'b0;
				
		  end
		  
		  //go walk forwards if being pulled
		  else if ( (HeroXint<150) && (eXint>600) )
				begin
				keycode<=8'h04;
				//DEATHE_sig<=1'b0;
				end
			
		  //advance if in range
        else if ( (HeroXint>320) && (80<(eXint-HeroXint)) )
				begin
				keycode<=8'h04;
				//DEATHE_sig<=1'b0;
				end
		  
		  //bowing
		  else if ( (HeroXint<160) && (HeroS==REVERENCE1 || HeroS==REVERENCE2 || HeroS==REVERENCE3 || HeroS==REVERENCE4 || HeroS==REVERENCE5) )
				begin
				keycode<=8'h58;
				//DEATHE_sig<=1'b0;
				end

		  //go to standing if out of range
		  else if ( (HeroXint<150) )
			begin
				keycode<=8'h54;
				//DEATHE_sig<=1'b0;
			end
		  
		  //default to attack
        else
			begin
				keycode<=8'h55;
				//DEATHE_sig<=1'b0;
			end
				
    end

endmodule
