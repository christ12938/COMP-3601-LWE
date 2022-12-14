function [A, B] = lweGeneratePublicKey(s, q, keyHeight)

bitlen = ceil(log2(q));
k = bitlen*2+1;
[logdeltas,expdeltas] = calcDeltas(bitlen);

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
    B = zeros(keyHeight,1);
    A = randi([0, q], keyHeight, height(s));
%     e = round(randn(keyHeight, 1));
    % e = 0;
%     for i = 1:keyHeight
%        [new_element] = rowMul(A(i,:),s);
%        B(i) = mod(new_element+e(i,:),q); 
%     end
    for i = 1:keyHeight
       [new_element] = rowMul(A(i,:),s,logdeltas,expdeltas,k);
       B(i) = mod(new_element,q); 
    end
%     disp("-------------------------------------");
    disp(mod(A * s, q)-B);

end

