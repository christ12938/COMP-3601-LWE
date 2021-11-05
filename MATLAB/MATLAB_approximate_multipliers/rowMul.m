function [B_element] = rowMul(row_a , S,logdeltas,expdeltas,k)
B_element = 0;
for i = 1:length(row_a)
%      [result , ~,~] = fn_MitchellMul_Optimized(row_a(i),S(i),32);
%     [result , ~,~] = fn_MitchellMul_MBM_t(row_a(i),S(i),16,15);
%     [result , ~,~] = fn_MitchellMul_REALM8x8_t(row_a(i),S(i),16,15);
%     result = row_a(i)*S(i);
    result = newMult(row_a(i),S(i),logdeltas,expdeltas,k);
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

