function b = struct(a)
% STRUCT - Conversion to a struct
%
% sArray = struct(evArray)
%
% Where
%
% EVARRAY is an array of pset.event objects
%
% SARRAY is an array of MATLAB structs with fields named as the properties
% of the input pset.event objects
%
%
% See also: from_struct, fieldtrip, eeglab

aprops = properties(class(a));

nprops = length(aprops);

laprops = cell(size(aprops));

for i = 1:nprops
   laprops{i} = lower(aprops{i}); 
end

b = cell2struct(cell(1,length(laprops)), laprops, 2);
b = repmat(b,size(a));

for i = 1:numel(a)
    
    for j = 1:nprops
       b(i).(laprops{j}) = a(i).(aprops{j});
    end
    
end