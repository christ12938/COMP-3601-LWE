function [u, v] = lweEncrypt(A, B, M, q, samples)
    % args:
    %     A, B, q = components of the public key
    %     M = plaintext bit
    %     samples = how many samples of A and B should be taken
    %
    % returns:
    %     u, v = ciphertext
    
    if M ~= 0 && M ~= 1
        error('M must be binary (either 0 or 1)')
    end
    if ~isprime(q)
        warning('q is not prime');
    end
    if height(A) ~= height(B)
        error('A and B have different heights')
    end
        
    v = 0;
    u = 0;
    for i = 1:samples
        randomRow = randi(height(A));
        u = u + A(randomRow, :);
        v = v + B(randomRow, :);
    end
    u = mod(u, q);
    v = mod(v - floor(q / 2) * M, q);
end