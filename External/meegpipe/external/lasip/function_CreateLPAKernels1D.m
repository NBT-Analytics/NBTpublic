function [kernels] = function_CreateLPAKernels1D(m,H,WindowTypeCell)

% Creates LPA convolution kernels cell array.
%
% SYNTAX
%   [kernels] = function_CreateLPAKernels1D(m,H,WindowTypeCell)
%
% DESCRIPTION
%   The function generates cell array of the LPA kernels of order m with scales
%   h_i from a set of scales H and window-types specified in 'WindowTypeCell'. 
%
%   m - is an order LPA (m = 0,1,2,...). The used polynomials are of 
%       PolType='Standard' i.e. mononials.
%
%   H - is an array of length J of scales h_i. H must be ordered is 
%   ascending order.
%
%   WindowTypeCell - is a cell array of 'WindowType'. 'WindowType' is a 
%               type of window function w(x). It can be: 
%               'Gaussian' (default), 'GaussianLeft', 'GaussianRight',
%               'Rectangular', 'RectangularLeft', 'RectangularRight',
%               'Treecube', 'Hermitian', 
%               'Exponential', 'ExponentialLeft', 'ExponentialRight',
%               'InterpolationWindow1', 'InterpolationWindow2', 
%               'InterpolationWindow3'
%
% RETURNS
%   kernels - is a cell array of LPA convolution kernels of size 
%   length(WindowTypeCell)xJ.
%
% REMARK
%   For more details of how the convolution kernels are created read
%   function_GetKernel.
%
% Dmitriy Paliy. Tampere University of Technology. TICSP. 16-02-2005
% dmitriy.paliy@tut.fi


lenh=length(H);

kernels=cell([length(WindowTypeCell),lenh]);

for i = 1:length(WindowTypeCell),
    
    wtype = WindowTypeCell{i};
    
    for s=1:lenh,
        % the kernel size
        if strcmp(wtype,'Gaussian')|strcmp(wtype,'GaussianLeft')|strcmp(wtype,'GaussianRight')
            sigma_winds = H(s)./9;
        else
            sigma_winds = H(s);
        end;

        [gh] = function_GetKernel1D(H(s),sigma_winds,m,wtype);
        kernels{i,s}=gh(:);
    end;
end;