
function [Result, charA,charB ] = fn_MitchellMul_Optimized(A,B, Sz)
N = Sz;
%------------------------------------------------------------------------------
AclgA = log2(A);
AclgB = log2(B);

% Extracting the characteristic (LOD) and mantissa part of log of A and B
charA = floor(AclgA);    
charB = floor(AclgB);

mantA = (A/(2^floor(AclgA))-1);     
mantB = (B/(2^floor(AclgB))-1);


% Get the log value in binary and in decimal respectively
lgAd   = [charA + mantA];
lgBd   = [charB + mantB];

%--------------------------------------------------------------------------
% Truncation
lgAv = uint64(2^(N-1)*(lgAd));  %  Thefractional parts has given N-1 Bits so that None of the bits from original number are lost
lgBv = uint64(2^(N-1)*(lgBd));  %  Thefractional parts has given N-1 Bits so that None of the bits from original number are lost


% if(tr>0)
%     lgAv = idivide(lgAv, uint64(2^tr),'floor')*(2^tr);
%     lgBv = idivide(lgBv, uint64(2^tr),'floor')*(2^tr);
% end

%--------------------------------------------------------------------------

% Adding the log of A and B
sumAB    = lgAv + lgBv;       

% Converting it to fraction
sumd   = double(sumAB)/2^(N-1);

% Extracting characteristic and mantissa part
charR  = floor(sumd);
mantR  = sumd - charR;

NormalizedAnswer = 1 + mantR;

Result = uint64(NormalizedAnswer*2^charR);

if(A == 0 || B ==0)
    Result = 0;
end
    
end

