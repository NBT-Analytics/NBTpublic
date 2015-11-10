function myNode = emg(varargin)
% EMG - Default EMG correction node

myNode = aar.emg.cca_sliding_window(varargin{:});

end