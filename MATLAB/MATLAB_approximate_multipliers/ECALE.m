% Ezra Hui
% Error Corrected Approximate Log and Exponential

clear all; % Frees memory. Delays the inevitable.
close all; % closes plots

%% Params
% mersenne prime, feel free to use a different prime. Controls extent of graphing.
% When calculating failure rates, many different primes will be considered
q = 8191;
bitlen = ceil(log2(q))
stride = 16; % Size of pixel in graph.

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


%% Plots
plotApproxExp(expdeltas, bitlen*2+1);
plotApproxLog(logdeltas,bitlen*2+1);
plotErrProfile(logdeltas, expdeltas, bitlen, stride, q);

function [] = plotApproxExp(expdeltas, k)
    hold on
    xlabel("x");
    ylabel("2^x");
    % plot exp against approximate version
    interval = 3:0.001:9;
    plot(interval, ecExp(interval,expdeltas,k))
    plot(interval, 2.^(interval))
    figure;
end

function [] = plotApproxLog(logdeltas, k)
    hold on
    xlabel("x");
    ylabel("log2(x)");
    % % plot log against approximate version
    interval = 1/4:0.001:1;
    plot(interval, ecLog(interval,logdeltas,k))
    plot(interval, log2(interval))
    figure;
end


% plots error graphically, failure rate for different configuration and
% a summary for the given q.
function [] = plotErrProfile(logdeltas, expdeltas, bitlen, stride, q)
    % Create x,y grid
    [X,Y] = meshgrid(1:(ceil(q/stride)*stride),1:(ceil(q/stride)*stride));
    % Compute Z
    Z = ecMult(X,Y,logdeltas, expdeltas, bitlen*2+1) - X.*Y;
    
    meanErr = sum(Z, 'all')/numel(Z)
    
    % Take stride*stride squares of Z and take the maximum value for that
    % region. This is so that we dont need to store as many values in the
    % plot.
    
    MZ = sepblockfun(abs(Z), [stride,stride], 'max');
    MY = sepblockfun(Y, [stride,stride], 'max'); 
    MX = sepblockfun(X, [stride,stride], 'max');
  
    % Possible primes to use.
    primes = [61, 127, 251, 509, 1021, 2039, 4093 , 8191, 16381, 32749, 65521, 131071];

    % Filter for all primes less than q, and then tack q on the end.
    primes = [primes(primes < q),q]; 
    
    % standard deviations and means when the multiplications are restricted
    % to each prime.
    meanErrs     = zeros(1, length(primes));
    standardDevs = zeros(1, length(primes));
    
    for i=1:length(primes)
        % mean = E(X)
        meanErrs(i) = sum(Z(1:primes(i),1:primes(i)), 'all')/(primes(i)^2);
        % sd = sqrt(E(X^2) - E(X)^2)
        standardDevs(i) = sqrt(sum(Z(1:primes(i),1:primes(i)).^2, 'all')/(primes(i)^2) - meanErrs(i)^2);
    end
    
    % display failure rate table
    disp("failure<N> is the failure rate when N samples are taken.");
    varNames = {'q', 'failure16','failure32','failure64','failure128','failure256','failure512', 'failure1024', 'failure2048', 'failure4096', 'failure8192'};
    disp(table (primes',...
           failureRate(primes, 16, standardDevs)',...
           failureRate(primes, 32, standardDevs)',...
           failureRate(primes, 64, standardDevs)',...
           failureRate(primes, 128, standardDevs)',...
           failureRate(primes, 256, standardDevs)',...
           failureRate(primes, 512, standardDevs)',...
           failureRate(primes, 1024, standardDevs)',...
           failureRate(primes, 2048, standardDevs)',...
           failureRate(primes, 4096, standardDevs)',...
           failureRate(primes, 8192, standardDevs)','VariableNames',varNames));
       
    % last value is the global standard deviation / mean
    standardDev = standardDevs(end);
    meanErr= meanErrs(end);
    maxErr = max(MZ,[], 'all');
    disp(table(q, standardDev, meanErr, maxErr));
    % plot surface
    surf(MX,MY,MZ, 'LineStyle', 'none');
    
    xlabel('x');
    ylabel('y');
    zlabel('xy');
end

% Theoretical failure rate assuming # samples large enough to give a normal
% distribution. 
function out = failureRate(q, nsamples, sd)
    out = 1-erf(q./(4.*sd*sqrt(nsamples)));
end

%% Approximate logs


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

function out = ecMult(x,y,logdeltas, expdeltas, k)
    out = ecExp(ecLog(x,logdeltas,k) + ecLog(y,logdeltas,k),expdeltas,k);
    out(x==0) = 0; % Handle case where x or y is zero.
    out(y==0) = 0;   
end

function result = newMult(x,y)
    result = ecMult(x,y,logdeltas,expdeltas,k);
end
% truncates and round the fractional part to a number of bits.
function out = trunc(x,bitlen)
    out = floor(x.*2.^bitlen).*2.^-bitlen;
    % check next bit after truncation point. If it is a 1, then round up.
    % add one unit to out to represent rounding.
    out = out + ((x-out).*2.^(bitlen+1) >= 1)*2.^-bitlen;    
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