/*
Author David Dolengewicz
Program_Control is an integrated instruction memory and program counter



*/

module Program_Control( 		clk, 
								jumpRegAddr, 		//input from register Data1
								instruction, 		//main output
								writeInstruction,	// for loading instruction data
								writeAddress, 		// for loading instruction data
								writeEnable,		// for loading instruction data
								jump,				//
								jumpReg,			//
								branch,				//
								negative,			//
								reset,				// active low
								suspendEnable  );	// active high
								
input wire [31:0] jumpRegAddr, writeInstruction; //data inputs
input wire [6:0] writeAddress;
input wire clk, writeEnable, jump, jumpReg, branch, negative, reset, suspendEnable; //1-bit flags
output wire [31:0] instruction; // instruction output

//Program counter value
reg [6:0] counter;

wire [31:0] signExtended;

//connect instruction memory module
instruction_memory inst_mem(
	     .clk(clk), 
         .we(writeEnable), 
         .rst_all(reset),  		//low reset
         .read_addr(counter),
		 .read_data(instruction), 	
         .write_addr(writeAddress), 
         .write_data(writeInstruction)

       );
								
sign_extender extender( .in16(instruction[15:0]), .out32(signExtended) );
								
always @(posedge clk) begin
	
	if(suspendEnable | writeEnable) begin
		counter = counter;//do nothing
	end 
	else begin	
		if(~jump & ~jumpReg) begin //if not jumping, address moves by 1
			counter = (counter + 1'b1)%128;
		end
		else if(jump) begin //if jumping
			if(branch & ~negative) begin //Branch Greater than
				counter = counter + instruction[6:0] + 1'b1;
			end
			if(branch & negative) begin //Branch Less Than
				counter = counter - instruction[6:0];
			end
			else if(jumpReg) begin
				counter = jumpRegAddr[6:0];
				
			end
			else begin //normal jump
				counter = instruction[6:0]; 
			end
		end
		else begin
			counter = counter + 7'b1;
		end
			
	end
	
end	
								
endmodule



								

module sign_extender( in16, out32 );

input wire [15:0] in16;
output wire [31:0] out32;

assign out32 = {in16[15], 15'b0, in16[14:0] }; 



endmodule								
								
								
