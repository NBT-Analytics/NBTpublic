function x = hankel2signal(H)

import misc.ispset;

for j = 2:size(H,1)
    H(j,:) = circshift(H(j,:)', j-1)';
end

if ispset(H),
    x = PSET.nan(1, sum(size(H))-1);
else
    x = nan(1,sum(size(H))-1);
end
for j = 1:min(size(H))
    x(j) = mean(H(1:j,j));
end
x(min(size(H)):size(H,2)) = mean(H(:, min(size(H)):size(H,2)));
count = 1;
for j = (size(H,2)+1):length(x)
    count = count+1;
    x(j) = mean(H(count:end,count-1));                                                                          
end