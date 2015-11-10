function [pvaluesSorted]=nbt_holmcorrect(pValues)

Num = length(pValues);

pValues = sort(pValues);
pB = 0.05/Num;
i = 1;
pvaluesSorted =[];
while pValues(i) < pB
    pvaluesSorted(i) = pValues(i);
    pB = 0.05/(Num-1);
    i=i+1;
    if(i > length(pValues))
        break
    end
end
end