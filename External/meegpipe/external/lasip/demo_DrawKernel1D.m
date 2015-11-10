% Calculation of the LPA convolution smoothing and differentiation kernel 
% g^{(r)} and its frequency response characteristic |fft(g^{(r)})|.
% Illustration of using the function [gh] = function_GetKernel(...):
% 
% SYNTAX
%   [gh] = function_GetKernel(n,h,m,WindowType,PolType,derivative);
%   [gh] = function_GetKernel(n,h,m,WindowType,PolType);
%   [gh] = function_GetKernel(n,h,m,WindowType);
%   [gh] = function_GetKernel(n,h,m);
%   [gh] = function_GetKernel(n,h);
%
% DESCRIPTION
%   The function generates a kernel of the scale h of the support size n
%   with the following parameters:
%
%   m - is an order of LPA, arbitrary positive integer (m>=0) for mononials 
%   and for the orthonormal polynomials m=0,1,2.
%
%   WindowType - is a type of window function w(x). It can be: 
%               'Gaussian' (default), 'GaussianLeft', 'GaussianRight',
%               'Rectangular', 'RectangularLeft', 'RectangularRight',
%               'Treecube', 'Hermitian', 
%               'Exponential', 'ExponentialLeft', 'ExponentialRight',
%               'InterpolationWindow1', 'InterpolationWindow2', 
%               'InterpolationWindow3'
%
%   derivative ('r' in the BOOK notation) - is an order of derivative 
%   (derivative = 0 by default).
%
%   PolType - is a polynomial set type: 'Standard' (mononials), 'Legendre',
%             'Hermitian', 'Lagrange', 'LagrangeNonSym', 'Exponential', 
%             'ExponentialNonSym'
%
% REMARKS
%   The polynomials orthonormal with the weight function:
%   -----------------------------------------------
%   | WindowType         | PolType                |
%   -----------------------------------------------
%   | 'Rectangular'      | 'Lagrange'             |
%   | 'RectangularRight' | 'LagrangeNonSym'       |
%   | 'Exponential'      | 'Exponential'          |
%   | 'ExponentialRight' | 'ExponentialNonSym'    |
%   -----------------------------------------------
% 
% The example is illustarated on Figures 3.3-3.7 of the book. For more 
% details read 3.4.1 '1D kernels' part pp. 67.
%
% Dmitriy Paliy, Tampere University of Technology, TICSP. 16-02-2005
% dmitriy.paliy@tut.fi

clear all
% ---------------------------------------------------
% parameters of the kernel
% ---------------------------------------------------
n = 127; % size of kernel

m = 2; % order of polynomial approximation

derivative = 0; % derivative must be <= order

WindowType = 'Gaussian'; % Gaussian window function

PolType = 'Standard'; % mononials

h = [8 20]; % set of scales. Here just 2 scales are specified to compare 
            % them


% ---------------------------------------------------
% run the example
% ---------------------------------------------------
version -release; % get matlab release
matlab_R=str2num(ans);

figure,

fh1 = subplot(1,2,1);
fh2 = subplot(1,2,2);

x = -floor(n/2):floor(n/2); % a set of arguments in time domain
for i=1:length(h),    
    % generates kernel g^{(r)} in time domain
    [gh] = function_GetKernel1D(n,h(i),m,WindowType,PolType,derivative);
    
    % draw this kernel
    cur_color = [rand(1,3)];
    
    subplot(fh1), hold on,
    plot(x,gh,'LineWidth',2,'Color',cur_color), 
    title(['LPA kernel. Impulse response: g^{(',num2str(derivative),')}_{h}, m=',num2str(m)]),
    if matlab_R>=14,
        xlabel('$x$','interpreter','latex');
    else
        xlabel('\itx');
    end;
    
    
    axis square tight
    
    % its frequency response characteristic |fft(g^{(r)})|.
    fft_gh = abs(fft(gh));

    % draw it in normalized frequency
    subplot(fh2), hold on,
    plot(0:pi/(ceil(size(fft_gh,2)/2)-1):pi, fft_gh(1:ceil(size(fft_gh,2)/2)), 'LineWidth', 2, 'Color', cur_color),
    title(['Frequency response: |G^{(',num2str(derivative),')}_{h}|, m=',num2str(m)]),
    if matlab_R>=14,
        xlabel('$\omega$','interpreter','latex');
    else
        xlabel('\it\omega');
    end;
    
    axis square tight
end;