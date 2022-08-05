//Two-always example for state machine

module screen_control (input  logic Clk,
					 input  logic Reset,
					 input  logic VICTORY_sig,
					 input  logic DEFEAT_sig,
					 input  logic [7:0] keycode,
                output logic [7:0] screen_code
					 );

    // Declare signals curr_state, next_state of type enum
    // with enum values of A, B, ..., F as the state values
	 // Note that the length implies a max of 8 states, so you will need to bump this up for 8-bits
    enum logic [5:0] {TITLE, GAME, VICTORY, DEFEAT}   curr_state, next_state; 
	
	 // Cutting clock in half repeatedely 
	 logic clkdiv0, clkdiv1, clkdiv2, clkdiv3, clkdiv4, clkdiv5, clkdiv6, clkdiv7, clkdiv8, clkdiv9, clkdiv10, clkdiv11, clkdiv12;
	 
	 always_ff @ (posedge Clk)
    begin 
        clkdiv0 <= ~ (clkdiv0);
    end
	 
	 always_ff @ (posedge clkdiv0)
    begin 
        clkdiv1 <= ~ (clkdiv1);
    end
	 
	 always_ff @ (posedge clkdiv1)
    begin 
        clkdiv2 <= ~ (clkdiv2);
    end
	 
	 always_ff @ (posedge clkdiv2)
    begin 
        clkdiv3 <= ~ (clkdiv3);
    end

	 /*always_ff @ (posedge clkdiv3)
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
	 
	 int VCOUNT, DCOUNT;

	//updates flip flop, current state is the only one
    always_ff @ (posedge clkdiv3)  
    begin
		  if (Reset)
            curr_state <= TITLE;
		  else if ( (keycode==8'h2C) && (curr_state != VICTORY) && (curr_state != DEFEAT) )
				curr_state <= GAME;
		  else if(VICTORY_sig)
				begin
				VCOUNT<=VCOUNT+1;
				if(VCOUNT>10)
					curr_state <= VICTORY;
				end
		  else if(DEFEAT_sig)
				begin
				DCOUNT=DCOUNT+1;
				if(DCOUNT>10)
					curr_state <= DEFEAT;
				end
		  else
            curr_state <= next_state;
    end
	 
	 //logic [7:0] RR, GG, BB;

    // Assign outputs based on state
	always_comb
    begin
        
		  next_state = curr_state;	//required because I haven't enumerated all possibilities below
        unique case (curr_state) 

            TITLE :   next_state = TITLE;
				GAME :    next_state = GAME;
				VICTORY : next_state = VICTORY;
            DEFEAT :  next_state = DEFEAT;
				
        endcase
   
		  // Assign outputs based on ‘state’
        case (curr_state) 
		  
	   	   TITLE: 
	         begin
					 screen_code=8'h00;
		      end
				
				GAME:
				begin
					 screen_code=8'h01;
		      end
				
				VICTORY: 
	         begin
				    screen_code=8'h02;
		      end
				
				DEFEAT:
				begin
				    screen_code=8'h03;
				end
				
        endcase
		  
    end

endmodule
