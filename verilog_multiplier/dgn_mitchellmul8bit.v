module dgn_mitchellmul8bit #(parameter sz=8)(input [sz-1:0] X,Y,  output[2*sz-1:0] M);

//----------------------------------------------------------------------------------------------
function integer clog2;
input integer value;
begin
value = value-1;
for (clog2=0; value>0; clog2=clog2+1)
value = value>>1;
end
endfunction
//---------------------------------------------------------------------------------------------
parameter lgsz = clog2(sz);

wire [sz+lgsz-1-1:0] lgX,lgY;
wire [sz-1-1:0] mantS;   
wire [lgsz:0] charS;
                                                                                           

SteeringLogicM8   #(sz, lgsz) SLi (X,Y, charS, mantS, lgX, lgY, M); 
ArithmeticBlockM8 #(sz, lgsz) ABi      (lgX,lgY, charS, mantS); 
//---------------------------------------------------------------------------------

endmodule
                                                                   
//###################################################################################################################################     
                                                                                          
module SteeringLogicM8 #(parameter sz=16, parameter lgsz = 4)(input [sz-1:0] X,Y, input [lgsz  : 0] charS, input [sz-1-1: 0] mantS,
                                                                       output [lgsz + sz-1-1: 0] lgX, lgY,  output[2*sz-1:0] M); 


reg  [lgsz-1: 0] charX;
reg  [lgsz-1: 0] charY;

wire [sz-1: 0] mantX;   
wire [sz-1: 0] mantY;   

wire zeroX;
wire zeroY;
wire zeroM = zeroX & zeroY; 
//---------------------------------------------------------------------------------
// Get the char part using LOD/Priority Encoder

always @(*)                                                                               
    begin                                                                                 
      casex (X)                                                                           
        8'b0000_0001  : charX = 3'b000;       
        8'b0000_001?  : charX = 3'b001;       
        8'b0000_01??  : charX = 3'b010;       
        8'b0000_1???  : charX = 3'b011;       
        8'b0001_????  : charX = 3'b100;       
        8'b001?_????  : charX = 3'b101;       
        8'b01??_????  : charX = 3'b110;       
        8'b1???_????  : charX = 3'b111;       
                                                                                          
        default  : charX = 3'b000;                          
      endcase                                                                             
    end
assign zeroX = (|X);                        
//---------------------------------------------------------------------------------

always @(*)                                                                               
    begin                                                                                 
      casex (Y)                                                                           
        8'b0000_0001  : charY = 3'b000;       
        8'b0000_001?  : charY = 3'b001;       
        8'b0000_01??  : charY = 3'b010;       
        8'b0000_1???  : charY = 3'b011;       
        8'b0001_????  : charY = 3'b100;       
        8'b001?_????  : charY = 3'b101;       
        8'b01??_????  : charY = 3'b110;       
        8'b1???_????  : charY = 3'b111;       
                                                                                          
        default  : charY = 3'b000;                          
      endcase                                                                             
    end
assign zeroY = (|Y);
//---------------------------------------------------------------------------------

// Get the mantissa part using behavioral model of barrel shifter 
wire [sz-1: 0] ShiftedX = {X} << ~charX;   
wire [sz-1: 0] ShiftedY = {Y} << ~charY;   


assign mantX = ShiftedX[sz-1: 0];     
assign mantY = ShiftedY[sz-1: 0];     


// Append as a number
assign lgX = {charX, mantX[sz-1-1: 0]};
assign lgY = {charY, mantY[sz-1-1: 0]};
//------------------------------ Input part done --------------------------



//------------------------------ Output part begins --------------------------

// Taking antilog of S using mitchells algorithm
wire [2*sz-1:0] ExtendedResult = { {1'b1, mantS} & {sz{zeroM}} , {sz{1'b0}}  } >> ~charS;  // Make the {1,mantissa} 16bit (2*sz) bit and then shift it right depending on the ~charS 
assign M = ExtendedResult[2*sz-1:00] ;     
                                                                    
endmodule
//###################################################################################################################################

module ArithmeticBlockM8 #(parameter sz=8, parameter lgsz = 3)(input [sz+lgsz-1-1:0] lgX,lgY   ,output [lgsz:0] charS
                                                                                            ,output [sz-1-1:0] mantS); 

// Add the log of the two numbers
assign {charS, mantS[sz-2: 0]} = lgX + lgY;     

endmodule

//###################################################################################################################################
