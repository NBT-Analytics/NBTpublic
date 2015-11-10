function obj = empty(nb)

labels = cellfun(@(x) ['Unknown ' num2str(x)], num2cell(1:nb), ...
    'UniformOutput', false); 
obj = sensors.physiology('Label', labels);


end