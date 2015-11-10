function [gh] = function_GetKernel(n,h,m,WindowType,PolType,derivative);

% Calculation of the LPA convolution smoothing and differentiation kernel
% g^{(r)}.
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
%   m - is an order of LPA, arbitrary positive integer for mononials and 
%   for the orthonormal polynomials m=0,1,2.
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

if nargin<6, derivative = 0; end;
if nargin<5, PolType = 'Standard'; end;
if nargin<4, WindowType = 'Gaussian'; end;
if nargin<3, m = 0; end;

z = -floor(n/2):floor(n/2);

sizez = length(z);

gh = zeros(size(z));

mdl = (max(z)-min(z))/2;
fi_h_zero = zeros([1 m+1]);

for t1=0:m,
    fi_h_zero(t1+1) = function_Phi1D(0,h,t1,PolType,derivative);
    
    for t2=0:m,
        Fi(t1+1,t2+1) = 0;
        for i=1:sizez,
            Fi(t1+1,t2+1) = Fi(t1+1,t2+1) + function_Window1D(z(i),h,WindowType)*...
                function_Phi1D(z(i),h,t1,PolType)*function_Phi1D(z(i),h,t2,PolType);
        end;
        
    end;
end;

Fi = pinv(Fi);

for i=1:sizez,
    for t1=0:m,
        fi_h(i,t1+1) = function_Phi1D(z(i),h,t1,PolType);
    end;
    
    gh(i) = ((-1/h)^derivative)*function_Window1D(z(i),h,WindowType)*...
        fi_h(i,:)*Fi*fi_h_zero';
end;