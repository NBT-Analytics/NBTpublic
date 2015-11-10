function colors = rnd_colors(n, varargin)
% RND_COLORS - Randomize line colors
%
% colors = rnd_colors(n)
% colors = rnd_colors(n, 'key', value, ...)
%
% Where
%
% N is the number of colors to generate
%
% COLORS is a Nx3 matrix of RGB color specifications
%
% ## Optional arguments (as key/value pairs):
%
%       MinDist: A numeric scalar in the range (0,1). Default: 0.1
%           Minimum Euclidean distance between two different line colors
%
%       MinLuminance: A numeric scalar in the range (0,1). Default: 0
%           Minimum color luminance
%
%       InitGuess: A Kx3 matrix with RGB color specifications. Default: []
%           A initial set of colors can be provided using this argument
%
%
% See also: plotter.luminance, plotter


import misc.process_arguments;
import plotter.luminance;
import misc.ismatrix;

MAX_ITER = 100;

opt.MinDist         = 0.1;
opt.MinLuminance    = 0;
opt.Background      = 'light';
opt.InitGuess       = [];

[~, opt] = process_arguments(opt, varargin);

if isempty(opt.InitGuess),
    
    if isempty(opt.Background), 
        opt.InitGuess = rand(n, 3);
    elseif strcmpi(opt.Background, 'light'),
        opt.InitGuess = [0 0 0;1 0 0;0 1 0;0 0 1;randn(n-4, 3)];
    elseif strcmpi(opt.Background, 'dark'),
        opt.InitGuess = [0.9 0.9 0.9;1 0 0;0 1 0;0 0 1;randn(n-4, 3)];
    else
       error('Background must be either ''light'' or ''dark''') 
    end
    
elseif size(opt.InitGuess, 1) < n,
    opt.InitGuess = [opt.InitGuess; rand(n-size(opt.InitGuess,1), 3)];
end

if ~isnumeric(opt.InitGuess) || ~ismatrix(opt.InitGuess) || ...
        size(opt.InitGuess, 2) ~= 3,
   error('INITGUESS Must be a Nx3 matrix of RGB color specifications')
end

colors = opt.InitGuess;
for i = 1:size(colors, 1),   
   count = 0;
   while (luminance(colors(i,:)) < opt.MinLuminance || ...
           (i > 1 && any(euclidean_dist(colors(i,:), colors(1:i-1,:)) < ...
           opt.MinDist))) && count < MAX_ITER,
       colors(i, :) = rand(1,3);
       count = count + 1;
   end  
   
end

colors = colors(1:n,:);

end




function y = euclidean_dist(a,b)


if size(a,1) > size(b,1),
    tmp = a;
    a = b;
    b = tmp;
    clear tmp;
elseif size(a,1)>1 && size(a,1) == size(b,1),
    y = nan(size(a,1),1);
    for i = 1:size(a,1)
       y(i) = misc.euclidean_dist(a(i,:), b(i,:));       
    end
    return;
end
   
a = repmat(a,size(b,1),1);

y = sqrt(sum((a-b).^2,2));

end