module AddRoundKey(
    input  logic [127:0] in,
	 input  logic [3:0] round_curr,
	 input  logic [1407:0] KeySchedule,
	 output logic [127:0] out
);

	 logic [127:0] key_curr;
    always_comb 
	 begin
		unique case (round_curr)
			4'b0000:
				key_curr = KeySchedule[127:0];
			4'b0001:
				key_curr = KeySchedule[255:128];
			4'b0010:
				key_curr = KeySchedule[383:256];
			4'b0011:
				key_curr = KeySchedule[511:384];
			4'b0100:
				key_curr = KeySchedule[639:512];
			4'b0101:
				key_curr = KeySchedule[767:640];
			4'b0110:
				key_curr = KeySchedule[895:768];
			4'b0111:
				key_curr = KeySchedule[1023:896];
			4'b1000:
				key_curr = KeySchedule[1151:1024];
			4'b1001:
				key_curr = KeySchedule[1279:1152];
			4'b1010:
				key_curr = KeySchedule[1407:1280];
		endcase
        out = in ^ key_curr;
    end

endmodule