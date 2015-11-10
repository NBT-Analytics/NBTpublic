function y = subset(x, varargin)


if nargin < 3 || isempty(varargin{2}),
    varargin{2} = 1:size(x,2);
end
if nargin < 2 || isempty(varargin{1}),
    varargin{1}= 1:size(x,1);
end

if iscell(x),
    y = cell(size(x));
    for i = 1:numel(x)
        y{i} = misc.subset(x{i}, varargin{:});
    end
else
    try
        y = subset(x, varargin{:});
    catch ME
        if isnumeric(x) 
            y = x(varargin{1}, varargin{2});            
        else
            rethrow(ME);
        end
    end
end