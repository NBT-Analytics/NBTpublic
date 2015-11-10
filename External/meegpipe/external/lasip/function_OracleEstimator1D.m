function [yh, opt_h, err_h, R2] = OracleEstimator(zx,h,y,m,WindowType,estimator)

% The ideal scale h of estimator with order m is found for the 
% noisy signal z(x) knowing the true signal y(x). Ideal scale is selected 
% in sense of minimization of mean square error.
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

if nargin<6, ErrorEstimator = -1; end;
if nargin<5, WindowType = 'Gaussian'; end;
if nargin<4, m = 0; end;

x = zx(1,:);
z = zx(2,:);

sizex = length(x);

sizeh = length(h);

e = ones(size(x)).*100000;
opt_h = ones(size(x)).*h(1);

switch estimator
    case -1
        R2 = ones(size(h))*10000;
    otherwise
        R2 = ones(size(x))*10000;
end;

yh = zeros(size(x));

gh = zeros(size(x));

err_est_window = estimator;

htimebar = timebar(['scale h selection for ',WindowType,' window'],'Progress');
itc=1; totalcounter = sizeh; timebar(htimebar,itc/totalcounter);

for k=1:sizeh,
    itc = itc+1;  timebar(htimebar,itc/totalcounter);

    [gh] = function_GetKernel1D(sizex,h(k),m,WindowType);
    yh_tmp = convn(z,gh,'same');

    e_tmp = abs(yh_tmp - y);

    switch estimator
        case -1

            R2(k) = sum(e_tmp.^2)/sizex;
            if R2(k) == min(R2),
                yh = yh_tmp;
                opt_h(:) = ones(size(opt_h)).*h(k);
                e = e_tmp;
            end;

        otherwise

            % just to avoid border effect
            for j=1:sizex,
                eee = e_tmp(max(1,j-err_est_window):min(sizex,j+err_est_window));
                loc_err(j) = sum(eee.^2)/length(eee);
            end;

            yh(loc_err<=e) = yh_tmp(loc_err<=e);
            opt_h(loc_err<=e) = h(k);
            e(loc_err<=e) = loc_err(loc_err<=e);

            R2 = sqrt(e);
    end;

end;

close(htimebar);

err_h = e;