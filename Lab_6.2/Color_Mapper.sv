//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input			Reset,
							  input        [9:0] BallX, BallY, DrawX, DrawY, Ball_size, 
							  input        [9:0] eX, eY, e_size, 
							  input        [7:0] keycode,
							  input        blank, ANIMATION_CLK, CLK,
                       output logic [7:0]  Red, Green, Blue,
							  output logic [7:0] enemy_keycode, 
							  output logic [6:0] HeroS,
							  output logic [6:0] EnemyS
							  );
    
    logic ball_on;
	 logic e_on;
	 
 /* Old Ball: Generated square box by checking if the current pixel is within a square of length
    2*Ball_Size, centered at (BallX, BallY).  Note that this requires unsigned comparisons.
	 
    if ((DrawX >= BallX - Ball_size) &&
       (DrawX <= BallX + Ball_size) &&
       (DrawY >= BallY - Ball_size) &&
       (DrawY <= BallY + Ball_size))

     New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
     this single line is quite powerful descriptively, it causes the synthesis tool to use up three
     of the 12 available multipliers on the chip!  Since the multiplicants are required to be signed,
	  we have to first cast them from logic to int (signed by default) before they are multiplied). */
	  
	 logic [23:0] gate, blug, blag, back, path, fence, moon;
	 assign gate=24'hFF0000;
	 assign blug=24'h444444;
	 assign blag=24'h222222;
	 assign back=24'h191970;
	 assign path=24'h654321;
	 assign fence=24'h033605;
	 assign moon=24'hd64b4b;
	  
    int DistX, DistY, SizeX, SizeY;
	 assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
	 //assign SizeX=40;
	 //assign SizeY=40;
	 
    int eDistX, eDistY, eSizeX, eSizeY;
	 assign eDistX = DrawX - eX;
    assign eDistY = DrawY - eY;
	 //assign eSizeX=40;
	 //assign eSizeY=40; 
	 
	 int roomdist1;
	 assign roomdist1=800;
	 
	 
	 logic [7:0] R, G, B;
	 logic [4:0] data, walk1, walk2, walk3, walk4, walk5;
	 logic [4:0] run1, run2, run3, run4, run5, run6, run7, run8, run9, run10;
	 logic [4:0] slide1, slide2, slide3, slide4, slide5, slide6, slide7, slide8, slide9, slide10;
	 logic [4:0] punch1, punch2, punch3, punch4, punch5, punch6, punch7, punch8, punch9, punch10, punch11;
	 logic [4:0] kick1, kick2, kick3, kick4, kick5;
	 logic [4:0] reverence1, reverence2, reverence3;
	 logic [4:0] death1, death2, death3, death4, death5;
	 logic [4:0] victory1, victory2;
 	 logic [8:0] colorcode;
	 logic DEATH;
	 
	 logic [7:0] eR, eG, eB;
	 logic [4:0] edata, ewalk1, ewalk2, ewalk3, ewalk4, ewalk5;
	 logic [4:0] erun1, erun2, erun3, erun4, erun5, erun6, erun7, erun8, erun9, erun10;
	 logic [4:0] eslide1, eslide2, eslide3, eslide4, eslide5, eslide6, eslide7, eslide8, eslide9, eslide10;
	 logic [4:0] epunch1, epunch2, epunch3, epunch4, epunch5, epunch6, epunch7, epunch8, epunch9, epunch10, epunch11;
	 logic [4:0] ekick1, ekick2, ekick3, ekick4, ekick5;
	 logic [4:0] ereverence1, ereverence2, ereverence3;
	 logic [4:0] edeath1, edeath2, edeath3, edeath4, edeath5;
 	 logic [8:0] ecolorcode;
	 logic eDEATH;
	 
	 enemy_key ( .Clk(CLK), .A_Clk(ANIMATION_CLK), .key(enemy_keycode), .keycode(enemy_keycode), 
	 .eX(eX),.HeroX(BallX), .HeroK(keycode), .HeroS(HeroS), .EnemyS(EnemyS), .HH(HHint), .HE(HEint),
	 .DEATHH_sig(DEATH), .DEATHE_sig(eDEATH), .Reset(Reset) );
	 
	 control hero_control( .Clk(ANIMATION_CLK), .Reset(Reset), .keycode(keycode), 
	 .colorcode(colorcode), .DEATH_sig(DEATH), .VICTORY_sig(eDEATH), .state(HeroS) );
	 
	 control enemy_control ( .Clk(ANIMATION_CLK), .Reset(Reset), .keycode(enemy_keycode), 
	 .colorcode(ecolorcode), .DEATH_sig(eDEATH), .state(EnemyS) );
	 
	 int HHint, HEint;
	 
	 //screen wire
	 int screencode, full_screen;
	 logic [7:0] addrT, addrV, addrD, sR, sG, sB, title, game, victory, defeat;
	 font_rom fr0( (16*(addrT)+DrawY%16), title ); //(8'h02+DrawY%16)
	 font_rom fr1( (16*(addrV)+DrawY%16), victory );
	 font_rom fr2( (16*(addrD)+DrawY%16), defeat );
	 assign game=8'b0;
	 
	 //shifts for where to locate words
	 int shift_k, shift_N, shift_v, shift_d;
	 assign shift_k=280;
	 assign shift_N=8;
	 assign shift_v=280;
	 assign shift_d=280;
	 
	 //screen control
	 screen_control ( .Clk(ANIMATION_CLK), .Reset(Reset), .VICTORY_sig(eDEATH), .DEFEAT_sig(DEATH), 
	 .keycode(keycode), .screen_code(screencode) );
	 
	 always_comb
	 begin
		
		//Title
		if( (DrawY>16*14) && (DrawY<16*15) )
			begin
			if( (DrawX>=8*0+shift_k) && (DrawX<8*1+shift_k) ) //K
				addrT=8'h4b;
			else if( (DrawX>=((8*1)+shift_k)) && (DrawX<((8*2)+shift_k)) ) //A
				addrT=8'h41;
			else if( (DrawX>=((8*2)+shift_k)) && (DrawX<((8*3)+shift_k)) ) //R
				addrT=8'h52;
			else if( (DrawX>=((8*3)+shift_k)) && (DrawX<((8*4)+shift_k)) ) //A
				addrT=8'h41;
			else if( (DrawX>=((8*4)+shift_k)) && (DrawX<((8*5)+shift_k)) ) //T
				addrT=8'h54;
			else if( (DrawX>=((8*5)+shift_k)) && (DrawX<((8*6)+shift_k)) ) //E
				addrT=8'h45;
			else if( (DrawX>=((8*6)+shift_k)) && (DrawX<((8*7)+shift_k)) ) //K
				addrT=8'h4b;
			else if( (DrawX>=((8*7)+shift_k)) && (DrawX<((8*8)+shift_k)) ) //A
				addrT=8'h41;
			else 
				addrT=8'h00;
			end
		else if( (DrawY>16*16) && (DrawY<16*17) )
			begin
			if( (DrawX>=8*0+shift_k+shift_N) && (DrawX<8*1+shift_k+shift_N) ) //B
				addrT=8'h42;
			else if( (DrawX>=((8*1)+shift_k+shift_N)) && (DrawX<((8*2)+shift_k)+shift_N) ) //Y
				addrT=8'h79;
			else if( (DrawX>=((8*2)+shift_k+shift_N)) && (DrawX<((8*3)+shift_k)+shift_N) ) //_
				addrT=8'h00;
			else if( (DrawX>=((8*3)+shift_k+shift_N)) && (DrawX<((8*4)+shift_k)+shift_N) ) //M
				addrT=8'h4d;
			else if( (DrawX>=((8*4)+shift_k)+shift_N) && (DrawX<((8*5)+shift_k)+shift_N) ) //A
				addrT=8'h61;
			else if( (DrawX>=((8*5)+shift_k)+shift_N) && (DrawX<((8*6)+shift_k)+shift_N) ) //T
				addrT=8'h74;
			else if( (DrawX>=((8*6)+shift_k)+shift_N) && (DrawX<((8*7)+shift_k)+shift_N) ) //T
				addrT=8'h74;
			else 
				addrT=8'h00;
			end
		else 
			addrT=8'h00;
			
		//Victory	
		if( (DrawY>16*15) && (DrawY<16*16) )
			begin
			if( (DrawX>=8*0+shift_v) && (DrawX<8*1+shift_k) ) //V
				addrV=8'h56;
			else if( (DrawX>=((8*1)+shift_v)) && (DrawX<((8*2)+shift_v)) ) //I
				addrV=8'h49;
			else if( (DrawX>=((8*2)+shift_v)) && (DrawX<((8*3)+shift_v)) ) //C
				addrV=8'h43;
			else if( (DrawX>=((8*3)+shift_v)) && (DrawX<((8*4)+shift_v)) ) //T
				addrV=8'h54;
			else if( (DrawX>=((8*4)+shift_v)) && (DrawX<((8*5)+shift_v)) ) //O
				addrV=8'h4f;
			else if( (DrawX>=((8*5)+shift_v)) && (DrawX<((8*6)+shift_v)) ) //R
				addrV=8'h52;
			else if( (DrawX>=((8*6)+shift_v)) && (DrawX<((8*7)+shift_v)) ) //Y
				addrV=8'h59;
			else 
				addrV=8'h00;
			end
		else 
			addrV=8'h00;
			
		//Defeat	
		if( (DrawY>16*15) && (DrawY<16*16) )
			begin
			if( (DrawX>=8*0+shift_d) && (DrawX<8*1+shift_k) ) //D
				addrD=8'h44;
			else if( (DrawX>=((8*1)+shift_d)) && (DrawX<((8*2)+shift_v)) ) //E
				addrD=8'h45;
			else if( (DrawX>=((8*2)+shift_d)) && (DrawX<((8*3)+shift_v)) ) //F
				addrD=8'h46;
			else if( (DrawX>=((8*3)+shift_d)) && (DrawX<((8*4)+shift_v)) ) //E
				addrD=8'h45;
			else if( (DrawX>=((8*4)+shift_d)) && (DrawX<((8*5)+shift_v)) ) //A
				addrD=8'h41;
			else if( (DrawX>=((8*5)+shift_d)) && (DrawX<((8*6)+shift_v)) ) //T
				addrD=8'h54;
			else 
				addrD=8'h00;
			end
		else 
			addrD=8'h00;
	 
	 
		//we pick which of the screens we want
		case(screencode)
		8'h00:
		begin
		full_screen=title[(8-DrawX%8-1)]; //(8-DrawX%8-1)
		end
		8'h01:
		begin
		full_screen=game;
		end
		8'h02:
		begin
		full_screen=victory[(8-DrawX%8-1)];
		end
		8'h03:
		begin
		full_screen=defeat[(8-DrawX%8-1)];
		end
		default:
		begin
		full_screen=defeat[(8-DrawX%8-1)];
		end
		endcase
		
		//pick our screen colors
		case(full_screen)
		8'h00:
		begin
		sR=8'h00;
		sG=8'h00;
		sB=8'h00;
		end
		8'h01:
		begin
		sR=8'hFF;
		sG=8'hFF;
		sB=8'hFF;
		end
		default:
		begin
		sR=8'h00;
		sG=8'h00;
		sB=8'h00;
		end
		endcase
		
	end
	 
	 //hero
	 
	 ROM_walk1 (.read_address(DistX+DistY*11), .Clk(CLK), .data_Out(walk1));
	 ROM_walk2 (.read_address(DistX+DistY*16), .Clk(CLK), .data_Out(walk2));
	 ROM_walk3 (.read_address(DistX+DistY*18), .Clk(CLK), .data_Out(walk3));
	 ROM_walk4 (.read_address(DistX+DistY*26), .Clk(CLK), .data_Out(walk4));
	 ROM_walk5 (.read_address(DistX+DistY*27), .Clk(CLK), .data_Out(walk5));
	 
	 ROM_run1 (.read_address(DistX+DistY*16), .Clk(CLK), .data_Out(run1));
	 ROM_run2 (.read_address(DistX+DistY*22), .Clk(CLK), .data_Out(run2));
	 ROM_run3 (.read_address(DistX+DistY*26), .Clk(CLK), .data_Out(run3));
	 ROM_run4 (.read_address(DistX+DistY*28), .Clk(CLK), .data_Out(run4));
	 ROM_run5 (.read_address(DistX+DistY*23), .Clk(CLK), .data_Out(run5));
	 ROM_run6 (.read_address(DistX+DistY*25), .Clk(CLK), .data_Out(run6));
	 ROM_run7 (.read_address(DistX+DistY*29), .Clk(CLK), .data_Out(run7));
	 ROM_run8 (.read_address(DistX+DistY*29), .Clk(CLK), .data_Out(run8));
	 ROM_run9 (.read_address(DistX+DistY*28), .Clk(CLK), .data_Out(run9));
	 ROM_run10 (.read_address(DistX+DistY*22), .Clk(CLK), .data_Out(run10));
	 
	 ROM_slide1 (.read_address(DistX+DistY*27), .Clk(CLK), .data_Out(slide1));
	 ROM_slide2 (.read_address(DistX+DistY*28), .Clk(CLK), .data_Out(slide2));
	 ROM_slide3 (.read_address(DistX+DistY*22), .Clk(CLK), .data_Out(slide3));
	 ROM_slide4 (.read_address(DistX+DistY*20), .Clk(CLK), .data_Out(slide4));
	 ROM_slide5 (.read_address(DistX+DistY*21), .Clk(CLK), .data_Out(slide5));
	 ROM_slide6 (.read_address(DistX+DistY*23), .Clk(CLK), .data_Out(slide6));
	 ROM_slide7 (.read_address(DistX+DistY*22), .Clk(CLK), .data_Out(slide7));
	 ROM_slide8 (.read_address(DistX+DistY*21), .Clk(CLK), .data_Out(slide8));
	 ROM_slide9 (.read_address(DistX+DistY*28), .Clk(CLK), .data_Out(slide9));
	 ROM_slide10 (.read_address(DistX+DistY*28), .Clk(CLK), .data_Out(slide10));
	 
	 ROM_punch1 (.read_address(DistX+DistY*26), .Clk(CLK), .data_Out(punch1));
	 ROM_punch2 (.read_address(DistX+DistY*28), .Clk(CLK), .data_Out(punch2));
	 ROM_punch3 (.read_address(DistX+DistY*34), .Clk(CLK), .data_Out(punch3));
	 ROM_punch4 (.read_address(DistX+DistY*26), .Clk(CLK), .data_Out(punch4));
	 ROM_punch5 (.read_address(DistX+DistY*34), .Clk(CLK), .data_Out(punch5));
	 ROM_punch6 (.read_address(DistX+DistY*33), .Clk(CLK), .data_Out(punch6));
	 ROM_punch7 (.read_address(DistX+DistY*26), .Clk(CLK), .data_Out(punch7));
	 ROM_punch8 (.read_address(DistX+DistY*35), .Clk(CLK), .data_Out(punch8));
	 ROM_punch9 (.read_address(DistX+DistY*36), .Clk(CLK), .data_Out(punch9));
	 ROM_punch10 (.read_address(DistX+DistY*27), .Clk(CLK), .data_Out(punch10));
	 ROM_punch11 (.read_address(DistX+DistY*35), .Clk(CLK), .data_Out(punch11));
	 
	 ROM_kick1 (.read_address(DistX+DistY*23), .Clk(CLK), .data_Out(kick1));
	 ROM_kick2 (.read_address(DistX+DistY*24), .Clk(CLK), .data_Out(kick2));
	 ROM_kick3 (.read_address(DistX+DistY*38), .Clk(CLK), .data_Out(kick3));
	 ROM_kick4 (.read_address(DistX+DistY*38), .Clk(CLK), .data_Out(kick4));
	 ROM_kick5 (.read_address(DistX+DistY*34), .Clk(CLK), .data_Out(kick5));
	 
	 ROM_reverence1 (.read_address(DistX+DistY*11-11), .Clk(CLK), .data_Out(reverence1));
	 ROM_reverence2 (.read_address(DistX+DistY*19-19), .Clk(CLK), .data_Out(reverence2));
	 ROM_reverence3 (.read_address(DistX+DistY*17-17), .Clk(CLK), .data_Out(reverence3));
	 
	 ROM_death1 (.read_address(DistX+DistY*SizeX), .Clk(CLK), .data_Out(death1));
	 ROM_death2 (.read_address(DistX+DistY*SizeX), .Clk(CLK), .data_Out(death2));
	 ROM_death3 (.read_address(DistX+DistY*SizeX), .Clk(CLK), .data_Out(death3));
	 ROM_death4 (.read_address(DistX+DistY*SizeX), .Clk(CLK), .data_Out(death4));
	 ROM_death5 (.read_address(DistX+DistY*SizeX), .Clk(CLK), .data_Out(death5));
	 
	 ROM_victory1 (.read_address(DistX+DistY*SizeX), .Clk(CLK), .data_Out(victory1));
	 ROM_victory2 (.read_address(DistX+DistY*SizeX), .Clk(CLK), .data_Out(victory2));
	 
	 //enemy
	 
	 e_walk1 (.read_address(eDistX+eDistY*12), .Clk(CLK), .data_Out(ewalk1));
	 e_walk2 (.read_address(eDistX+eDistY*14), .Clk(CLK), .data_Out(ewalk2));
	 e_walk3 (.read_address(eDistX+eDistY*19), .Clk(CLK), .data_Out(ewalk3));
	 e_walk4 (.read_address(eDistX+eDistY*27), .Clk(CLK), .data_Out(ewalk4));
	 e_walk5 (.read_address(eDistX+(eDistY*28)+28*5), .Clk(CLK), .data_Out(ewalk5));
	 
	 e_run1 (.read_address(eDistX+eDistY*15), .Clk(CLK), .data_Out(erun1));
	 e_run2 (.read_address(eDistX+eDistY*25), .Clk(CLK), .data_Out(erun2));
	 e_run3 (.read_address(eDistX+eDistY*20), .Clk(CLK), .data_Out(erun3));
	 e_run4 (.read_address(eDistX+eDistY*32), .Clk(CLK), .data_Out(erun4));
	 e_run5 (.read_address(eDistX+eDistY*25), .Clk(CLK), .data_Out(erun5));
	 e_run6 (.read_address(eDistX+eDistY*24), .Clk(CLK), .data_Out(erun6));
	 e_run7 (.read_address(eDistX+eDistY*32), .Clk(CLK), .data_Out(erun7));
	 e_run8 (.read_address(eDistX+eDistY*32), .Clk(CLK), .data_Out(erun8));
	 e_run9 (.read_address(eDistX+eDistY*25), .Clk(CLK), .data_Out(erun9));
	 e_run10 (.read_address(eDistX+eDistY*24), .Clk(CLK), .data_Out(erun10));
	 
	 e_slide1 (.read_address(eDistX+eDistY*26), .Clk(CLK), .data_Out(eslide1));
	 e_slide2 (.read_address(eDistX+eDistY*28), .Clk(CLK), .data_Out(eslide2));
	 e_slide3 (.read_address(eDistX+eDistY*24), .Clk(CLK), .data_Out(eslide3));
	 e_slide4 (.read_address(eDistX+eDistY*22), .Clk(CLK), .data_Out(eslide4));
	 e_slide5 (.read_address(eDistX+eDistY*22), .Clk(CLK), .data_Out(eslide5));
	 e_slide6 (.read_address(eDistX+eDistY*22), .Clk(CLK), .data_Out(eslide6));
	 e_slide7 (.read_address(eDistX+eDistY*22), .Clk(CLK), .data_Out(eslide7));
	 e_slide8 (.read_address(eDistX+eDistY*22), .Clk(CLK), .data_Out(eslide8));
	 e_slide9 (.read_address(eDistX+eDistY*28), .Clk(CLK), .data_Out(eslide9));
	 e_slide10 (.read_address(eDistX+eDistY*26), .Clk(CLK), .data_Out(eslide10));
	 
	 e_punch1 (.read_address(eDistX+eDistY*24), .Clk(CLK), .data_Out(epunch1));
	 e_punch2 (.read_address(eDistX+eDistY*26), .Clk(CLK), .data_Out(epunch2));
	 e_punch3 (.read_address(eDistX+eDistY*31), .Clk(CLK), .data_Out(epunch3));
	 e_punch4 (.read_address(eDistX+eDistY*27), .Clk(CLK), .data_Out(epunch4));
	 e_punch5 (.read_address(eDistX+eDistY*31), .Clk(CLK), .data_Out(epunch5));
	 e_punch6 (.read_address(eDistX+eDistY*31), .Clk(CLK), .data_Out(epunch6));
	 e_punch7 (.read_address(eDistX+eDistY*31), .Clk(CLK), .data_Out(epunch7));
	 e_punch8 (.read_address(eDistX+eDistY*31), .Clk(CLK), .data_Out(epunch8));
	 e_punch9 (.read_address(eDistX+eDistY*31), .Clk(CLK), .data_Out(epunch9));
	 e_punch10 (.read_address(eDistX+eDistY*27), .Clk(CLK), .data_Out(epunch10));
	 e_punch11 (.read_address(eDistX+eDistY*31), .Clk(CLK), .data_Out(epunch11));
	 
	 e_kick1 (.read_address(eDistX+eDistY*20), .Clk(CLK), .data_Out(ekick1));
	 e_kick2 (.read_address(eDistX+eDistY*20), .Clk(CLK), .data_Out(ekick2));
	 e_kick3 (.read_address(eDistX+eDistY*32), .Clk(CLK), .data_Out(ekick3));
	 e_kick4 (.read_address(eDistX+eDistY*36), .Clk(CLK), .data_Out(ekick4));
	 e_kick5 (.read_address(eDistX+eDistY*32), .Clk(CLK), .data_Out(ekick5));
	 
	 e_reverence1 (.read_address(eDistX+eDistY*12-12), .Clk(CLK), .data_Out(ereverence1));
	 e_reverence2 (.read_address(eDistX+eDistY*22-22), .Clk(CLK), .data_Out(ereverence2));
	 e_reverence3 (.read_address(eDistX+eDistY*20-20), .Clk(CLK), .data_Out(ereverence3));
	 
	 e_death1 (.read_address(eDistX+eDistY*eSizeX), .Clk(CLK), .data_Out(edeath1));
	 e_death2 (.read_address(eDistX+eDistY*eSizeX), .Clk(CLK), .data_Out(edeath2));
	 e_death3 (.read_address(eDistX+eDistY*eSizeX), .Clk(CLK), .data_Out(edeath3));
	 e_death4 (.read_address(eDistX+eDistY*eSizeX), .Clk(CLK), .data_Out(edeath4));
	 e_death5 (.read_address(eDistX+eDistY*eSizeX), .Clk(CLK), .data_Out(edeath5));
	 
	//hero 
	 
	always_comb
	begin
	
	 case(colorcode)
	 
		8'h0:
		begin
		data=walk1;
		SizeX=11;
		SizeY=50;
		end
		
		8'h1:
		begin
		data=walk2;
		SizeX=16;
		SizeY=50;
		end

		8'h2:
		begin
		data=walk3;
		SizeX=18;
		SizeY=48;
		end
		
		8'h3:
		begin
		data=walk4;
		SizeX=26;
		SizeY=48;
		end
		
		8'h4:
		begin
		data=walk5;
		SizeX=27;
		SizeY=44;
		end
		
		8'h5:
		begin
		data=run1;
		SizeX=16;
		SizeY=51;
		end
		
		8'h6:
		begin
		data=run2;
		SizeX=22;
		SizeY=48;
		end

		8'h7:
		begin
		data=run3;
		SizeX=26;
		SizeY=49;
		end
		
		8'h8:
		begin
		data=run4;
		SizeX=28;
		SizeY=47;
		end
		
		8'h9:
		begin
		data=run5;
		SizeX=23;
		SizeY=47;
		end
		
		8'hA:
		begin
		data=run6;
		SizeX=25;
		SizeY=49;
		end
		
		8'hB:
		begin
		data=run7;
		SizeX=29;
		SizeY=49;
		end
		
		8'hC:
		begin
		data=run8;
		SizeX=29;
		SizeY=46;
		end
		
		8'hD:
		begin
		data=run9;
		SizeX=28;
		SizeY=44;
		end
		
		8'hE:
		begin
		data=run10;
		SizeX=22;
		SizeY=48;
		end
		
		8'hF:
		begin
		data=slide1;
		SizeX=27;
		SizeY=44;
		end
		
		8'h10:
		begin
		data=slide2;
		SizeX=28;
		SizeY=44;
		end
		
		8'h11:
		begin
		data=slide3;
		SizeX=22;
		SizeY=44;
		end
		
		8'h12:
		begin
		data=slide4;
		SizeX=20;
		SizeY=44;
		end
		
		8'h13:
		begin
		data=slide5;
		SizeX=21;
		SizeY=44;
		end
		
		8'h14:
		begin
		data=slide6;
		SizeX=23;
		SizeY=44;
		end
		
		8'h15:
		begin
		data=slide7;
		SizeX=22;
		SizeY=44;
		end
		
		8'h16:
		begin
		data=slide8;
		SizeX=21;
		SizeY=44;
		end
		
		8'h17:
		begin
		data=slide9;
		SizeX=28;
		SizeY=44;
		end
		
		8'h18:
		begin
		data=slide10;
		SizeX=28;
		SizeY=44;
		end
		
		8'h19:
		begin
		data=punch1;
		SizeX=26;
		SizeY=44;
		end
		
		8'h1A:
		begin
		data=punch2;
		SizeX=28;
		SizeY=44;
		end
		
		8'h1B:
		begin
		data=punch3;
		SizeX=34;
		SizeY=44;
		end
		
		8'h1C:
		begin
		data=punch4;
		SizeX=26;
		SizeY=44;
		end
		
		8'h1D:
		begin
		data=punch5;
		SizeX=34;
		SizeY=44;
		end
		
		8'h1E:
		begin
		data=punch6;
		SizeX=33;
		SizeY=44;
		end
		
		8'h1F:
		begin
		data=punch7;
		SizeX=26;
		SizeY=44;
		end
		
		8'h20:
		begin
		data=punch8;
		SizeX=35;
		SizeY=44;
		end
		
		8'h21:
		begin
		data=punch9;
		SizeX=36;
		SizeY=44;
		end
		
		8'h22:
		begin
		data=punch10;
		SizeX=27;
		SizeY=44;
		end
		
		8'h23:
		begin
		data=punch11;
		SizeX=35;
		SizeY=44;
		end
		
		8'h24:
		begin
		data=kick1;
		SizeX=23;
		SizeY=44;
		end
		
		8'h25:
		begin
		data=kick2;
		SizeX=24;
		SizeY=44;
		end
		
		8'h26:
		begin
		data=kick3;
		SizeX=38;
		SizeY=43;
		end
		
		8'h27:
		begin
		data=kick4;
		SizeX=38;
		SizeY=45;
		end
		
		8'h28:
		begin
		data=kick5;
		SizeX=34;
		SizeY=44;
		end
		
		8'h29:
		begin
		data=reverence1;
		SizeX=11;
		SizeY=48;
		end
		
		8'h2A:
		begin
		data=reverence2;
		SizeX=19;
		SizeY=48;
		end
		
		8'h2B:
		begin
		data=reverence3;
		SizeX=17;
		SizeY=47;
		end
		
		8'h2C:
		begin
		data=death1;
		SizeX=26;
		SizeY=34;
		end
		
		8'h2D:
		begin
		data=death2;
		SizeX=28;
		SizeY=28;
		end
		
		8'h2E:
		begin
		data=death3;
		SizeX=26;
		SizeY=24;
		end
		
		8'h2F:
		begin
		data=death4;
		SizeX=33;
		SizeY=22;
		end
		
		8'h30:
		begin
		data=death5;
		SizeX=34;
		SizeY=16;
		end
		
		8'h31:
		begin
		data=victory1;
		SizeX=27;
		SizeY=46;
		end
		
		8'h32:
		begin
		data=victory2;
		SizeX=31;
		SizeY=45;
		end
		
		default:
		begin
		data=walk1;
		SizeX=11;
		SizeY=50;
		end
	 
	 endcase
	 
	 //enemy
	
	 case(ecolorcode)
	 
		8'h0:
		begin
		edata=ewalk1;
		eSizeX=12;
		eSizeY=49;
		end
		
		8'h1:
		begin
		edata=ewalk2;
		eSizeX=14;
		eSizeY=49;
		end

		8'h2:
		begin
		edata=ewalk3;
		eSizeX=19;
		eSizeY=49;
		end
		
		8'h3:
		begin
		edata=ewalk4;
		eSizeX=27;
		eSizeY=49;
		end
		
		8'h4:
		begin
		edata=ewalk5;
		eSizeX=28;
		eSizeY=49;
		end
		
		8'h5:
		begin
		edata=erun1;
		eSizeX=15;
		eSizeY=49;
		end
		
		8'h6:
		begin
		edata=erun2;
		eSizeX=25;
		eSizeY=49;
		end

		8'h7:
		begin
		edata=erun3;
		eSizeX=20;
		eSizeY=47;
		end
		
		8'h8:
		begin
		edata=erun4;
		eSizeX=32;
		eSizeY=49;
		end
		
		8'h9:
		begin
		edata=erun5;
		eSizeX=25;
		eSizeY=49;
		end
		
		8'hA:
		begin
		edata=erun6;
		eSizeX=24;
		eSizeY=49;
		end
		
		8'hB:
		begin
		edata=erun7;
		eSizeX=32;
		eSizeY=48;
		end
		
		8'hC:
		begin
		edata=erun8;
		eSizeX=32;
		eSizeY=48;
		end
		
		8'hD:
		begin
		edata=erun9;
		eSizeX=25;
		eSizeY=49;
		end
		
		8'hE:
		begin
		edata=erun10;
		eSizeX=24;
		eSizeY=49;
		end
		
		8'hF:
		begin
		edata=eslide1;
		eSizeX=26;
		eSizeY=44;
		end
		
		8'h10:
		begin
		edata=eslide2;
		eSizeX=28;
		eSizeY=44;
		end
		
		8'h11:
		begin
		edata=eslide3;
		eSizeX=24;
		eSizeY=44;
		end
		
		8'h12:
		begin
		edata=eslide4;
		eSizeX=22;
		eSizeY=44;
		end
		
		8'h13:
		begin
		edata=eslide5;
		eSizeX=22;
		eSizeY=44;
		end
		
		8'h14:
		begin
		edata=eslide6;
		eSizeX=22;
		eSizeY=44;
		end
		
		8'h15:
		begin
		edata=eslide7;
		eSizeX=22;
		eSizeY=44;
		end
		
		8'h16:
		begin
		edata=eslide8;
		eSizeX=22;
		eSizeY=44;
		end
		
		8'h17:
		begin
		edata=eslide9;
		eSizeX=28;
		eSizeY=44;
		end
		
		8'h18:
		begin
		edata=eslide10;
		eSizeX=26;
		eSizeY=44;
		end
		
		8'h19:
		begin
		edata=epunch1;
		eSizeX=24;
		eSizeY=42;
		end
		
		8'h1A:
		begin
		edata=epunch2;
		eSizeX=26;
		eSizeY=42;
		end
		
		8'h1B:
		begin
		edata=epunch3;
		eSizeX=31;
		eSizeY=42;
		end
		
		8'h1C:
		begin
		edata=epunch4;
		eSizeX=27;
		eSizeY=42;
		end
		
		8'h1D:
		begin
		edata=epunch5;
		eSizeX=31;
		eSizeY=42;
		end
		
		8'h1E:
		begin
		edata=epunch6;
		eSizeX=31;
		eSizeY=42;
		end
		
		8'h1F:
		begin
		edata=epunch7;
		eSizeX=31;
		eSizeY=42;
		end
		
		8'h20:
		begin
		edata=epunch8;
		eSizeX=31;
		eSizeY=42;
		end
		
		8'h21:
		begin
		edata=epunch9;
		eSizeX=31;
		eSizeY=42;
		end
		
		8'h22:
		begin
		edata=epunch10;
		eSizeX=27;
		eSizeY=42;
		end
		
		8'h23:
		begin
		edata=epunch11;
		eSizeX=31;
		eSizeY=42;
		end
		
		8'h24:
		begin
		edata=ekick1;
		eSizeX=20;
		eSizeY=44;
		end
		
		8'h25:
		begin
		edata=ekick2;
		eSizeX=20;
		eSizeY=44;
		end
		
		8'h26:
		begin
		edata=ekick3;
		eSizeX=32;
		eSizeY=43;
		end
		
		8'h27:
		begin
		edata=ekick4;
		eSizeX=36;
		eSizeY=44;
		end
		
		8'h28:
		begin
		edata=ekick5;
		eSizeX=32;
		eSizeY=44;
		end
		
		8'h29:
		begin
		edata=ereverence1;
		eSizeX=12;
		eSizeY=48;
		end
		
		8'h2A:
		begin
		edata=ereverence2;
		eSizeX=22;
		eSizeY=48;
		end
		
		8'h2B:
		begin
		edata=ereverence3;
		eSizeX=20;
		eSizeY=48;
		end
		
		8'h2C:
		begin
		edata=edeath1;
		eSizeX=24;
		eSizeY=32;
		end
		
		8'h2D:
		begin
		edata=edeath2;
		eSizeX=26;
		eSizeY=32;
		end
		
		8'h2E:
		begin
		edata=edeath3;
		eSizeX=24;
		eSizeY=32;
		end
		
		8'h2F:
		begin
		edata=edeath4;
		eSizeX=32;
		eSizeY=32;
		end
		
		8'h30:
		begin
		edata=edeath5;
		eSizeX=32;
		eSizeY=32;
		end
		
		default:
		begin
		edata=ewalk1;
		eSizeX=12;
		eSizeY=49;
		end
	 
	 endcase
	 
	 //hero
	
	 case(data) 
	 
		5'h0: 
		begin
			R = 8'h00;
			G = 8'h00;
			B = 8'hFF;
		end
		
		5'h1: 
		begin
			R = 8'h00;
			G = 8'h00;
			B = 8'h00;
		end
		
		5'h2: 
		begin
			R = 8'hFC;
			G = 8'hFC;
			B = 8'hFC;
		end
		
		5'h3: 
		begin
			R = 8'hE4;
			G = 8'h00;
			B = 8'h58;
		end
		
		default:
		begin
			R = 8'hFF;
			G = 8'hFF; 
			B = 8'hFF;
		end
	
	endcase
	
	//enemy
	
	case(edata) 
	 
		5'h0: 
		begin
			eR = 8'h00;
			eG = 8'h00;
			eB = 8'hFF;
		end
		
		5'h1: 
		begin
			eR = 8'h00;
			eG = 8'h00;
			eB = 8'h00;
		end
		
		5'h2: 
		begin
			eR = 8'hFC;
			eG = 8'hFC;
			eB = 8'hFC;
		end
		
		5'h3: 
		begin
			eR = 8'h5C;
			eG = 8'h94;
			eB = 8'hFC;
		end
		
		default:
		begin
			eR = 8'hFF;
			eG = 8'hFF; 
			eB = 8'hFF;
		end
	
	endcase

	end
	
	  
    always_comb //HERO
    begin:Ball_on_proc
        if ( ( DistX >= 0 ) && ( DistY >= 0 ) && ( DistX <= SizeX ) && ( DistY <= SizeY ) )
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
     end 
	  
	 always_comb //ENEMY
    begin:e_on_proc
        if ( ( eDistX <= 0 ) && ( eDistY >= 0 ) && ( eDistX >= -eSizeX ) && ( eDistY <= eSizeY ) )
            e_on = 1'b1;
        else 
            e_on = 1'b0;
     end 
       
	 //int distances for comparison
	 int DrawXint, DrawYint, BallXint, BallYint;
	 assign DrawXint = DrawX;
	 assign DrawYint = DrawY;
	 assign BallXint = BallX;
	 assign BallYint = BallY;
		 
    always_comb
    begin:RGB_Display
	 
		if(blank)
		begin
		  
		  //health bars
		  
		  //hero health
		  if( DrawYint>465 && DrawYint<475 && (DrawXint)%10>5 && DrawXint<(200-10*HHint))
		  begin
				Red = 8'h0;
				Green = 8'hFF;
				Blue = 8'h0;
		  end
		  
		  //enemy health
		  else if( DrawYint>465 && DrawYint<475 && (DrawXint-5)%10>5 && DrawXint>(640-200+10*HEint))
		  begin
				Red = 8'hFF;
				Green = 8'h00;
				Blue = 8'h0;
		  end
		  
		  //This is to generate the backgrounds
		  
		   //first front post
		  else if ( (DrawYint>390-DrawXint-BallXint+100) && (DrawXint < 5+50-BallXint+100) && (DrawXint > 0+50-BallXint+100) && ( ((ball_on == 1'b1) && (data != 5'b0)) || ((e_on == 1'b1) && (edata != 5'b0)) ) )
        begin 
            Red = gate[23:16]; 
            Green = gate[15:8]; 
            Blue = gate[7:0]; 
        end
		  
		  //second front post
		  else if ( (DrawYint>DrawXint-250+BallXint-roomdist1+150) && (DrawXint < 640-50-BallXint+roomdist1-150) && (DrawXint > 635-50-BallXint+roomdist1-150) && ( ((ball_on == 1'b1) && (data != 5'b0)) || ((e_on == 1'b1) && (edata != 5'b0)) ))
        begin 
            Red = gate[23:16]; 
            Green = gate[15:8]; 
            Blue = gate[7:0];
        end
		  
		  else if ( (ball_on == 1'b1) && (data != 5'b0) )
        begin 
				Red = R;//8'hFF;//R;
            Green = G;//8'hFF;//G;
            Blue = B;//8'hFF;//B;
        end
		  
		  else if ( (e_on == 1'b1)  && (edata != 5'b0) )
        begin 
				Red = eR;//8'hFF;//eR;
            Green = eG;//8'hFF;//eG;
            Blue = eB;//8'hFF;//eB;
        end
		  
		  //blue ground lines
		  else if ( (DrawYint%5 <= 2) && (DrawYint >= 380) && (DrawXint < DrawYint+roomdist1-BallXint) && ( DrawXint > (490-DrawYint-BallXint+100) ) )
        begin 
            Red = blug[23:16]; 
            Green = blug[15:8]; 
            Blue = blug[7:0]; 
        end
		  
		  //black ground lines 
		  else if ( (DrawYint%5 >= 2) && (DrawYint >= 380) && (DrawXint < DrawYint+roomdist1-BallXint) && ( DrawXint > (490-DrawYint-BallXint+100) ) )
        begin 
            Red = blag[23:16]; 
            Green = blag[15:8]; 
            Blue = blag[7:0]; 
        end
		  
		   //first front post
		  else if ( (DrawYint>390-DrawXint-BallXint+100) && (DrawXint < 5+50-BallXint+100) && (DrawXint > 0+50-BallXint+100) )
        begin 
            Red = gate[23:16]; 
            Green = gate[15:8]; 
            Blue = gate[7:0]; 
        end
		  
		  //second front post
		  else if ( (DrawYint>DrawXint-250+BallXint-roomdist1+150) && (DrawXint < 640-50-BallXint+roomdist1-150) && (DrawXint > 635-50-BallXint+roomdist1-150) )
        begin 
            Red = gate[23:16]; 
            Green = gate[15:8]; 
            Blue = gate[7:0]; 
        end
		  
		  //first top of gate
		  else if ( (DrawYint>390-DrawXint-BallXint+100) && (DrawYint<395-DrawXint-BallXint+100) && (DrawXint>40-BallXint+100) && (DrawXint<100-BallXint+100) )
        begin 
            Red = gate[23:16]; 
            Green = gate[15:8]; 
            Blue = gate[7:0]; 
        end
		  
		  //second top of gate
		  else if ( (DrawYint<DrawXint-245+BallXint-roomdist1+150) && (DrawYint>DrawXint-250+BallXint-roomdist1+150) && (DrawXint<640-40-BallXint+roomdist1-150) && (DrawXint>640-100-BallXint+roomdist1-150) )
        begin 
            Red = gate[23:16]; 
            Green = gate[15:8]; 
            Blue = gate[7:0]; 
        end
		  
		  //first back post
		  else if ( (DrawYint>390-DrawXint-BallXint+100) && (DrawXint < 15+80-BallXint+100) && (DrawXint > 10+80-BallXint+100) )
        begin 
            Red = gate[23:16]; 
            Green = gate[15:8]; 
            Blue = gate[7:0]; 
        end
		  
		  //second set of posts  
		  else if ( (DrawYint>DrawXint-250+BallXint-roomdist1+150) && (DrawXint < 630-80-BallXint+roomdist1-150) && (DrawXint > 625-80-BallXint+roomdist1-150)  )
        begin 
            Red = gate[23:16]; 
            Green = gate[15:8]; 
            Blue = gate[7:0]; 
        end
		  
		  //path area
		  else if ( (DrawYint >= 380) )
        begin 
            Red = path[23:16]; 
            Green = path[15:8]; 
            Blue = path[7:0]; 
        end
		  
		  //back fence
        else if ( ((DrawXint+BallXint+200)%5 >= 2) && (DrawYint >= 320+(DrawXint+BallXint-100)%5) )
        begin 
            Red = fence[23:16]; 
            Green = fence[15:8]; 
            Blue = fence[7:0]; 
        end
		  
		  //moon
        else if ( ( ((320-DrawX)**2) + ((120-DrawY)**2) <= 666 ) )
        begin 
            Red = moon[23:16]; 
            Green = moon[15:8]; 
            Blue = moon[7:0]; 
        end
		  
		  //background
		  else
        begin 
            Red = back[23:16]; 
            Green = back[15:8]; 
            Blue = back[7:0]; 
        end
		  
		  //screen
		  if ( screencode != 8'h01 )
		  begin
			   Red = sR;//8'h00;
				Green = sG;//8'h00;
				Blue = sB;//8'h00;
		  end
		  
		end
		
		else
		begin
			Red = 8'h00; 
         Green = 8'h00;
         Blue = 8'h00;
		end
		  
    end 
    
endmodule
