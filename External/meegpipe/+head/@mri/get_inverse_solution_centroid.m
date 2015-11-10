function [coord, m] = get_inverse_solution_centroid(obj, sourceIdx)

if nargin < 2 || isempty(sourceIdx), sourceIdx = numel(obj.InverseSolution); end

[~, idx] = max((obj.InverseSolution(sourceIdx).strength));

coord = obj.SourceSpace.pnt(idx,:);
m     = obj.InverseSolution(sourceIdx).momentum(idx,:);
m = m/1e3;

end