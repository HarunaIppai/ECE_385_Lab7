module reg_32 (input  logic CLK, RESET, Load,
              input  logic [31:0]  D,
              output logic [31:0]  Data_Out);

    always_ff @ (posedge CLK)
    begin
	 	 if (RESET) //notice, this is a sycnrhonous reset, which is recommended on the FPGA
			  Data_Out <= 32'h0;
		 else if (Load)
			  Data_Out <= D; 
    end

endmodule
