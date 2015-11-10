function ci  = bootci(nboot,bootfun,varargin)
%BOOTCI Bootstrap Confidence Interval
%   CI = BOOTCI(NBOOT,BOOTFUN,...) computes the 95 percent BCa bootstrap
%   confidence interval of the statistic defined by the function BOOTFUN.
%   NBOOT is a positive integer indicating the number of bootstrap data
%   samples used in the computation. BOOTFUN is a function handle specified
%   with @, and must return a scalar. The third and later input arguments to
%   BOOTCI are data (scalars, column vectors, or matrices) that are used to
%   create inputs to BOOTFUN. BOOTCI creates each bootstrap sample by sampling
%   with replacement from the rows of the non-scalar data arguments (these
%   must have the same number of rows). Scalar data are passed to BOOTFUN
%   unchanged. CI is a vector containing the lower and upper bounds of the
%   confidence interval.
%
%   CI = BOOTCI(NBOOT,{BOOTFUN,...},'alpha',ALPHA) computes the 100*(1-ALPHA)
%   percent BCa bootstrap confidence interval of the statistic defined by the
%   function BOOTFUN. ALPHA is a scalar between 0 and 1. The default value of
%   ALPHA is 0.05. A cell array groups BOOTFUN and the arguments used to create
%   inputs to it. ALPHA and any other arguments to BOOTCI appear outside the
%   cell array.
%
%   CI = BOOTCI(NBOOT,{BOOTFUN,...},...,'type',TYPE) computes the bootstrap
%   confidence interval of the statistic defined by the function BOOTFUN.
%   TYPE is the confidence interval type, specifying different methods of
%   computing the confidence interval. TYPE is a string chosen from
%       'norm' or 'normal':               normal approximated interval with
%                                         bootstrapped bias and standard
%                                         error;                                        
%       'per' or 'percentile':            basic percentile method; 
%       'cper' or 'corrected percentile': bias corrected percentile method;
%       'bca' :                           bias corrected and accelerated 
%                                         percentile method;
%       'stud' or 'student':              studentized confidence interval.
%   The default value of TYPE is 'bca'.
%
%   CI = BOOTCI(NBOOT,{BOOTFUN,...},...,'type','stud','nbootstd',NBOOTSTD)
%   computes the studentized bootstrap confidence interval of the statistic
%   defined by the function BOOTFUN. The standard error of the bootstrap
%   statistics is estimated using bootstrap with NBOOTSTD bootstrap data
%   samples. NBOOTSTD is a positive integer value. The default value of
%   NBOOTSTD is 100.
%
%   CI = BOOTCI(NBOOT,{BOOTFUN,...},...,'type','stud','stderr',STDERR)
%   computes the studentized bootstrap confidence interval of statistics
%   defined by the function BOOTFUN. The standard error of the bootstrap
%   statistics is evaluated by the function STDERR. STDERR is a function
%   handle created using @. STDERR should take the same arguments as
%   BOOTFUN and return the standard error of the statistic computed by
%   BOOTFUN.
%
%   Example:
%     Compute the confidence interval for the capability index in
%     statistical process control:
%          y = normrnd(1,1,30,1);                  % simulated process data
%          LSL = -3;  USL = 3;                     % process specifications
%          capable = @(x) (USL-LSL)./(6* std(x));  % process capability
%          bootci(2000,capable, y)                 % Bca confidence interval
%          bootci(2000,{capable, y},'type','stud') % studentized confidence interval
%
%   See also: BOOTSTRP, JACKKNIFE.

% The BCa method is described in the following references:
%
%     T.J. DiCicio and B. Efron (1996), "Bootstrap confidence intervals,"
%     Statistical Science, v. 11, n. 3, pp. 189-228.
% 
%     B. Efron and R.J. Tibshirani (1993), An Introduction to the
%     Bootstrap, Chapman & Hall, New York.
%
% Their formula involves a Z0 factor that is computed using the proportion
% of bootstrap values less than the original sample value.  In order to get
% reasonable results when the sample is lumpy, we include half of the
% bootstrap values that are tied with the original sample value when we
% compute Z0.

% Copyright 2005-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $  $Date: 2008/06/20 09:04:53 $

if nargin<2
    error('stats:bootci:TooFewInputs','BOOTCI requires at least two arguments.');
end;
if nboot<=0 || nboot~=round(nboot)
    error('stats:bootci:BadNboot','NBOOT must be a positive integer.')
end; 

if ~iscell(bootfun) % default syntax
    type = 'bca';
    alpha = .05;
    fun = bootfun;
    data = varargin;
else % syntax with optional type, alpha, nbootstd, and stderrfun name/value pairs
    fun = bootfun{1};
    data = {bootfun{2:end}};
    pnames = {'type' ,'alpha', 'stderr','nbootstd'};
    dflts =  {'bca',.05, [],100};
    [eid,errmsg,type,alpha,stderrfun,nbootstd] = statgetargs(pnames, dflts, varargin{:});
    if ~isempty(eid)
        error(sprintf('stats:bootci:%s',eid),errmsg);
    end
end;
 
% error check for the bootfun
try 
    bootstat = fun(data{:});    
catch ME
    throw(addCause(MException('stats:bootci:BadBootfun',...
                              'Error evaluating BOOTFUN function ''%s''.',...
                              func2str(fun)),...
                   ME));
end
if any(~isfinite(bootstat))
        error('stats:bootci:NonfiniteBootfun','BOOTFUN returns a NaN or Inf.');
end;
if any(~isscalar(bootstat))
        error('stats:bootci:NonscalarBootfun','BOOTFUN must return a scalar.');
end;
 
% call sub-functions to compute the intervals 
switch (lower(type))
    case {'norm','normal'}
        ci = bootnorm(nboot,fun,alpha,data{:});
    case {'per','percentile'}
        ci = bootper(nboot,fun,alpha,data{:});
    case {'cper', 'corrected percentile'}
        ci = bootcper(nboot,fun,alpha,data{:});
    case 'bca'
        ci = bootbca(nboot,fun,alpha,data{:});        
    case {'stud','student'}
        if isempty(stderrfun) % studentized with bootstrap error
            if nbootstd<=0 || nbootstd~=round(nbootstd)
                error('stats:bootci:BadNbootstd','NBOOTSTD must be a positive integer.')
            end;
            ci = bootstud1(nboot,fun,alpha,nbootstd,data{:});                    
        else  % studentized with stderrfun fun
            % error check for stderrfun
            try 
                out=stderrfun(data{:});
            catch ME
                throw(addCause(MException('stats:bootci:BadStderr',...
                                  'Error evaluating STDERR function ''%s''.', ...
                                  func2str(stderrfun)),...
                               ME));
            end
            if any(~isfinite(out))
                error('stats:bootci:NonfiniteStderr','STDERR returns a NaN or Inf.');
            end;
            if any(~isscalar(out))
                error('stats:bootci:NonscalarStderr','BOOTFUN must return a scalar.');
            end;
            ci = bootstud2(nboot,fun,alpha,stderrfun,data{:});
        end;
    otherwise 
        error('stats:bootci:BadType','BAD confidence interval type')
end;
 
%-------------------------------------------------------------------------    
function ci = bootnorm(nboot,bootfun,alpha,varargin)
% normal approximation interval
% A.C. Davison and D.V. Hinkley (1996), p198-200
 
stat = bootfun(varargin{:});
bstat = bootstrp(nboot,bootfun,varargin{:}); % bootstrap statistics
se = std(bstat);   % standard deviation estimate
bias =mean(bstat-stat); % bias estimate
za = norminv(alpha/2);   % normal confidence point
lower = stat - bias + se*za; % lower bound
upper = stat - bias - se*za;  % upper bound
ci = [lower;upper];        
 
 
%-------------------------------------------------------------------------
function ci = bootper(nboot,bootfun,alpha,varargin)
% percentile bootstrap CI
 
bstat = bootstrp(nboot,bootfun,varargin{:}); % bootstrap statistics
pct1 = 100*alpha/2;
pct2 = 100-pct1;
lower = prctile(bstat,pct1); 
upper = prctile(bstat,pct2);
ci =[lower;upper];
 
%-------------------------------------------------------------------------
function ci = bootcper(nboot,bootfun,alpha,varargin)
% corrected percentile bootstrap CI
% B. Efron (1982), "The jackknife, the bootstrap and other resampling
% plans", SIAM.
 
stat = bootfun(varargin{:});
bstat = bootstrp(nboot,bootfun,varargin{:}); % bootstrap statistics
% stat is transformed to a normal random variable z0.
% z0 = invnormCDF[ECDF(stat)]
z_0 = fz0(bstat,stat);
z_alpha = norminv(alpha/2); % normal confidence point
 
% transform z0 back using the invECDF[normCDF(2z0-za)] and
% invECDF[normCDF(2z0+za)] 
pct1 = 100*normcdf(2*z_0-z_alpha); 
pct2 = 100*normcdf(2*z_0+z_alpha);
lower = prctile(bstat,pct2);  % inverse ECDF
upper = prctile(bstat,pct1);
ci = [lower;upper];
 
 
%-------------------------------------------------------------------------
function ci = bootbca(nboot,bootfun,alpha,varargin)
% corrected and accelerated percentile bootstrap CI
% T.J. DiCiccio and B. Efron (1996), "Bootstrap Confidence Intervals",
% statistical science, 11(3)
 
stat = bootfun(varargin{:});
bstat = bootstrp(nboot,bootfun,varargin{:});% bootstrap statistics
% same as bootcper, this is the bias correction
z_0 = fz0(bstat,stat);
 
% acceleration finding, see DiCiccio and Efron (1996)
jstat = jackknife(bootfun,varargin{:});
score = (length(varargin{:})-1).*(bootfun(varargin{:})-jstat); % score function at stat;
skew = sum(score.^3)./(sum(score.^2).^1.5);  %skewness of the score function
acc =  skew/6;  % acceleration
% transform back with bias corrected and acceleration
z_alpha1 = norminv(alpha/2);
z_alpha2 = -z_alpha1;
pct1 = 100*normcdf(z_0 +(z_0+z_alpha1)/(1-acc*(z_0+z_alpha1)));
pct2 = 100*normcdf(z_0 +(z_0+z_alpha2)/(1-acc*(z_0+z_alpha2)));
% inverse of ECDF
ci = sort([prctile(bstat,pct2); prctile(bstat,pct1)]);
 
%-------------------------------------------------------------------------
function ci = bootstud1(nboot,bootfun,alpha,nbootstd,varargin)
% studentized bootstrap CI with bootstrp to estimate the se
% T.J. DiCiccio and B. Efron (1996), "Bootstrap Confidence Intervals",
% statistical science, 11(3)
 
[bstat,bootsam] = bootstrp(nboot,bootfun,varargin{:});% bootstrap statistics
stat = bootfun(varargin{:});% statistics from the original sample
 
la = length(varargin);
scalard = zeros(la,1);
% find out the size information in varargin.
for k = 1:la
   [row,col] = size(varargin{k});
   if max(row,col) == 1
      scalard(k) = 1;
   end
   if row == 1 && col ~= 1
      varargin{k} = varargin{k}(:);
   end
end

db = cell(la,1);
for k = 1:la
     % store the bootstrap data samples in a cell array
     if scalard(k) == 0
        db{k} = varargin{k}(bootsam);
     else
        db{k} = varargin{k};
     end
end

% standard errors for the each bootstrap estimates
sd_t = std(bootstrp(nbootstd,bootfun,db{:}));
% studentized statistics
tstat = (bstat-stat)./sd_t';
% percentiles for the studentized stats are computed.
lower = prctile(tstat,100*alpha/2);
upper = prctile(tstat,100*(1-alpha/2));
 
% back to the original stats from the studentized stats
ci = [lower*std(bstat)+stat;upper*std(bstat)+stat];
 
%-------------------------------------------------------------------------
function ci = bootstud2(nboot,bootfun,alpha,stderrfun,varargin)
% studentized bootstrap CI with a supplied function for the standard error
% of the bootstrapped statistics
% T.J. DiCiccio and B. Efron (1996), "Bootstrap Confidence Intervals",
% statistical science, 11(3)
 
[bstat,bootsam] = bootstrp(nboot,bootfun,varargin{:});% bootstrap statstics
stat = bootfun(varargin{:});% statistics from the original sample
 
la = length(varargin);
scalard = zeros(la,1);
% find out the size information in varargin.
for k = 1:la
   [row,col] = size(varargin{k});
   if max(row,col) == 1
      scalard(k) = 1;
   end
   if row == 1 && col ~= 1
      varargin{k} = varargin{k}(:);
   end
end

db = cell(la,1);
for k = 1:la
     % store the bootstrap data samples in a cell array
     if scalard(k) == 0
        db{k} = varargin{k}(bootsam);
     else
        db{k} = varargin{k};
     end
end
 
% standard errors for the each bootstrap estimates
sd_t = stderrfun(db{:}); 
% studentized statistics
tstat = (bstat-stat)./sd_t';
% percentiles for the studentized stats
lower = prctile(tstat,100*alpha/2);
upper = prctile(tstat,100*(1-alpha/2));
 
% back to the original stats from the studentized stats
ci = [lower*std(bstat)+stat;upper*std(bstat)+stat];
 
% -------------------------
function z0=fz0(bstat,stat)
% Compute bias-correction constant z0
z0 = norminv((sum(bstat<stat)+sum(bstat==stat)/2)./length(bstat));
 


