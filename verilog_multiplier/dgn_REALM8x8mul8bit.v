module dgn_REALM8x8mul8bit #(parameter sz=8, m=08)(input [sz-1:0] X,Y,  output[2*sz-1:0] M);

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
parameter tr 			= sz-m;

wire [sz+lgsz-1-1:tr] lgX,lgY;
wire [sz-1:tr] mantS;   
wire [lgsz:0] charS;
wire CornerCase1;

SteeringLogic_SMBM_8x8_8_ConfigurableARD_08   #(sz, lgsz,m) SLi (X,Y, charS, mantS, lgX, lgY, M, CornerCase1); 
ArithmeticBlock_SMBM_8x8_8_ConfigurableARD_08 #(sz, lgsz,m) ABi      (lgX,lgY, charS, mantS, CornerCase1); 
//---------------------------------------------------------------------------------

endmodule
//###################################################################################################################################
     
                                                                                          
module SteeringLogic_SMBM_8x8_8_ConfigurableARD_08 #(parameter sz=8, parameter lgsz = 3, parameter m = 15, parameter tr = sz-m)(input [sz-1:0] X,Y, input [lgsz  : 0] charS, input [sz-1: tr] mantS,
                                                                       output [lgsz + sz-1-1: tr] lgX, lgY,  output[2*sz-1:0] M, input CornerCase1); 

parameter [lgsz-1:0] mc = m;



reg  [lgsz-1: 0] charX;
reg  [lgsz-1: 0] charY;

reg [sz-1: tr] mantX;   
reg [sz-1: tr] mantY;   

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


//**** Error configurability - Inspired by DRUM ****

reg isBigX;                                 
reg isBigY;  
// Truncate lower bits and keep only the k bits
generate 
if(sz!=m)
    always @(*)
    begin
        mantX =  {ShiftedX[sz-1:sz-m+1],1'b1};                                                 
        mantY =  {ShiftedY[sz-1:sz-m+1],1'b1};   


    end
endgenerate
generate 
if(sz==m)
    always @(*)
    begin
 		mantX = ShiftedX[sz-1:0];    
 		mantY = ShiftedY[sz-1:0];   
    end
endgenerate 




//*************************************************



// Append as a number
assign lgX = {charX, mantX[sz-1-1: tr]};
assign lgY = {charY, mantY[sz-1-1: tr]};
//------------------------------ Input part done --------------------------



//------------------------------ Output part begins --------------------------

// Taking antilog of S using mitchells algorithm
reg  [2*sz:0] ExtendedResult ;


generate 
if(sz!=m)
    always @(*)
    begin
		ExtendedResult = { {mantS[sz-1],~mantS[sz-1], mantS[sz-1-1:tr] , {(tr){1'b0}} } & {(sz+1){zeroM}} , {(sz){1'b0}}  } >> ~charS;
    end
endgenerate
generate 
if(sz==m)
    always @(*)
    begin
	ExtendedResult = { {mantS[sz-1],~mantS[sz-1], mantS[sz-1-1:tr]} & {(sz+1){zeroM}} , {(sz){1'b0}}  } >> ~charS;
	// This becomes a 17 bit shifter
    end
endgenerate 




wire [2*sz-1:0] IntermediateResult = ExtendedResult[2*sz-1:0];

wire [2:0] temp_sum = {IntermediateResult[2:0] + CornerCase1};

assign M = {IntermediateResult[2*sz-1:3], temp_sum[2:0] } ;      // Make the {1,mantissa} 16bit (2*sz) bit and then shift it right depending on the ~charS 
                                                                  
endmodule

//###################################################################################################################################
module ArithmeticBlock_SMBM_8x8_8_ConfigurableARD_08 #(parameter sz=8, parameter lgsz = 3, parameter m = 15, parameter tr = sz-m)(input [sz+lgsz-1-1:tr] lgX,lgY   ,output [lgsz:0] charS
                                                                                            ,output [sz-1:tr] mantS, output CornerCase1); 
parameter [lgsz:0] szc = 2*sz-1;
parameter nOfBitsPerPatch = 3;




// Add the log of the two numbers

wire [m-1: 0] uncorrectedMantS =   lgX[sz-1-1: tr]           +  lgY[sz-1-1: tr];
assign  charS                   =  {lgX[sz+lgsz-1-1 : sz-1]} + {lgY[sz+lgsz-1-1 : sz-1]} + uncorrectedMantS [m-1];


reg [m-1: 0]  RawmantS;

//------------------------------------- SMBM mod --------------------------------
wire [nOfBitsPerPatch-1 : 0] x1 = lgX[sz-1-1: sz-1-nOfBitsPerPatch]  ;
wire [nOfBitsPerPatch-1 : 0] x2 = lgY[sz-1-1: sz-1-nOfBitsPerPatch]  ;


reg [2:0] corr_table_out;    // 5-2 table for 8-bit multiplier     
always @(*)                                                          
    begin                                                            
      casex ({x1,x2})                                                
          6'b000_000  : corr_table_out = 3'b000;  
          6'b000_001  : corr_table_out = 3'b000;  
          6'b000_010  : corr_table_out = 3'b001;  
          6'b000_011  : corr_table_out = 3'b001;  
          6'b000_100  : corr_table_out = 3'b001;  
          6'b000_101  : corr_table_out = 3'b001;  
          6'b000_110  : corr_table_out = 3'b010;  
          6'b000_111  : corr_table_out = 3'b001;  
          6'b001_000  : corr_table_out = 3'b000;  
          6'b001_001  : corr_table_out = 3'b001;  
          6'b001_010  : corr_table_out = 3'b010;  
          6'b001_011  : corr_table_out = 3'b011;  
          6'b001_100  : corr_table_out = 3'b011;  
          6'b001_101  : corr_table_out = 3'b100;  
          6'b001_110  : corr_table_out = 3'b100;  
          6'b001_111  : corr_table_out = 3'b010;  
          6'b010_000  : corr_table_out = 3'b001;  
          6'b010_001  : corr_table_out = 3'b010;  
          6'b010_010  : corr_table_out = 3'b011;  
          6'b010_011  : corr_table_out = 3'b100;  
          6'b010_100  : corr_table_out = 3'b110;  
          6'b010_101  : corr_table_out = 3'b110;  
          6'b010_110  : corr_table_out = 3'b100;  
          6'b010_111  : corr_table_out = 3'b001;  
          6'b011_000  : corr_table_out = 3'b001;  
          6'b011_001  : corr_table_out = 3'b011;  
          6'b011_010  : corr_table_out = 3'b100;  
          6'b011_011  : corr_table_out = 3'b110;  
          6'b011_100  : corr_table_out = 3'b111;  
          6'b011_101  : corr_table_out = 3'b110;  
          6'b011_110  : corr_table_out = 3'b011;  
          6'b011_111  : corr_table_out = 3'b001;  
          6'b100_000  : corr_table_out = 3'b001;  
          6'b100_001  : corr_table_out = 3'b011;  
          6'b100_010  : corr_table_out = 3'b110;  
          6'b100_011  : corr_table_out = 3'b111;  
          6'b100_100  : corr_table_out = 3'b110;  
          6'b100_101  : corr_table_out = 3'b100;  
          6'b100_110  : corr_table_out = 3'b011;  
          6'b100_111  : corr_table_out = 3'b001;  
          6'b101_000  : corr_table_out = 3'b001;  
          6'b101_001  : corr_table_out = 3'b100;  
          6'b101_010  : corr_table_out = 3'b110;  
          6'b101_011  : corr_table_out = 3'b110;  
          6'b101_100  : corr_table_out = 3'b100;  
          6'b101_101  : corr_table_out = 3'b011;  
          6'b101_110  : corr_table_out = 3'b010;  
          6'b101_111  : corr_table_out = 3'b001;  
          6'b110_000  : corr_table_out = 3'b010;  
          6'b110_001  : corr_table_out = 3'b100;  
          6'b110_010  : corr_table_out = 3'b100;  
          6'b110_011  : corr_table_out = 3'b011;  
          6'b110_100  : corr_table_out = 3'b011;  
          6'b110_101  : corr_table_out = 3'b010;  
          6'b110_110  : corr_table_out = 3'b001;  
          6'b110_111  : corr_table_out = 3'b000;  
          6'b111_000  : corr_table_out = 3'b001;  
          6'b111_001  : corr_table_out = 3'b010;  
          6'b111_010  : corr_table_out = 3'b001;  
          6'b111_011  : corr_table_out = 3'b001;  
          6'b111_100  : corr_table_out = 3'b001;  
          6'b111_101  : corr_table_out = 3'b001;  
          6'b111_110  : corr_table_out = 3'b000;  
          6'b111_111  : corr_table_out = 3'b000;  
        default  : corr_table_out = 3'b000;                     
      endcase                                                    
    end                                                 

 wire [6:0]    CorrTerm = {2'b00,corr_table_out,2'b00} >> uncorrectedMantS [m-1];                                                              
//------------------------------------------------------------------------------------------
generate
if(m>8)
begin    
    reg [m-1:m-8] UpdatedPart;
    always@(*)
    begin
        UpdatedPart = uncorrectedMantS[m-2:m-8] + CorrTerm;
        RawmantS    = {UpdatedPart,  uncorrectedMantS[m-8-1:0]};
    end
end
endgenerate
generate
if(m==8)
begin    
    reg [m-1:m-8] UpdatedPart;
    always@(*)
    begin
        UpdatedPart = uncorrectedMantS[m-2:m-8] + CorrTerm;
        RawmantS    = {UpdatedPart};
    end
end
endgenerate
generate
if(m<8)
begin
    reg [m-1:0] UpdatedPart;
    always@(*)
    begin
        UpdatedPart = uncorrectedMantS[m-2:0] + CorrTerm[6:8-m];
        RawmantS    = UpdatedPart;
    end
end
endgenerate
//--------------------------------------------------------
// Corner case : Peak error for lower values
assign CornerCase1 = (charS<=5) & uncorrectedMantS [m-1];

//CornerCase : Overflow
wire CornerCase2 = (charS==(szc)) & RawmantS [m-1]; // Means it will cross to 17 bits

assign mantS = CornerCase2? {1'b0, uncorrectedMantS[m-2:0]} : RawmantS;

endmodule
//###################################################################################################################################
