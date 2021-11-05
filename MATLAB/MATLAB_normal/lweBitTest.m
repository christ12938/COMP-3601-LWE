secret = [4701;3470;4496;664;6247;8187;4998;3116];
q = 3347;
keyHeight = 8192;
samples = keyHeight / 4;
tests = 1e4;

[A, B] = lweGeneratePublicKey(secret, q, keyHeight);

% Generate lots of messages and see if they get decrypted correctly
successes = 0;
for i = 1:tests
    message = randi([0,1]);
    [u, v] = lweEncrypt(A, B, message, q, samples);
    answer = lweDecrypt(u, v, secret, q);
    if answer == message
        successes = successes + 1;
    end
end

% Output printing
output = sprintf('%d tests run, success rate was %.1f%%\n', ...
    tests, (successes / tests) * 100);

if tests ~= successes
    error('Tests failed: %s', output);
end

fprintf('Tests passed: %s\n', output);