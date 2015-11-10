function [y, obj] = filter(obj, x, varargin)
% FILTER - One-dimensional stop-band digital filtering
%
%
% x = filter(obj, x)
%
% x = filter(obj, x, 'key', value, ...)
%
%
% where
%
% OBJ is a filter.sbfilt object
%
% X is the data to be filtered, which can be a numeric data matrix or an
% object of any class that behaves as such, e.g. a pset.pset object.
%
%
% Accepted key/value pairs:
%
% 'Reject'  :   (logical) A logical array that especifies whether a
%               data dimension (channel) should be ignored. This is handy
%               when processing EEG/MEG datasets with bad channels.
%               Default: false(size(x,1),1)
%
%
% See also: filter.dfilt, filter.abstract_dfilt, filter.sbfilt.filtfilt


y = x;

if isempty(obj.LpFilter) && isempty(obj.HpFilter),   
   return; 
end

y = filter(mdfilt(obj), x);


end