function [success, message, messageId] = rmdir(varargin)
% RMDIR - A wrapper around MATLAB's builtin rmdir
%
% This function is identical to MATLAB's built-in with the exception that
% this function re-tries the rm operation multiple times before giving up.
% 
% See also: rmdir

MAX_TRIES = 5;
INTERVAL  = 1; % in seconds

tryCount = 0;

while (tryCount < MAX_TRIES)
    [success, message, messageId] = rmdir(varargin{:});
    if success, return; end
    tryCount = tryCount + 1;
    pause(INTERVAL);
end




end