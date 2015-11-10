function dMat = distance(bss1, bss2, distMeas)


dMat = nan(numel(bss1), numel(bss2));

for i = 1:numel(bss1)
    for j = 1:numel(bss2)
        dMat(i,j) = distMeas(bss1{i}, bss2{j});        
    end
end

end