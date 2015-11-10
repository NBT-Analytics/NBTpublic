function [w, A, C, sbc, fpe, aic, th]=arfit(v, pmin, pmax, selector, no_const, min_order)
%ARFIT	Stepwise least squares estimation of multivariate AR model.
%
%  [w,A,C,SBC,FPE,th]=ARFIT(v,pmin,pmax) produces estimates of the
%  parameters of a multivariate AR model of order p,
%
%      v(k,:)' = w' + A1*v(k-1,:)' +...+ Ap*v(k-p,:)' + noise(C),
%
%  where p lies between pmin and pmax and is chosen as the optimizer
%  of Schwarz's Bayesian Criterion. The input matrix v must contain
%  the time series data, with columns of v representing variables
%  and rows of v representing observations.  ARFIT returns least
%  squares estimates of the intercept vector w, of the coefficient
%  matrices A1,...,Ap (as A=[A1 ... Ap]), and of the noise covariance
%  matrix C.
%
%  As order selection criteria, ARFIT computes approximations to
%  Schwarz's Bayesian Criterion, to the logarithm of Akaike's Final
%  Prediction Error and to the logarithm of Akaike's Information Criteria.
%  The order selection criteria for models of order pmin:pmax are returned'
%  as the vectors SBC, FPE and AIC.
%
%  The matrix th contains information needed for the computation of
%  confidence intervals. ARMODE and ARCONF require th as input
%  arguments.
%
%  If the optional argument SELECTOR is included in the function call,
%  as in ARFIT(v,pmin,pmax,SELECTOR), SELECTOR is used as the order
%  selection criterion in determining the optimum model order. The
%  three letter string SELECTOR must have one of the three values 'sbc'
%  'aic, or 'fpe'. (By default, Schwarz's criterion SBC is used.) If the
%  bounds pmin and pmax coincide, the order of the estimated model
%  is p=pmin=pmax.
%
%  If the function call contains the optional argument 'zero' as the
%  fourth or fifth argument, a model of the form
%
%         v(k,:)' = A1*v(k-1,:)' +...+ Ap*v(k-p,:)' + noise(C)
%
%  is fitted to the time series data. That is, the intercept vector w
%  is taken to be zero, which amounts to assuming that the AR(p)
%  process has zero mean.
%
%  If the optional argument EARLYSTOP is included in the function call,
%  as in ARFIT(v,pmin,pmax,SELECTOR,EARLYSTOP), EARLYSTOP is used as
%  stopping criterion when choosing the optimal model order. If
%  EARLYSTOP>=1, then the chosen order will be that having minimum value of
%  the corresponding model order selection criterion. IF EARLYSTOP<1,then
%  the order for which the criterion SELECTOR has reached the value:
%  SELECTOR(PMIN)-EARLYSTOP*(SELECTOR(PMIN)-SELECTOR(PMAX)). 
% 
% -------------------------------------------------------------------------
% IMPORTANT NOTE:
% This function is a modified version of the function
% arfit.m included in ARfit. For the latest release of ARFit please visit
% ARfit's official site:
% http://www.gps.caltech.edu/~tapio/arfit/
%
% The modifications were performed by:
% Germán Gómez-Herrero 
% german.gomezherrero@tut.fi
% http://www.cs.tut.fi/~gomezher/index.htm
%
% This modified version is available at the URL:
% http://www.cs.tut.fi/~gomezher/projects/eeg/software.htm
%
% This modified version of arsim.m has these new features:
% - The input data can be now of class 'ddataset'
% - The AIC criterion is also computed
% - The user can specify an early-stopping criterion for avoiding
%   overlearning when the model order selection criterion slows very slowly
%   but monotonically (i.e. without reaching a local minimum).
%
% -------------------------------------------------------------------------

%  Last modification on 19-March-2008 by German Gomez-Herrero,
%  german.gomezherrero@tut.fi

%  Modified 14-Oct-00
%  Authors: Tapio Schneider
%           tapio@gps.caltech.edu
%
%           Arnold Neumaier
%           neum@cma.univie.ac.at

if isa(v,'ddataset'),
    v = load(v);
end

% n: number of observations; m: dimension of state vectors
[n,m]   = size(v);
if n < m,
    v = v';
    [n,m]   = size(v);
end

if (pmin ~= round(pmin) || pmax ~= round(pmax))
    error('Order must be integer.');
end
if (pmax < pmin)
    error('PMAX must be greater than or equal to PMIN.')
end

% set defaults and check for optional arguments
if nargin < 6 || isempty(min_order),
    min_order = 1;
end
if (nargin == 3)              % no optional arguments => set default values
    mcor       = 1;               % fit intercept vector
    selector   = 'sbc';	          % use SBC as order selection criterion
elseif (nargin == 4)          % one optional argument
    if strcmp(selector, 'zero')
        mcor     = 0;               % no intercept vector to be fitted
        selector = 'sbc';	          % default order selection
    else
        mcor     = 1; 		  % fit intercept vector
    end
elseif (nargin > 4)          % two or more optional arguments
    if strcmp(no_const, 'zero')
        mcor     = 0;               % no intercept vector to be fitted
    else
        error(['Bad argument. Usage: ', ...
            '[w,A,C,SBC,FPE,th]=AR(v,pmin,pmax,SELECTOR,''zero'')'])
    end
end

ne  	= n-pmax;               % number of block equations of size m
npmax	= m*pmax+mcor;          % maximum number of parameter vectors of length m

if (ne <= npmax)
    error('Time series too short.')
end

% compute QR factorization for model of order pmax
[R, scale]   = arqr(v, pmax, mcor);

% compute approximate order selection criteria for models
% of order pmin:pmax

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This line has been modified by Germán Gómez-Herrero
[sbc, fpe, aic]   = arord(R, m, mcor, ne, pmin, pmax);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% get index iopt of order that minimizes the order selection
% criterion specified by the variable selector
[val, iopt]  = min(eval(selector));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These code has been introduced by Germán Gómez-Herrero
% if min_order flag was used
if min_order,
    ivals = eval(selector);
    irange = ivals(1)-val;
    [val2,iopt2] = find(ivals<ivals(1)-0.9*irange);
    if ~isempty(iopt2),
        iopt = iopt2(1);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% select order of model
popt         = pmin + iopt-1; % estimated optimum order
np           = m*popt + mcor; % number of parameter vectors of length m

% decompose R for the optimal model order popt according to
%
%   | R11  R12 |
% R=|          |
%   | 0    R22 |
%
R11   = R(1:np, 1:np);
R12   = R(1:np, npmax+1:npmax+m);
R22   = R(np+1:npmax+m, npmax+1:npmax+m);

% get augmented parameter matrix Aaug=[w A] if mcor=1 and Aaug=A if mcor=0
if (np > 0)
    if (mcor == 1)
        % improve condition of R11 by re-scaling first column
        con 	= max(scale(2:npmax+m)) / scale(1);
        R11(:,1)	= R11(:,1)*con;
    end;
    Aaug = (R11\R12)';

    %  return coefficient matrix A and intercept vector w separately
    if (mcor == 1)
        % intercept vector w is first column of Aaug, rest of Aaug is
        % coefficient matrix A
        w = Aaug(:,1)*con;        % undo condition-improving scaling
        A = Aaug(:,2:np);
    else
        % return an intercept vector of zeros
        w = zeros(m,1);
        A = Aaug;
    end
else
    % no parameters have been estimated
    % => return only covariance matrix estimate and order selection
    % criteria for ``zeroth order model''
    w   = zeros(m,1);
    A   = [];
end

% return covariance matrix
dof   = ne-np;                % number of block degrees of freedom
C     = R22'*R22./dof;        % bias-corrected estimate of covariance matrix

% for later computation of confidence intervals return in th:
% (i)  the inverse of U=R11'*R11, which appears in the asymptotic
%      covariance matrix of the least squares estimator
% (ii) the number of degrees of freedom of the residual covariance matrix
invR11 = inv(R11);
if (mcor == 1)
    % undo condition improving scaling
    invR11(1, :) = invR11(1, :) * con;
end
Uinv   = invR11*invR11';
th     = [dof zeros(1,size(Uinv,2)-1); Uinv];



