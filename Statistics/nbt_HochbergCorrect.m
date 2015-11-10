 function pvalues = nbt_HochbergCorrect(pvalues)
pvalues = sort(pvalues(:));
Num = length(pvalues);
Pb = 0.05;
i = Num;
while pvalues(i) > Pb
Pb = ((i)*0.05)/Num;
i= i-1;
if i <= 1
    break;
end
end
if i>1
pvalues = pvalues(1:i);
else
    if(pvalues(1) < 0.05/Num)
        pvalues = pvalues(1);
    else 
        pvalues = [];
    end
end
end