function [w] = function_WindowFunction(x,h,WindowType)

% Window function w(x)
%
%   [w] = function_WindowFunction(x,h,WindowType)
%   [w] = function_WindowFunction(x,h)
%
%   x - is an argument of function w
% 
%   h - estimator bandwidth (any real number);
%
%   WindowType: 'Gaussian' (default), 'GaussianLeft', 'GaussianRight',
%               'Rectangular', 'RectangularLeft', 'RectangularRight',
%               'Treecube', 'Hermitian', 
%               'Exponential', 'ExponentialLeft', 'ExponentialRight',
%               'InterpolationWindow1', 'InterpolationWindow2', 'InterpolationWindow3'
%
% Dmitriy Paliy. Tampere University of Technology. TICSP. 16-02-2005
% dmitriy.paliy@tut.fi

w = 0;

if nargin<3, WindowType='Gaussian'; end;

switch WindowType
    case 'Rectangular'
        if abs(x/h)<=1, w = (1/h)*(1/2); end;
        
    case 'RectangularRight'
        if (((x/h)<=2)&((x/h)>=0)), w = (1/h)*(1/2); end;
        
    case 'RectangularLeft'
        if (((x/h)<=0)&((x/h)>=-2)), w = (1/h)*(1/2); end;

    case 'Hermitian'
        w = exp(-x*x/(2*h*h))/sqrt(2*pi);
        
    case 'Exponential'
        gamma = exp(-1/h);
        w = (gamma^abs(x))*(1-gamma)/(1+gamma);
        
    case 'ExponentialRight'
        gamma = exp(-1/h);
        w = (x>=0)*(gamma^x)*(1-gamma);
        
    case 'ExponentialLeft'
        gamma = exp(-1/h);
        w = (x<=0)*(gamma^x)*(1-gamma);
        
    case 'Gaussian'
        w = (1/(sqrt(2*pi)*h))*exp(-x^2/(2*h^2));
        
    case 'GaussianLeft'
        w = (1/(sqrt(2*pi)*h))*exp(-x^2/(2*h^2));
        w = ((x/h)<=0)*w;

    case 'GaussianRight'
        w = (1/(sqrt(2*pi)*h))*exp(-x^2/(2*h^2));
        w = ((x/h)>=0)*w;
        
%     Interpolation    
    case 'InterpolationWindow1'
        if x==0,
            w = 10^10;
        else
            w = (1/h)*((abs(x/h).^(-2)));
        end;
        if w >= 10^10, w = 10^10; end;

    case 'InterpolationWindow2'
        if x==0,
            w = 10^10;
        else
            w = (1/h)*(abs(x/h)<=1).*(cos(abs(x/h).*pi/2).^2)./(abs(x/h).^2);
        end;
        if w >= 10^10, w = 10^10; end;
        
    case 'InterpolationWindow3'
        if x==0,
            w = 10^10;
        else
            w = (1/h)*(abs(x/h).^(-2)).*...
                (((1-abs(x/h))).^2).*(abs(x/h)<=1);
        end;
        if w >= 10^10, w = 10^10; end;

end;