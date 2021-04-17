/************************************************************************
AES Decryption Core Logic

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module AES (
	input	 logic CLK,
	input  logic RESET,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
);

logic 			add_en;
logic [   3:0] round_curr;
logic [   3:0] round_next;
logic [  31:0] InvMixCol_In, InvMixCol_Out;
logic [ 127:0] AES_MSG_DEC_Next, AddRoundkey_Next, InvMixCol_Next, InvShiftRows_Next, InvSubBytes_Next;		  
logic [1407:0] KeySchedule;

enum logic [3:0] {
						Wait,
						Done,
						inv_shift_rows,
						inv_sub_bytes,
						add_round_key,
						inv_mix_columns_0,
						inv_mix_columns_1,
						inv_mix_columns_2,
						inv_mix_columns_3
						}  State, Next_state;

Adder Add(.add_en, .Data_In(round_curr), .Data_Out(round_next));

KeyExpansion KeyExpansion_Subcomp (.clk(CLK), .Cipherkey(AES_KEY), .KeySchedule);

InvShiftRows InvShiftRows_Subcomp (.data_in(AES_MSG_DEC), .data_out(InvShiftRows_Next));

InvSubBytes InvSubBytes_Subcomp[15:0](.clk(CLK), .in(AES_MSG_DEC), .out(InvSubBytes_Next));

AddRoundKey AddRoundKey_Subcomp (.in(AES_MSG_DEC), .round_curr, .KeySchedule, .out(AddRoundkey_Next));

InvMixColumns InvMixColumns_Subcomp (.in(InvMixCol_In), .out(InvMixCol_Out));

always_ff @ (posedge CLK)
begin
	if (RESET) 
		begin
			State <= Wait;
			round_curr <= 4'b0000;
		end
	else 
		begin
			AES_MSG_DEC <= AES_MSG_DEC_Next;
			round_curr <= round_next;
			if (round_next == 4'b1011)
				round_curr <= 4'b0000;
			State <= Next_state;
		end
end


always_comb
begin 

	add_en = 1'b0;
	AES_DONE = 1'b0;
	AES_MSG_DEC_Next = AES_MSG_DEC;
	InvMixCol_In = 32'd0;
	
	
	Next_state = State;
	
	unique case (State)
		Wait:
			if (AES_START)
				Next_state = add_round_key;
			else
				Next_state = Wait;
				
		inv_shift_rows:
			Next_state = inv_sub_bytes;
			
		inv_sub_bytes:
			Next_state = add_round_key;
			
		add_round_key:
			if (round_curr == 4'b0000)
				Next_state = inv_shift_rows;
			else if (round_curr == 4'b1010)
				Next_state = Done;
			else
				Next_state = inv_mix_columns_0;
		
		inv_mix_columns_0:
			Next_state = inv_mix_columns_1;
		
		inv_mix_columns_1:
			Next_state = inv_mix_columns_2;
			
		inv_mix_columns_2:
			Next_state = inv_mix_columns_3;	
			
		inv_mix_columns_3:
			Next_state = inv_shift_rows;	
			
		Done:
			if (~AES_START)
				Next_state = Wait;
			else
				Next_state = Done;
		default : ;
	endcase

	unique case (State)
		Wait: begin
			AES_MSG_DEC_Next = AES_MSG_ENC;
		end
		
		inv_shift_rows: begin
			AES_MSG_DEC_Next = InvShiftRows_Next;
		end
		
		inv_sub_bytes: begin
			AES_MSG_DEC_Next = InvSubBytes_Next;
		end
		
		add_round_key: begin
			AES_MSG_DEC_Next = AddRoundkey_Next;
			add_en = 1'b1;
		end
		
		inv_mix_columns_0: begin
			InvMixCol_In = AES_MSG_DEC[127:96];
			AES_MSG_DEC_Next[127:96] = InvMixCol_Out;
		end
		
		inv_mix_columns_1: begin
			InvMixCol_In = AES_MSG_DEC[95:64];
			AES_MSG_DEC_Next[95:64] = InvMixCol_Out;
		end
		
		inv_mix_columns_2: begin
			InvMixCol_In = AES_MSG_DEC[63:32];
			AES_MSG_DEC_Next[63:32] = InvMixCol_Out;
		end
		
		inv_mix_columns_3: begin
			InvMixCol_In = AES_MSG_DEC[31:0];
			AES_MSG_DEC_Next[31:0] = InvMixCol_Out;
		end
		
		Done:
			AES_DONE = 1'b1;
			
		default : ;
	endcase
end

endmodule
