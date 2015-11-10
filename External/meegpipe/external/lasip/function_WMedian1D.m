function y=function_wmedian(w,x)

% returns the value of weighted median
% INPUT: 
%       w = Vector of n weights, 
%       x = Vector of n values.
% The weights are non-negative, at least one positive

n=length(w); w=w/sum(w);
[xord,places]=sort(x); word=w(places);
xx=xord(cumsum(word)>=.5);
y=xx(1);