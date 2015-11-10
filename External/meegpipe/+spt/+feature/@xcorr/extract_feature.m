function [featVal, featName] = extract_feature(obj, ~, tSeries,  data, varargin)


import misc.eta;

featName = [];

featVal = zeros(size(tSeries,1), 1);

if isa(tSeries, 'pset.mmappset'),
    tSeries = copy(tSeries);
end

% Select reference signals
ref = select(obj.RefSelector, data);

if size(ref,2) > 0,   
    tmp = zeros(size(tSeries,1), size(ref,1));
    for i = 1:size(tSeries,1)
        for j = 1:size(ref,1),           
            tmp(i, j) = abs(xcorr(tSeries(i,:), ref(j,:), 0 , 'coeff'));
        end
        featVal(i) = obj.AggregatingStat(tmp(i,:));
    end   
end

restore_selection(data);

end