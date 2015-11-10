function y = resample(data, p, q, varargin)
% resample - same as built-in but attempts to take care of border effects

BORDER_SIZE = min(150, ceil(0.1*numel(data)*p/q));

y = resample(data, p, q, varargin{:});

if p == 1 && q > 1,
    tmp = downsample(data, q);
    y(1:BORDER_SIZE) = tmp(1:BORDER_SIZE);
    y(end-BORDER_SIZE+1:end) = tmp(end-BORDER_SIZE+1:end);
end


end