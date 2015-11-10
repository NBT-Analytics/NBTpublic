function [v]=arsim(w,A,C,alpha,n,ndisc)
%ARSIM	Simulation of AR process.	
%
%  v=ARSIM(w,A,C,alpha,n) simulates n time steps of the AR(p) process
%
%     v(k,:)' = w' + A1*v(k-1,:)' +...+ Ap*v(k-p,:)' + eta(k,:)', 
%
%  where A=[A1 ... Ap] is the coefficient matrix, and w is a vector of
%  intercept terms that is included to allow for a nonzero mean of the
%  process. The vectors eta(k,:) are independent noise vectors with mean
%  zero and covariance matrix C. The noise has a generalized Gaussian
%  distribution with shape parameter alpha. If alpha=2 (default), the noise
%  is normally distributed.
%
%  The p vectors of initial values for the simulation are taken to
%  be equal to the mean value of the process. (The process mean is
%  calculated from the parameters A and w.) To avoid spin-up effects,
%  the first 10^3 time steps are discarded. Alternatively,
%  ARSIM(w,A,C,n,ndisc) discards the first ndisc time steps.
%
% -------------------------------------------------------------------------
% IMPORTANT NOTE:
% This function is a modified version of the function arsim.m included in
% ARfit. For the latest release of ARFit please visit ARfit's official site:
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
% This modified version of arsim.m allows the user to specify the
% distribution of the residuals via the parameter alpha. It requires
% function ggrnd.m
% -------------------------------------------------------------------------


%  Last modification on 19-March-2008 by German Gomez-Herrero,
%  german.gomezherrero@tut.fi

%  Modified 13-Oct-00
%  Author: Tapio Schneider
%          tapio@gps.caltech.edu

  m       = size(C,1);                  % dimension of state vectors 
  p       = size(A,2)/m;                % order of process

  if (p ~= round(p)) 
    error('Bad arguments.'); 
  end

  if (length(w) ~= m || min(size(w)) ~= 1)
    error('Dimensions of arguments are mutually incompatible.')
  end 
  w       = w(:)';                      % force w to be row vector

  % Check whether specified model is stable
  A1 	  = [A; eye((p-1)*m) zeros((p-1)*m,m)];
  lambda  = eig(A1);
  if any(abs(lambda) > 1)
    warning('The specified AR model is unstable.')
  end
  
  % by default the residuals are normally distributed
  if nargin < 5 || isempty(alpha),
      alpha = 2;
  end
  
  % Discard the first ndisc time steps; if ndisc is not given as input
  % argument, use default
  if (nargin < 6) 
    ndisc = 10^3; 
  end
  
  % Compute Cholesky factor of covariance matrix C
  [R, err]= chol(C);                    % R is upper triangular
  if err ~= 0
    error('Covariance matrix not positive definite.')
  end
    
  % Get ndisc+n independent pseudo-random vectors with 
  % covariance matrix C=R'*R
  % 
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % These are the modifications performed by Germán Gómez-Herrero
  %randvec = randn([ndisc+n,m])*R;
  randvec = reshape(ggrnd([(ndisc+n)*m],alpha),ndisc+n,m)*R;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Add intercept vector to random vectors
  randvec = randvec + ones(ndisc+n,1)*w;
  
  % Get transpose of system matrix A (use transpose in simulation because 
  % we want to obtain the states as row vectors)
  AT      = A';

  % Take the p initial values of the simulation to equal the process mean, 
  % which is calculated from the parameters A and w
  if any(w)
    %  Process has nonzero mean    mval = inv(B)*w'    where 
    %             B = eye(m) - A1 -... - Ap; 
    %  Assemble B
    B 	 = eye(m);
    for j=1:p
      B = B - A(:, (j-1)*m+1:j*m);
    end
    %  Get mean value of process
    mval = w / B';

    %  The optimal forecast of the next state given the p previous
    %  states is stored in the vector x. The vector x is initialized
    %  with the process mean.
    x    = ones(p,1)*mval;
  else
    %  Process has zero mean
    x    = zeros(p,m); 
  end
  
  % Initialize state vectors
  u      = [x; zeros(ndisc+n,m)];
  
  % Simulate n+ndisc observations. In order to be able to make use of
  % Matlab's vectorization capabilities, the cases p=1 and p>1 must be
  % treated separately.
  if p==1
    for k=2:ndisc+n+1; 
      x(1,:) = u(k-1,:)*AT;
      u(k,:) = x + randvec(k-1,:);
    end
  else
    for k=p+1:ndisc+n+p; 
      for j=1:p;
	x(j,:) = u(k-j,:)*AT((j-1)*m+1:j*m,:);
      end
      u(k,:) = sum(x)+randvec(k-p,:);
    end
  end
  
  % return only the last n simulated state vectors
  v = u(ndisc+p+1:ndisc+n+p,:); 





