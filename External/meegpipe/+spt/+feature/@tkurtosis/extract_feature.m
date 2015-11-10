function [featVal, featName] = extract_feature(obj, ~, tSeries, varargin)

featVal = nan(size(tSeries,1), 1);

featName = [];

if isempty(obj.Nonlinearity),
    nonlin = @(x) x;
else
    nonlin = obj.Nonlinearity;
end

for i = 1:size(tSeries,1)
    this = tSeries(i,:);    
    if obj.MedFiltOrder > 1,
        this = medfilt1(this, obj.MedFiltOrder);        
    end
    this = this./sqrt(var(this));
    featVal(i) = kurtosis(nonlin(this), 1, 2);
end

end