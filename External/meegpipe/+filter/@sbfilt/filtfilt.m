function y = filtfilt(obj, x, varargin)
% FILTFILT - Zero-phase forward and reverse stop-band digital filtering
%
% 
% data = filtfilt(obj, data)
%
% data = filtfilt(obj, data, 'key', value, ...)
%
%
% where
%
% OBJ is a filter.sbfilt object
%
% DATA is the data to be filtered. DATA can be either a numeric matrix or
% an object of any class that behaves as such, e.g. a pset.pset object
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
% See also: filter.sbfilt, filter.sbfilt.filter


y = x;

if isempty(obj.LpFilter) && isempty(obj.HpFilter),   
   return; 
end

for bandItr = 1:numel(obj.LpFilter),
    if isa(y, 'pset.mmappset'),
        yCopy = copy(y, 'Temporary', true);
    else
        yCopy = y;
    end    
    tmp = yCopy;
    if ~isempty(obj.LpFilter{bandItr}),
        tmp =  filtfilt(obj.LpFilter{bandItr}, yCopy, varargin{:});
    end
    if ~isempty(obj.HpFilter{bandItr}),
        tmp =  tmp + filtfilt(obj.HpFilter{bandItr}, y, varargin{:});
    end    
    y = tmp;   
end


end