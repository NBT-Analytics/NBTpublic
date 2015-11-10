function obj = egi(ns)
% EGI
% Generate a label object that agrees with EGI sensor labeling
%
% obj = label.egi(ns)
%
% 
% Where
%
% NS is the number of EEG sensors.
%
% OBJ is the generated @label object
%
%
% 
% See also: edfplus.label, EDFPLUS



signals = repmat(edfplus.signal, 1, ns);

for sensorItr = 1:ns
    spec = ['e' num2str(sensorItr)];
    signals(sensorItr) = edfplus.signal('type', 'EEG', 'spec', spec);
end
obj = edfplus.signalset(signals);
