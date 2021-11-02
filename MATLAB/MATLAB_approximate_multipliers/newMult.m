function result = newMult(x,y,logdeltas,expdeltas,k)

% Row Multiplier : 
% Takes in row_a (a single row of matrix A) and Secret S
% Multiplier them and returns a single element of matrix B



%% Approximate logs

% approximate exp respecting bit arithmetic. X is an integer
function out = ecExp(x, deltas, k)
    len = size(deltas);
    n = log2(len(2)); % log of # subdivisions
    integ = floor(x);
    frac  = x-integ;
    msbs = floor(frac.*2.^n+1); % MSBS
    delta = trunc(reshape(deltas(msbs), size(x)), k-1); % Reshape to help with vectorization
    out = round(2.^integ.*(frac + delta + 1));
end

% approximate log respecting bit arithmetic. X is an integer
function out = ecLog(x, deltas, k)  
    len = size(deltas);
    n = log2(len(2)); % log of # subdivisions
    
    integ = floor(log2(x)); % integer part. Obtainable using priority encoder.
    integ(x==0) = 1; % Set to zero to keep next line happy. x=0 is an invalid input anyway
    
    mant = trunc(x./(2.^integ) - 1, k-1);  % mantissa truncated to k-1 bits
    mant(x==0) = 0; % Also to keep the next line happy
    msbs = floor(mant.*2.^n + 1);
    delta = trunc(reshape(deltas(msbs), size(x)), k-1); % Reshape to help with vectorization
    
    % represented by log(N) bits for integer part, and + k-1 bits for the
    % fractional part.
    out = integ + mant + delta;
end

function out = ecMult(x,y,logdeltas,expdeltas,k)
    out = ecExp(ecLog(x,logdeltas,k) + ecLog(y,logdeltas,k),expdeltas,k);
    out(x==0) = 0; % Handle case where x or y is zero.
    out(y==0) = 0;   
end
% truncates and round the fractional part to a number of bits.
function out = trunc(x,bitlen)
    out = floor(x.*2.^bitlen).*2.^-bitlen;
    % check next bit after truncation point. If it is a 1, then round up.
    % add one unit to out to represent rounding.
    out = out + ((x-out).*2.^(bitlen+1) >= 1)*2.^-bitlen;    
end
    

result = ecMult(x,y,logdeltas,expdeltas,k);

end