function [Result, charA,charB ] = fn_MitchellMul_MBM_t(A,B, Sz, k)
N = Sz;
%------------------------------------------------------------------------------
AclgA = log2(A);
AclgB = log2(B);

% Extracting the characteristic (LOD) and mantissa part of log of A and B
charA = floor(AclgA);   %
charB = floor(AclgB);

mantA = (A/(2^floor(AclgA))-1);       
mantB = (B/(2^floor(AclgB))-1);


% Get the log value in binary and in decimal respectively
lgAd   = [charA + mantA];
lgBd   = [charB + mantB];


%--------------------------------------------------------------------------
% Error Configurability Part (Inspired from DRUM Logic)
%--------------------------------------------------------------------------
lgAv = uint64(floor(2^(k-1)*(lgAd)));  % Thefractional parts has given k-1 Bits so that k bits are taken and rest of the bits are truncated
lgBv = uint64(floor(2^(k-1)*(lgBd)));  % Thefractional parts has given k-1 Bits so that k bits are taken and rest of the bits are truncated

%k-1 because one bit is left for the leading one. In actual. we need
%(N-1)+logN. If we want k-bit to include LeadingOne. Then k-1 bits can go
%to the fraction

tA = charA;
tB = charB;

% Setting the LSB of the extracted part equal to 1 ALWAYS 
if ( (mod(lgAv,uint64(2)) == 0) && k<Sz)
    % The case when a some information is actually lose
    lgAv = lgAv + 1;
else  % Do nothing
end

if ( (mod(lgBv,uint64(2)) == 0) && k<Sz )
    lgBv =lgBv + 1;
else  % Do nothing
end

%--------------------------------------------------------------------------

% Adding the log of A and B
sumAB    = lgAv + lgBv;       

% Converting it to binary
sumd   = double(sumAB)/2^(k-1);

% Extracting characteristic and mantissa part
charR  = floor(sumd);
mantR  = sumd - charR;

CorrTem = 2^-4+2^-6; % ==0.0781;
NormalizedAnswer = 1 + mantR + CorrTem/(2^(charR-( charA + charB) ));  % Here, since the answers are in fraction, the Corr Terms precision wont be lost. (Which is important to keep the peak error low). 


% However, when charr is lessthan or equal to 6, these bits are lost in the
% final shifting. Therefore a corner case needs to be added
% At the moment, this code is incomplete. 
if(charR==2*N-1 && NormalizedAnswer>=2)
% cornercase: overflow
    NormalizedAnswer = 1 + mantR;
end

NormalizedAnswer = floor(NormalizedAnswer*2^(k-1))/2^(k-1);

Result = uint64(floor(NormalizedAnswer*2^charR));

if(charR<=6  &&  charR -( charA + charB) == 1 )
% cornercase: peak error 
        Result = Result+1;
end
if(A == 0 || B ==0)
    Result = 0;
end
end

