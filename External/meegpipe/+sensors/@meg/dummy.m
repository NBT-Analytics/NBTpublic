function obj = dummy(nb)

labels = cellfun(@(x) ['MEG ' num2str(x)], num2cell(1:nb), 'UniformOutput', false); 
obj = sensors.meg('Cartesian', nan(nb,3), 'Label', labels, 'PhysDim', 'na');


end