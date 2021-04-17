module Adder (
					input  logic add_en,
               input  logic [3:0] Data_In,
               output logic [3:0] Data_Out
		);
					
		assign Data_Out = add_en ? Data_In + 4'b1 : Data_In;
		
endmodule 