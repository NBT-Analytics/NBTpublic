function obj = eeg(varargin)

import misc.process_arguments;
import edfplus.signal;

keySet = {...
    'dim',...
    'prefix'...
    };

dim     = [];
prefix  = [];

eval(process_arguments(keySet, varargin));

if isempty(dim),
    [~, dim] = signal.signal_types('EEG');
    dim = dim{1};
end
if isempty(prefix),
    prefix = 'u';
end

obj = signal('type', 'EEG', 'dim', dim, 'prefix', prefix);


end