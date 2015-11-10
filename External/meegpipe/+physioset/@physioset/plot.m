function h = plot(data, varargin)

if ~exist('eegplot', 'file'),
    error(['EEGLAB is required for plotting physiosets\n' ...
        'Did you forget running meegpipe.initialize?']);
end

% Events
ev = get_event(data);
if ~isempty(ev), ev = eeglab(ev); end

% Sensors
sens = sensors(data);
if ~isempty(sens), sens = eeglab(sens); end

if nargin == 2
    S.subs = {':', ':'};
    S.type = '()';
    sr = data.SamplingRate;
    data2 = subsref(varargin{1}, S);
    data = subsref(data, S);
    if isempty(ev),
        eegplot(data, 'eloc_file', sens, ...
            'srate', sr, 'data2', data2);
    else
        eegplot(data, 'events', ev, 'eloc_file', sens, ...
            'srate', sr, 'data2', data2);
    end
else
    if isempty(ev),
        eegplot(data, 'eloc_file', sens, ...
            'srate', data.SamplingRate, varargin{:});
    else
        eegplot(data, 'events', ev, 'eloc_file', sens, ...
            'srate', data.SamplingRate, varargin{:});
    end
end
h = gcf;

% Remove annoying callbacks
set(gcf, ...
    'WindowButtonDownFcn',      [], ...
    'WindowButtonMotionFcn',    [], ...
    'WindowButtonUpFcn',        []);

end