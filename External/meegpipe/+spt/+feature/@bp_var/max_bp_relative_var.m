function y = max_bp_relative_var(spcVar, rawVar)


[maxVar, I] = max(spcVar);

y = 100*maxVar/rawVar(I);


end