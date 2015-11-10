function [y] = function_Phi(x,h,m,PolType,derivative)

% SYNTAX
%   [y] = function_Phi(x,h,m,PolType,derivative)
%   [y] = function_Phi(x,h,m,PolType)
%   [y] = function_Phi(x,h,m)
%   
% DESCRIPTION
%   Polynomial function of x of different types with scale parameter h and 
%   order of polynom m.
% 
%   m - is an order of LPA, arbitrary positive integer (m>=0) for mononials 
%   and for the orthonormal polynomials m=0,1,2.
%
%   PolType - is a polynomial set type: 'Standard', 'Legendre',
%             'Hermitian', 'Lagrange', 'LagrangeNonSym', 'Exponential', 
%             'ExponentialNonSym'
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
% Dmitriy Paliy. Tampere University of Technology. TICSP. 16-02-2005
% dmitriy.paliy@tut.fi


if nargin<5, derivative = 0; end;
if nargin<4, PolType = 'Standard'; end;

d = derivative;

rm = rem(m,2);

switch PolType
    case 'Standard'
        if m<d, y = 0; else y = (1/h)^d*(x/h)^(m-d)/factorial(m-d); end;
        
    case 'Legendre'        
        switch m
            case 0
                if d>0, y = 0; else y = sqrt(1/2); end;
            case 1
                switch d
                    case 0
                        y = sqrt(3/2)*(x/h);
                    case 1
                        y = sqrt(3/2)*(1/h);
                    otherwise
                        y = 0;
                end;
            case 2
                switch d
                    case 0
                        y = sqrt(5/2)*(3*(x/h)^2-1)/2;
                    case 1
                        y = sqrt(5/2)*(3/h)*(x/h);
                    case 2
                        y = sqrt(5/2)*(3/(h^2));
                    otherwise
                        y = 0;
                end;
        end;

    case 'Hermitian'
        switch m
            case 0
                if d>0, y = 0; else y = 1; end;
            case 1                
                switch d
                    case 0
                        y = (x/h);      
                    case 1
                        y = (1/h);
                    otherwise
                        y = 0;
                end;
            case 2
                switch d
                    case 0
                        y = sqrt(1/2)*((x/h)^2-1)/2;
                    case 1
                        y = sqrt(1/2)*(x/h)/h;
                    case 2
                        y = sqrt(1/2)*(1/h)/h;
                    otherwise
                        y = 0;
                end;
        end;
        
    case 'Lagrange'
        switch m
            case 0
                if d>0, y = 0; else y = 1; end;
            case 1
                switch d
                    case 0
                        y = x*sqrt(3/(h*(h+1)));
                    case 1
                        y = sqrt(3/(h*(h+1)));
                    otherwise
                        y = 0;
                end;                
            case 2
                switch d
                    case 0
                        y = (3*(x^2) - h*(h+1))*...
                            sqrt(5/(h*(h+1)*(2*h+3)*(2*h-1)));
                    case 1
                        y = 6*x*sqrt(5/(h*(h+1)*(2*h+3)*(2*h-1)));
                    case 2
                        y = 6*sqrt(5/(h*(h+1)*(2*h+3)*(2*h-1)));
                    otherwise
                        y = 0;
                end;
        end;
        
    case 'LagrangeNonSym'
        switch m
            case 0
                if d>0, y = 0; else y = 1; end;
            case 1
                switch d
                    case 0
                        y = (2*x-h)*sqrt(3/(h*(h+2)));                        
                    case 1
                        y = 2*sqrt(3/(h*(h+2)));
                    otherwise
                        y = 0;
                end;
            case 2
                switch d
                    case 0
                        y = (6*x^2 - 6*x*h + h*(h-1))*...
                            sqrt(5/(h*(h+2)*(h+3)*(h-1)));
                    case 1
                        y = (12*x - 6*h)*...
                            sqrt(5/(h*(h+2)*(h+3)*(h-1)));
                    case 2
                        y = 12*sqrt(5/(h*(h+2)*(h+3)*(h-1)));
                    otherwise
                        y = 0;
                end;
        end;
        
    case 'Exponential'
        gamma = exp(-1/h);
        switch m
            case 0
                if d>0, y = 0; else y = 1; end;
            case 1
                switch d
                    case 0
                        y = x*(1-gamma)/sqrt(2*gamma);
                    case 1
                        y = (1-gamma)/sqrt(2*gamma);
                    otherwise
                        y = 0;
                end;
            case 2
                switch d
                    case 0
                        y = (-2*gamma^2+(1-gamma)^2*x^2)/...
                            sqrt(2*gamma*(1+8*gamma+gamma^2));
                    case 1
                        y = (2*(1-gamma)^2*x)/...
                            sqrt(2*gamma*(1+8*gamma+gamma^2));
                    case 2
                        y = (2*(1-gamma)^2)/...
                            sqrt(2*gamma*(1+8*gamma+gamma^2));
                    otherwise
                        y = 0;
                end;
        end;
        
    case 'ExponentialNonSym'
        gamma = exp(-1/h);
        switch m
            case 0
                if d>0, y = 0; else y = 1; end;
            case 1
                switch d
                    case 0
                        y = (x*(1-gamma)-gamma)/sqrt(gamma);
                    case 1
                        y = (1-gamma)/sqrt(gamma);
                    otherwise
                        y = 0;
                end;
            case 2
                switch d
                    case 0
                        y = (2*gamma^2-(1+3*gamma)*(1-gamma)*x+x^2*(1-gamma)^2)/(2*gamma);
                    case 1
                        y = (-(1+3*gamma)*(1-gamma)+x*2*(1-gamma)^2)/(2*gamma);
                    case 2
                        y = (2*(1-gamma)^2)/(2*gamma);
                    otherwise
                        y = 0;
                end;
                
        end;
end