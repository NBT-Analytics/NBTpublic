function obj = empty(nb)

warning('sensors:eeg:Obsolete', ...
    'Static constructor empty() has been deprecated by dummy()');

if nargin < 1 || isempty(nb) || nb < 1,
    obj = sensors.eeg;
    return; 
end

labels = cellfun(@(x) ['EEG ' num2str(x)], num2cell(1:nb), 'UniformOutput', false); 
obj = sensors.eeg('Cartesian', nan(nb,3), 'Label', labels, 'PhysDim', 'uV');


end