function coord = get_source_centroid(obj, index)


index = source_index(obj, index);

coord = nan(numel(index), 3);
for i = 1:size(coord,1)
   coord(1,:) = mean(obj.Source(index).pnt); 
end



end