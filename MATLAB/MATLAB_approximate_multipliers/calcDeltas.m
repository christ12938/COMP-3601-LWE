function [logdeltas , expdeltas] = calcDeltas(bitlen)
%% Params
% mersenne prime, feel free to use a different prime. Controls extent of graphing.
% When calculating failure rates, many different primes will be considered

% Deltas are the correction that bring the approximate function
% closer to it's actual value.
% These values essentially represent the lookup tables
logME = 13; % log2 of # correction values for exponential. ME = 2^15
logML = 12; % log2 of # correction values for logarithmm. ML = 2^12
expdeltas = calcExpDeltas(logME, bitlen*2+1, 'discrete');
logdeltas = calcLogDeltas(logML, bitlen, 'precise');

% uncomment to set corrections to zero. Zero correction gives you
% mitchell's multiplier.

%expdeltas = zeros(1,2^logME);  
%logdeltas = zeros(1,2^logML);
% disp("row_a = ");
% disp(row_a);
% disp(S);

% approximate log (uncorrected)
function out = aLog(x)
    integ = floor(log2(x)); % integer part. Obtainable using barrel shift.
    mant = x./(2.^integ) - 1;  % mantissa
    out = integ + mant;
end

% approximate 2^x (uncorrected)
function out = aExp(x)
    integ = floor(x); % integer part
    frac  = x - integ; % fractional part  
    out   = 2.^integ.*(frac + 1);
end


%% Delta Calculations

% Trivial Delta calculations:
% method 1. integrate over the error, and set the delta such that the mean error is
% zero, i.e delta = -mean error

% method 2. Same as above except we sum over the possible inputs rather
% than integrating over the continuum of possible values.

% method 3. Correct the error taking into account the start point of the
% range only. This is useful when you want to take precise logs.

% Has same convergence rate as REALM (error proportional to division size),
% but may be less accurate initially.
% Since this is a trivial calculation, mean error is not ensured to be
% identically zero, even though it approaches zero for large n. Ideally fix
% this later. But I have no idea how to do it.

% A quick fix is to calculate a final offset value which reduces the mean
% to zero but appends an adder stage.

function deltas = calcExpDeltas(n, bitlen, errorMode)
    len = 2^n;
    step = 2^-bitlen;
    spacing = 2^(bitlen-n);
    
    deltas = zeros(1,len);
    
    % Select which error correction method to use
    switch (errorMode)
        case 'continuous'
            % Error Correction method 1: take integral average over interval
            correctionFunction = @continuousMean;
        case 'discrete'       
            % Error Correction method 2: take sum average over discrete points in the interval
            correctionFunction = @discreteMean;
        case 'precise'
            % Error correction method 3: Only consider the point. Use for
            % precise Logarithms.
            correctionFunction = @preciseDelta;
    end
    
    for i = 0:len-1
        deltas(i+1) = correctionFunction(@(x) 2.^x - aExp(x), i, spacing, step, len);
    end
end

function deltas = calcLogDeltas(n, bitlen, errorMode)
    if (n>bitlen)
        n=bitlen
    end
    len = 2^n;
    step = 2^-bitlen;
    spacing = 2^(bitlen-n);
    deltas = zeros(1,len);
    % Select which error correction method to use
    switch (errorMode)
        case 'continuous'
            % Error Correction method 1: take integral average over interval
            correctionFunction = @continuousMean;
        case 'discrete'       
            % Error Correction method 2: take sum average over discrete points in the interval
            correctionFunction = @discreteMean;
        case 'precise'
            % Error correction method 3: Only consider the point. Use for
            % precise Logarithms.
            correctionFunction = @preciseDelta;
    end
    
    for i = 0:len-1
        deltas(i+1) = correctionFunction(@(x) log2(1+x) - aLog(1+x), i, spacing, step, len);
    end
end

function out = discreteMean(fn, i, spacing, step, len)
    out = sum(fn(step*(i*spacing+(0:spacing-1))))/spacing;
end

function out = continousMean(fn, i, spacing, step, len)
    out = len*integral(@(x) fn(x), i/len,(i+1)/len);
end

function out = preciseDelta(fn, i, spacing, step, len)
    out = fn(i/len);
end
end
