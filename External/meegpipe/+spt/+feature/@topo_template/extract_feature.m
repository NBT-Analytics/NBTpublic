function [featVal, featName] =  extract_feature(obj, sptObj, varargin)

import misc.eta;
import misc.unit_norm;

featName = [];
% Candidate topographies
A = bprojmat(sptObj);

% Reference (template) topography
ref = get_config(obj, 'Template');

if isa(ref, 'function_handle'),
    ref = ref(data);
end

if size(ref, 1) ~= size(A,1),
    error('topo_template:NonMatchingDimensions', ...
        'The template and candidate topographies have different dimensions');
end

% Find location of power peak
ref = ref - repmat(mean(ref,2), 1, size(ref,2));
P   = sum(ref.^2);
[~, idx] = max(P);

% Normalize topographies
A   = unit_norm(A);
ref = unit_norm(ref(:, idx));

featVal = abs(ref'*A);

end