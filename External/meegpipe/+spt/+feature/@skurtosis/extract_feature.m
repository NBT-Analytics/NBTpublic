function [featVal, featName] = extract_feature(obj, sptObj, ~, varargin)

featName = [];

M = bprojmat(sptObj);

featVal = nan(size(M, 2), 1);

if isempty(obj.Nonlinearity),
    nonlin = @(x) x;
else
    nonlin = obj.Nonlinearity;
end

for i = 1:numel(featVal)    
    featVal(i) = kurtosis(nonlin(M(:,i)), 1);
end

end