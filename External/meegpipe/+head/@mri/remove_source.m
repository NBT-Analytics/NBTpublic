function obj = remove_source(obj, index)
% REMOVE_SOURCE
% Removes an EEG source from the model
%
% obj = remove_source(obj, index)
%
% where
%
% OBJ is a head.mri object
%
% INDEX is a numeric array of source indices, or the string 'all'. The
% latter will remove all EEG sources that are currently present in the model
%
% 
% See also: head.mri

if nargin < 2 || isempty(index),
    index = obj.NbSources;
end

if isnumeric(index),
    index = intersect(index, 1:obj.NbSources);
    obj.Source(index) = [];
elseif ischar(index) || iscell(index),
    remove = false(1, obj.NbSources);
    for i = 1:obj.NbSources
        if ischar(index) && strcmpi(obj.Source(i).name, index),
            remove(i) = true;
        elseif iscell(index) && ismember(obj.Source(i).name, index),
            remove(i) = true;
        end
    end
    obj.Source(remove) = [];
end





end