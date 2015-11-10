function nbt_PowerAnalysis(meanA,stdA, meanB, stdB)
for n=2:50
disp(n)
for i=1:1000
A = meanA + stdA*randn(n,1); B = meanB + stdB*randn(n,1);
[h, p(i)] = ttest2(A,B);
end
ttestpower(n) = length(find(p<0.05))/10;
end

plot(ttestpower)
end