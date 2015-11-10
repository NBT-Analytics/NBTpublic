function y = filtfilt(obj, x, varargin)
% FILTFILT
%
% Zero-phase forward and reverse band-pass digital filtering
%
%
% data = filtfilt(obj, data)
%
% data = filtfilt(obj, data, 'key', value, ...)
%
%
% where
%
% OBJ is a filter.bpfilt object
%
% DATA is the data to be filtered. DATA can be either a numeric matrix or
% an object of any class that behaves as such, e.g. a pset.pset or a
% pset.eegset object
%
%
% ## Accepted key/value pairs:
%
% 'Reject'      : (logical) A logical array that especifies whether a data
%                 dimension (a channel) should be ignored when applying the
%                 filter. This is handy when filtering EEG/MEG datasets
%                 with bad channels. Default: false(size(data,1),1)
%
%
% See also: filter.bpfilt, filter.bpfilt.filter


verboseLabel = get_verbose_label(obj);
verbose      = is_verbose(obj);

if isempty(obj.LpFilter) && isempty(obj.HpFilter),
    y = x;
    return;
end

if verbose,
    if isa(x, 'physioset.physioset'),
        fprintf([verboseLabel 'BP-filtering %s...'], get_name(x));
    else
        fprintf([verboseLabel 'BP-filtering...']);
    end
end

y = [];
for bandItr = 1:numel(obj.LpFilter),
    if isa(x, 'pset.mmappset'),
        xCopy = copy(x, 'Temporary', true);
    else
        xCopy = x;
    end
    tmp = xCopy;
    if ~isempty(obj.LpFilter{bandItr}),
        tmp =  filtfilt(obj.LpFilter{bandItr}, tmp, varargin{:});
    end
    if ~isempty(obj.HpFilter{bandItr}),
        tmp =  filtfilt(obj.HpFilter{bandItr}, tmp, varargin{:});
    end
    
    if ~isempty(y),
        y = y + tmp;
    else
        y  = tmp;
    end
end
if verbose,
    fprintf('\n\n');
end

end