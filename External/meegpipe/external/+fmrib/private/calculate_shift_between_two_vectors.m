% function shift = calculate_shift(vec,refvec)
%
% a quick n dirty function to calculate the shift in samples between two
% vectors. They can be double or single. vec and refvec are automatically changed
% to N-by-1 doubles.
%
% !! vec and refvef should have the EXACT SAME LENGTH!
%
% this function returns shift, which is a scalar integer.
%
% i use the circshift function to change

function shiftvalue = calculate_shift_between_two_vectors(vec,refvec)

% typecasting..
vec=reshape(double(vec),numel(vec),1);
refvec=reshape(double(refvec),numel(refvec),1);


% calculate the max. shift value.
minshift = floor(numel(vec)/2);

shiftvalues=-1*minshift:1:minshift;
corvals=zeros(size(shiftvalues));

% calculate for each shiftvalue, the correlation.
for i=1:numel(shiftvalues)
    corvals(i) = prcorr2(circshift(vec,shiftvalues(i)),refvec);
end

% now use the prcorr2.

shiftvalue = -1*shiftvalues(corvals==max(corvals));

return;



