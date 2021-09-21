function M = lweDecrypt(u, v, s, q)
    % args:
    %     u, v = ciphertext
    %     s = secret key
    %     q = part of public key
    %    
    % returns:
    %     M = plaintext bit
    
    decoded = mod(v - u * s, q);
    % disp(decoded)
    % disp(q/4)
    if (q / 4) <= decoded && decoded <= ((3 * q) / 4)
        M = 1;
    else
        M = 0;
    end
end