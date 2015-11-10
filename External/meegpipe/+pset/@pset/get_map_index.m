function [m_index, p_index2] = get_map_index(obj, p_index)
% get_map_index - Converts a point index to a (map_index,point_index) pair
%
%   [M_INDEX, P_INDEX] = get_map_index(obj, p_index)
%
%   *This is a private method of the class pset
%
% See also: pset.

p_index2 = p_index;
m_index = nan(size(p_index));
map_boundaries = [obj.MapIndices Inf];
for i = (length(map_boundaries)-1):-1:1,    
    tmp = find(p_index >= map_boundaries(i) & p_index < map_boundaries(i+1));
    p_index2(tmp) = p_index2(tmp) - obj.MapIndices(i) + 1;
    m_index(tmp) = i;
end


end