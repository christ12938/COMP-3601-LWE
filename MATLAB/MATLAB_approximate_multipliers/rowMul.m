function [B_element] = rowMul(row_a , S)
% Row Multiplier : 
% Takes in row_a (a single row of matrix A) and Secret S
% Multiplier them and returns a single element of matrix B

B_element = 0;
% disp("row_a = ");
% disp(row_a);
% disp(S);

for i = 1:length(row_a)
%      [result , ~,~] = fn_MitchellMul_Optimized(row_a(i),S(i),32);
    [result , ~,~] = fn_MitchellMul_MBM_t(row_a(i),S(i),16,15);
%     [result , ~,~] = fn_MitchellMul_REALM8x8_t(row_a(i),S(i),16,15);
%     result = row_a(i)*S(i);
    B_element = B_element + result;
%     disp("A=");
%     disp(row_a(i));
%     disp("S=");
%     disp(S(i));
%     disp((row_a(i)*S(i)) - result);
end
%disp(B_element);
%disp(row_a*S);

end

