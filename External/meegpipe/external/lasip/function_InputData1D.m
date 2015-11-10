function [z] = function_InputData(x,sigma,Type,alpha)

% Generates a 1D signal
%
% SYNTAX
%   [z] = function_InputData(x,sigma,Type,alpha)
% 
% DESCRIPTION
%   Generates a noisy signal z(x), where:
%
%   x - is a set of arguments. Ususally, x is from [0,1].
%
%   sigma - is a noise parameter which consists of 2 parameters sigma(1) 
%   and sigma(2) (sigma(2)=0 by default). The noise probability density 
%   is a mix of two Gaussian distributions different only by their variances 
%   (sigma_noise(1) and sigma_noise(2)). The parameter 'alpha' defines a 
%   proportion of the high variance random (impulses/outliers) in the 
%   sequence of experiments:
%
%   z(x) = alpha*z0(x) + (1-alpha)*z1(x),
%
%   where z0(x) = N(0, sigma_noise(1)^2) and z1(x) = N(0, sigma_noise(2)^2), and 
%   0<=alpha<=1.
%
%   Type - is a type of signal. Can be: 'StepWise' (default), 'StepWise1',
%   'StepWise2', 'Blocks', 'Heavisine', 'Doppler', 'Bumps'.
%
%   alpha - is a percentage of noise sigma(1). For instance, sigma = [1 10] and alpha=0.95
%   mean the 95% of the noise with std sigma(1) = 1 and 5% of the noise
%   with sigma(2) = 10.
%   alpha = 1 by default.
%
% Dmitriy Paliy. Tampere University of Technology. TICSP. 16-02-2005
% dmitriy.paliy@tut.fi

if nargin<4, alpha = 1; end;
if nargin<3, Type = 'StepWise'; end;
if length(sigma)<=1, sigma(2)=0; end;

y = zeros(size(x));

switch Type
    case 'StepWise'
        y(x<=1/3)=2;
        y((x>1/3)&(x<=2/3))=1;
        y((x>2/3)&(x<=1))=3;
        
    case 'StepWise1'
        y(x<=1/3)=2;
        y((x>1/3)&(x<=2/3))=1;
        y((x>2/3)&(x<=1))=2;
        
    case 'StepWise2'
        y(x<0)=10;
        y((x>=0)&(x<=1/2))=0;
        y(x>1/2)=1;
        y(x>1)=10;
        
        
    case 'Blocks'
        tt=[0.1 0.13 0.15 0.23 0.25 0.40 0.44 0.65 0.76 0.78 0.81];
        hh=[4 -5 3 -4   5 -4.2 2.1 4.3 -3.1 2.1 -4.2];
        s=0; 
        Y=zeros(size(x)); U=Y;

        for t=[tt]
        s=s+1;
        U=U+hh(s)*(1+sign(x-t))/2; 
        end
        Y=U;
        st_Y=std(Y);

        Y_N=(7/st_Y)*Y;
        y = Y_N;
        
    case 'Heavisine'
        Y=4*sin(4*pi*x)-sign(x-0.3)-sign(.72-x);%% true signal
        Y_N=Y*(7/std(Y));
        y = Y_N;
        
    case 'Bumps'
        tt=[0.1 0.13 0.15 0.23 0.25 0.40 0.44 0.65 0.76 0.78 0.81];
        hh=[4 5 3 4   5 4.2 2.1 4.3 3.1 2.1 4.2];
        ww=[.005 .005 .006 .01 .01 .03 .01 .01 .005 .008 .005];
        s=0;
        Y=zeros(size(x)); U=Y;

        for t=[tt]
        s=s+1;
        U=U+hh(s)*(1+abs((x-t)/ww(s))).^(-4); end
        Y=U;
        Y_N=(7/std(Y))*Y; %%signal with noise
        y = Y_N;
        
    case 'Doppler'
        e=0.05;
        Y=sqrt(x.*(1-x)).*sin(2*pi*(1+e)./(x+e)); %% true signal
        Y_N=(7/std(Y))*Y; %%signal with noise
        y = Y_N;
        
end;

n1 = randn(size(x));
n2 = randn(size(x));
ind=(rand(1,length(x))>=alpha);

noise=(1-ind).*sigma(1).*n1+ind.*sigma(2).*n2;

z = y + noise;
