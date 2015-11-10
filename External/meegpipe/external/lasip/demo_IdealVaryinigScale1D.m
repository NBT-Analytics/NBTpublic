% The estimator with the ideal varying scale. Example illustrates scale 
% selection knowing true signal. As results it shows on the Figure 'Scales': 
% true signal and noisy signal, the ideal scales for the symmetric, right 
% and left estimators. Figure 'Errors' illustrates errors for the ideal 
% scales for the symmetric, right and left estimators. Figure 'Final Estimates'
% illustarates obtained estimates.
%   Finally, RMS errors are printed for the final symmetric, right and left
% estimates. The fact is thay are significantly lower then error for the
% case with invariant scale.
%
%   The varying ideal scale h of estimator with order m is found for the noisy
% signal z(x) knowing the true signal y(x). Ideal scale is selected in sense 
% of minimization of mean square error.
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
%       Here, we select the best scale h for every x.
%
%   Here:
%     z - is a 2xn array consists of:
%       a) z(1,1:n) = x; is a REGULAR grid of arguments x where z is 
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
%   estimator >= 1 for a varying scale selection case with a sliding 
%   average window of the length 2*estimator  + 1 (2.50-2.51)
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
%   squared errors err_h (2.48).
%
% REMARKS
%   The example is illustarated on Figure 2.8 (p. 37) of the book. For more
%   details read pp. 36-38 of the book.
%
% Dmitriy Paliy. Tampere University of Technology. TICSP. 16-02-2005
% dmitriy.paliy@tut.fi

clear all
rand('state',0);
randn('state',0);

% ---------------------------------------------------
% settings of the estimator
% ---------------------------------------------------
m = 0;

estimator = 0;

h = [1:10:600]./10;

delta = 1/255;
x = 0:delta:1;

% ---------------------------------------------------
% observations
% ---------------------------------------------------
% argumants
z(1,:) = x;
% noisy signal
z(2,:) = function_InputData1D(x,0.2,'StepWise'); % 0.2 is a noise std

% true signal
y = function_InputData1D(x,0.0,'StepWise');

disp('started process can take some time...')

% ---------------------------------------------------
% get results for different window functions
% ---------------------------------------------------
[yh_sym, opt_h_sym, err_h_sym, R2sym] = function_OracleEstimator1D(z,h,y,m,'Gaussian',estimator);

[yh_left, opt_h_left, err_h_left, R2left] = function_OracleEstimator1D(z,h,y,m,'GaussianLeft',estimator);

[yh_right, opt_h_right, err_h_right, R2right] = function_OracleEstimator1D(z,h,y,m,'GaussianRight',estimator);

% ---------------------------------------------------
% show result
% ---------------------------------------------------
version -release; % get matlab release
matlab_R=str2num(ans);

figure('Name','Scales & Errors'),

    subplot(4,2,1)
    plot(x,z(2,:),'-');
    hold on;
    plot(x,y,'r-'), title('True and noisy signals'),
    if matlab_R>=14,
        ylabel('$z(x),y(x)$','interpreter','latex');
    else
        ylabel('\itz(\itx),\ity(\itx)');
    end;

    subplot(4,2,3)
    plot(x,opt_h_sym.*delta,'-'), title('Scales for symmetrical kernels'),
    if matlab_R>=14,
        ylabel('$h_{sym}(x)$','interpreter','latex');
    else
        ylabel('\ith_{\it{sym}}(\itx)');
    end;

    subplot(4,2,5)
    plot(x,opt_h_left.*delta,'-'), title('Scales for left nonsymmetrical kernels');
    if matlab_R>=14,
        ylabel('$h_{left}(x)$','interpreter','latex');
    else
        ylabel('\ith_{\it{left}}(\itx)');
    end;

    subplot(4,2,7)
    plot(x,opt_h_right.*delta,'-'), title('Scales for right nonsymmetrical kernels');
    if matlab_R>=14,
        ylabel('$h_{right}(x)$','interpreter','latex');
        xlabel('$x$','interpreter','latex');
    else
        ylabel('\ith_{\it{right}}(\itx)');
        xlabel('\itx');
    end;

    
    subplot(4,2,2)
    plot(x,z(2,:),'-'),
    hold on;
    plot(x,y,'r-'), title('True and noisy signals'),
    if matlab_R>=14,
        ylabel('$z(x),y(x)$','interpreter','latex');
    else
        ylabel('\itz(\itx),\ity(\itx)');
    end;
    
    subplot(4,2,4)
    plot(x,err_h_sym,'-'), title('Errors using symmetrical kernels'),
    if matlab_R>=14,
        ylabel('$e_{sym}(x)$','interpreter','latex');
    else
        ylabel('\ite_{\it{sym}}(\itx)');
    end;

    subplot(4,2,6),
    plot(x,sqrt(err_h_left),'-'), title('Errors using left nonsymmetrical kernels'),
    if matlab_R>=14,
        ylabel('$e_{left}(x)$','interpreter','latex');
    else
        ylabel('\ite_{\it{left}}(\itx)');
    end;

    subplot(4,2,8),
    plot(x,sqrt(err_h_right),'-'), title('Errors using right nonsymmetrical kernels'),
    if matlab_R>=14,
        ylabel('$e_{right}(x)$','interpreter','latex'),
        xlabel('$x$','interpreter','latex');
    else
        ylabel('\ite_{\it{right}}(\itx)'),
        xlabel('\itx');
    end;
    
    % global MSE errors
    disp('global MSE: R2sym     R2left      R2right')
    [sum(R2sym.^2)/length(R2sym) sum(R2left.^2)/length(R2left) sum(R2right.^2)/length(R2right)]


figure('Name','Final Estimates'),
    
    subplot(3,1,1),
    plot(x,yh_left,'-'), title('Estimates for left nonsymmetrical kernels'),
    if matlab_R>=14,
        ylabel('$\hat{y}_{left}(x)$','interpreter','latex');
    else
        ylabel('\ity_{\it{left}}(\itx)');
    end;

    subplot(3,1,2),
    plot(x,yh_right,'-'), title('Estimates for right nonsymmetrical kernels'),
    if matlab_R>=14,
        ylabel('$\hat{y}_{right}(x)$','interpreter','latex');
    else
        ylabel('\ity_{\it{right}}(\itx)');
    end;
    
    subplot(3,1,3),
    plot(x,yh_sym,'-'), title('Estimates for symmetrical kernels'),
    if matlab_R>=14,
        ylabel('$\hat{y}_{sym}(x)$','interpreter','latex'),
        xlabel('$x$','interpreter','latex');
    else
        ylabel('\ity_{\it{sym}}(\itx)'),
        xlabel('\itx');
    end;