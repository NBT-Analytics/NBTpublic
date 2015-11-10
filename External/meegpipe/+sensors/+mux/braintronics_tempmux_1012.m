function obj = braintronics_tempmux_1012()


labels = repmat({'Temperature'}, 1, 12);
labels = cellfun(@(x,y) [x ' ' num2str(y)], labels, num2cell(1:12), ...
    'UniformOutput', false);

muxSensors = sensors.physiology('Label', labels);

obj = sensors.mux.mux(...
    'UmuxSensors',   muxSensors, ...
    'CycleDur',      500, ...  % change to 125ms later!!
    'NbSlots',       16, ...
    'CalibSlotIdx',  [1 2 3], ...
    'SignalSlotIdx', 5:16, ...
    'CalibValue',    [40 10 25]);
    


end