function y = subset(x, keyArray)
% subset - Extract hash subset
%
% See also: mjava.hash


xKeys = keys(x);

y = mjava.hash;

keyArray = intersect(keyArray, xKeys);

for i = 1:numel(keyArray)
    
    S.type = '()';
    S.subs = keyArray(i);
    B = subsref(x, S);
    
    y = subsasgn(y, S, B);
    
end


end