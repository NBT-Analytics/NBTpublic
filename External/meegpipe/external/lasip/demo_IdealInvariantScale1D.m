% The estimator with the ideal invariant scale. Example illustrates a 
% problem of scale selection. As results it shows on the left: a) the noisy 
% signal; b) the estimate; c) the estimation error. On the right: the mean 
% squared estimation error as a function of the scale h.
%
% The invariant ideal scale h of estimator with order m is found for the 
% noisy signal z(x) knowing the true signal y(x). Ideal scale is selected 
% in sense of minimization of the mean square error.
%
% Illustration of using the function [yh, opt_h, err_h, R2] = 
% function_OracleEstimator(...);
%
% SYNTAX
%   [yh, opt_h, err_h, R2] = function_OracleEstimator(z,h,y,m,WindowType,estimator);
%   [yh, opt_h, err_h, R2] = function_OracleEstimator(z,h,y,m,WindowType);
%   [yh, opt_h, err_h, R2] = function_OracleEstimator(z,h,y,m);
%   [yh, opt_h, err_h, R2] = function_OracleEstimator(z,h,y);
%
% DESCRIPTION
%   The function returns the ORACLE estimate of a signal. The "oracle" or
%   "ideal" scale assumes that the true signal is available and can be used
%   for evaluation of the accuracy of the estimation.
%       Here, we select the best scale h assuming that this h is constant
%   and independent on x.
%
%   Here:
%     z - is a 2xn array consists of:
%       a) z(1,1:n) = X_s; is a REGULAR grid of arguments X_s where z is 
%          observed. 
%       b) z(2,1:n) = z; function values.
% 
%   h - is a SET of estimator bandwidth (a set of any real numbers)
%
%   y - is a true signal
%
%   m - is an order of estimator (m = 0 in this example)
%
%   WindowType: 'Gaussian' (default), 'GaussianLeft', 'GaussianRight',
%               'Rectangular', 'RectangularLeft', 'RectangularRight',
%               'Treecube', 'Hermitian', 
%               'Exponential', 'ExponentialLeft', 'ExponentialRight',
%               'InterpolationWindow1', 'InterpolationWindow2', 
%               'InterpolationWindow3'
%
%   estimator = -1 (by default) for invarinat scale selection case
% and
%   estimator >= 0 for a varying scale selection case with a sliding 
%   average window of the length 2*estimator + 1 (2.51)
%
% RETURNS
%   yh - is an optimal estimate (oracle estimate)
%    
%   opt_h - is a array of size (1,n) of optimal h for every x (in the case 
%   when h is invariant it has the same value for all x).
%     
%   err_h - is a set of mean squared errors for every x.
%     
%   R2 - has a size of array h. it has a form of the sample mean of the
%   squared errors err_h (2.50-2.51).
%
% REMARKS
%   The example is illustrated on Figure 2.7 of the book. For more details 
%   read pp. 36-38 of the book.
%
% Dmitriy Paliy. Tampere University of Technology. TICSP. 16-02-2005
% dmitriy.paliy@tut.fi

clear all

rand('state',0);
randn('state',0);

disp('the started process can take some time...')

% ---------------------------------------------------
% settings of the estimator
% ---------------------------------------------------
WindowType = 'Gaussian'; % window function

m = 0; % order of approximation

estimator = -1; % invariant scale

h = [1:25:800]./100; % a set of scales. practically the cardinality of this 
                    % set is much smaller

% ---------------------------------------------------
% observations
% ---------------------------------------------------
delta = 1/511;
x = 0:delta:1; % arguments
sigma = 0.2; % std of a noise

z(1,:) = x;
z(2,:) = function_InputData1D(x,sigma,'StepWise'); % noisy signal

% ---------------------------------------------------
% true signal
% ---------------------------------------------------
y = function_InputData1D(x,0.0,'StepWise');

% ---------------------------------------------------
% get result
% ---------------------------------------------------
[yh, opt_h, err_h, R2] = function_OracleEstimator1D(z,h,y,m,WindowType,estimator);

% ---------------------------------------------------
% show result
% ---------------------------------------------------
version -release; % get matlab release
matlab_R=str2num(ans);

figure,

subplot(3,2,1), plot(x,z(2,:),'-'), title(['a) Noisy signal']),
if matlab_R>=14,
    ylabel('$z(x)$','interpreter','latex');
else
    ylabel('\itz(\itx)');
end;
subplot(3,2,3), plot(x,yh,'r-'), title('b) Estimate'),
if matlab_R>=14,
    ylabel('$\hat{y}(x)$','interpreter','latex');
else
    ylabel('\ity_{it{est}}(\itx)');
end;
subplot(3,2,5), plot(x,err_h,'-'), title('c) Estimation error'),
if matlab_R>=14,
    ylabel('$r(x)$','interpreter','latex');
    xlabel('$x$','interpreter','latex');
else
    ylabel('\itr(\itx)');
    xlabel('\itx');
end;
    
subplot(1,2,2), 
plot(h,R2,'-'), hold on,
plot(h(R2==min(R2)),min(R2),'ro'), title('d) Error as a function of \it{h}'),
if matlab_R>=14,
    ylabel('$mse(h)$','interpreter','latex');
    xlabel('$h$','interpreter','latex');
else
    ylabel('mse(\ith)');
    xlabel('\ith');
end;

disp('Optimal h     Min error')
disp([num2str(h(R2==min(R2))),'         ',num2str(min(R2))])