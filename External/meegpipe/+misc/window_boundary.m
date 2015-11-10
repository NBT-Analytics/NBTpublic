function boundaries = window_boundary(N, wl, wov)
% window_boundary - Returns the boundaries of the data windows in a
% sliding window analysis.
%
%   Y = window_boundary(N, WL, WOV) where N is the length of the data, WL
%   is the window length (in samples) and WOV is the window overlap (in
%   percentage).
%
% See also: BSS/MR


if nargin < 2,
    error('misc:window_boundary:invalidInput', ...
        'At least two input arguments are expected.');
end
if nargin < 3 || isempty(wov),
    wov = 0;
end
if isempty(wl),
    boundaries = [];
    return;
end
if wl < 0,
    error('misc:window_boundary:invalidInput', ...
        'The window length must be a positive scalar.');
end
if wov < 0 || wov >= 1,
    error('misc:window_boundary:invalidInput', ...
        'The window overlap must be a scalar in the range [0,1).');
end

w_s = ceil((1-wov)*wl);
first = 1:w_s:max(1,(N-wl+1));
last = first+wl;
if last(end) < N,
    last(end) = N;
elseif last(end)>N,
    last(end) = N;
end
boundaries = [first(:) last(:)];

end