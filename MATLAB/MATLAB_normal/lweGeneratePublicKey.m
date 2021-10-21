function [A, B] = lweGeneratePublicKey(s, q, keyHeight)
    % args:
    %     s = secret key
    %     q = random number range, should be prime
    %     keyHeight = the height of the key
    %    
    % returns:
    %     A, B, q = components of the public key
    
    if ~isprime(q)
        warning('q is not prime');
    end

    A = randi([0, q], keyHeight, height(s));
    e = round(randn(keyHeight, 1));
    % e = 0;
    B = mod(A * s + e, q);

end

