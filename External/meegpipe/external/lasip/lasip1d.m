function yh = lasip1d(y, m, h, Gamma, winTypeCell, wMedian, expand)
% LASIP1D - A simple LASIP 1D filter using the ICI rule
%
% yh = lasip1d(y, m, h, Gamma, winTypeCell)
%
% Where
%
% Y is the signal to be filtered (a 1xN numeric vector)
%
% M is the order of LPA. Default: M=2
%
% H is a set of scales. Default: H = ceil([1 1.45.^(4:16)])
%
% GAMMA is the Gamma parameter used by the ICI rule. A set of Gamma
% parameters can be specified, in which case the optimal Gamma parameter is
% chosen by Cross-Validation for every type of window function (argument
% WINTYPECELL). Default: [1:0.2:5.0]
%
% WINTYPECELL is a cell array of window function types. Can be:
% 'Gaussian' (default), 'GaussianLeft', 'GaussianRight', 'Rectangular',
% 'RectangularLeft', 'RectangularRight', 'Treecube', 'Hermitian',
% 'Exponential', 'ExponentialLeft', 'ExponentialRight',
% 'InterpolationWindow1', 'InterpolationWindow2', 'InterpolationWindow3'
%
%  e.g. winTypeCell{1} = 'Gaussian';
%       winTypeCell{2} = 'GaussianLeft';
%       winTypeCell{3} = 'GaussianRight';
% the final estimate will consist of these 3 estimates: left, right, and
% symmetrical.
%
% WMEDIAN  is a vector of weights for the weighted median filtering in the
% ICI procedure of the final scales. Default: WMedian = [1 1 1 3 1 1 1].
%
%
% ## Notes:
%
% * The scale h has different meanings for different types of window
%   functions. E.g., for the symmetrical Rectangular window h is a length
%   of window and equal to support of the window. This value should be odd,
%   if it is even then h forces to be h+1. For the Gaussian window h is a
%   length of support and h/9 is a variance parameter of Gaussian function.
%
% * This function is a slightly modified version of script
%   demo_LPCAICI_1D.m, which can be obtained from:
%   http://www.cs.tut.fi/~lasip/1D/
%
% * One modification introduced aims to minimize border effects by
%   artificially expanding the boundaries of the provided signal.
%
% See also: lasip


%% Default input arguments
if nargin < 7 || isempty(expand),
    expand = 1; % in percentage of the signal duration
end
if nargin < 6 || isempty(wMedian),
    wMedian = [1 1 1 3 1 1 1];
end
if nargin < 5 || isempty(winTypeCell),
    winTypeCell = {'Gaussian', 'GaussianLeft', 'GaussianRight'};
end
if nargin < 4 || isempty(Gamma),
    Gamma = 1:0.2:4.0;
end
if nargin < 3 || isempty(h),
    h = ceil([1 1.43.^(4:18)]);
end
if nargin < 2 || isempty(m),
    m = 2;
end

%% Artificially expand signal boundaries
y = reshape(y, 1, numel(y));
expandDuration = floor(expand*numel(y)/100);
y = [...
    fliplr(y(1:expandDuration)), ...
    y, ...
    fliplr(y(end-expandDuration+1:end)) ...
    ];


%% Modelling
deltaf  = numel(y)-1;
delta   = 1/deltaf;
x       = (0:delta:1);
[yN,xN] = size(x);


%% Kernels construction
kernels = function_CreateLPAKernels1D(m, h, winTypeCell);

%% Noise (sigma) estimation
D2_Z = y(1,2:numel(y))-y(1,1:numel(y)-1);
sigma = median(abs(D2_Z(1:numel(y)-1)))/(0.6745*sqrt(2));

%% Do LPA for every scale and every window function
yh      = cell(numel(winTypeCell), 1);
stdh    = nan(numel(winTypeCell), numel(h));
gh0     = cell(numel(winTypeCell), 1);
for s2=1:numel(h),
    for s1=1:numel(winTypeCell),
        
        % the kernel
        gh = kernels{s1, s2}';
        % the estimate
        yh{s1}(s2, 1:xN) = convn(y, gh, 'same')';
        % standard deviation of estimate
        stdh(s1, s2) = sqrt(sum(sum(gh.^2)));
        % g(0) used in Cross-Validation criterion
        gh0{s1}(s2) = gh(ceil(size(gh, 2)/2));
        
    end
end

%% Cross-Validation criterion for selection Gamma parameters
Icv_CRITERIA = zeros([numel(winTypeCell), numel(Gamma)]);
yh_Q_CV = cell(numel(winTypeCell), numel(Gamma));
for i = 1:numel(Gamma),
    
    %yh_final = 0; var_inv = 0;
    
    %%%% ICI for function estimation optimal window size selection %%%%%
    for s1 = 1:numel(winTypeCell)
        
        % the ICI rule selects from a set of estimates only one
        % estimate. It is done for different types of windows.
        [yh_ici, h_opt, std_opt] = ...
            function_ICI_1D(yh{s1}, stdh(s1,:), Gamma(i), sigma, wMedian);
        
        % the final estimate
        yh_Q_CV{s1, i}      = yh_ici;
        
        % the final estimate variances, used in fusing of estimates.
        var_opt_Q_CV{s1, i} = (std_opt.^2+eps);
        
        % optimal windows
        h_opt_Q_CV{s1, i}   = h_opt;
        
        gh0_opt(s1, 1:length(x)) = gh0{s1}(h_opt);
        
        % Cross-Validation criterion
        tmpCV = y - yh_Q_CV{s1,i};
        tmpGH = 1 - gh0_opt(s1,:);
        tmpCV_index         = find(gh0_opt(s1, :) ~= 1);
        tmpCV(tmpCV_index)  = tmpCV(tmpCV_index)./tmpGH(tmpCV_index);
        Icv(s1, i) = sum(tmpCV(tmpCV_index).^2);
        Icv(s1, i) = Icv(s1, i)/numel(y);
        
        Icv_CRITERIA(s1, i) = Icv_CRITERIA(s1, i) + Icv(s1, i);
        
    end %% for s1, directions
end;

%% Cross-Validation Results
yh_final_CV=0; var_inv_CV=0;
a = nan(1, numel(winTypeCell));
h_opt_Q_fcv = cell(numel(winTypeCell), 1);

for ss1 = 1:numel(winTypeCell)    
    
    a(ss1) = find( Icv(ss1, :) == min(Icv(ss1, :)), 1, 'first');  

    yh_final_CV = yh_final_CV + ...
        yh_Q_CV{ss1,a(ss1)}./var_opt_Q_CV{ss1, a(ss1)};
    var_inv_CV  = var_inv_CV + 1./var_opt_Q_CV{ss1,a(ss1)};
    
    h_opt_Q_fcv{ss1} = h_opt_Q_CV{ss1,a(ss1)};
    
end;

yh = yh_final_CV./var_inv_CV;

%% Cut away the expanded boundaries
yh = yh(expandDuration+1:end-expandDuration);


end