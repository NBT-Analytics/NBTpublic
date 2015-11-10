function value = tc2dec(bin,N)
val = bin2dec(bin);
y = sign(2^(N-1)-val).*(2^(N-1)-abs(2^(N-1)-val));

value = y;
condition = (y==0 & val~=0);
value(condition) = -val(condition);

end