function obj = sort(obj, sortingFeature, varargin)
% SORT - Sorts components according to a given feature


if isa(sortingFeature, 'spt.feature.feature'),
    feature = extract_feature(obj, obj, varargin{:});
else
    feature = sortingFeature;
end

[~, I] = sort(feature);

obj.ComponentSelection = obj.ComponentSelection(I);


end