function vec=nbt_removeMaxMin(vec)
%this function removes the max and min values, in order to solve simple
%'outlier' issues.

[~,MaxIndex] = max(vec);
[~,MinIndex] = min(vec);

vec = vec(nbt_negSearchVector(1:length(vec), [MaxIndex MinIndex]));
end