% nbt_runrossler - Solves differential equations of two coupled rossler
% systems using ode45
%
% Usage:
%   [Texp,Lexp,Data]=nbt_runrossler(n,tstart,stept,tend,ystart,ioutp,a,b,c,
%   E,D,w);
%
% Inputs:
%      n - number of equation               
%      tstart - start values of independent value (time t)
%      stept - step on t-variable for Gram-Schmidt renormalization procedure.
%      tend - finish value of time
%      ystart - start point of trajectory of ODE system.
%      ioutp - step of print to MATLAB main window. ioutp==0 - no print, 
%              if ioutp>0 then each ioutp-th point will be print.
%      a,b,c - Rossler system parameters
%      E - coupling strength >=0
%      D - noise influence >=0
%      w - 1x2 vector containing the natural frequencies of the two
%      oscillators w = [w1 w2]
%
% Outputs:
%   Texp - time values
%   Lexp - Lyapunov exponents to each time value.
%   Data - solution for the systems
%
% Example:
%   
% References:
%        A. Wolf, J. B. Swift, H. L. Swinney, and J. A. Vastano,
%        "Determining Lyapunov Exponents from a Time Series," Physica D,
%        Vol. 16, pp. 285-317, 1985.
% 
% See also: 
%   nbt_rossler
%  
  
%------------------------------------------------------------------------------------
% Originally created by Giuseppina Schiavone (2011), see NBT website (http://www.nbtwiki.net) for current email address
% rearrangement of a file created by Govorukhin V.N. for finding lyapunov
% exponents
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) <year>  <Main Author>  (Neuronal Oscillations and Cognition group, 
% Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, 
% Neuroscience Campus Amsterdam, VU University Amsterdam)
%
% Part of the Neurophysiological Biomarker Toolbox (NBT)
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
% See Readme.txt for additional copyright information.
% -------------------------------------------------------------------------



function [Texp,Lexp,Data]=nbt_runrossler(n,tstart,stept,tend,ystart,ioutp,a,b,c,E,D,w);

%
%    Example. Two coupled nonidentical Rossler  system
%
%   dx1/dt = -w1y1-z1+GaussianDeltaCorrelatedNoise1 + E*(x2-x1)
%   dy1/dt = w1+a*y1
%   dz1/dt = b +z1*(x1-c)
%   dx2/dt = -w2y2-z2+GaussianDeltaCorrelatedNoise2 + E*(x1-x2)
%   dy2/dt = w2+a*y2
%   dz2/dt = b +z2*(x2-c)
%   x1 = X(1);
%   y1 = X(2);
%   z1 = X(3);
%   x2 = X(4);
%   y2 = X(5);
%   z2 = X(6);
%
%    The Jacobian of system: 
%       J = |-E  -w1 -1   E    0   0 |
%           | w1  a   0   0    0   0 |
%           |X(3) 0  -c   0    0   0 |
%           | E   0   0  -E   -w2 -1 |
%           | 0   0   0   w2   a   0 |
%           | 0   0   0   X(6) 0  -c |
%
%    Then, the variational equation has a form:
% 
%    F = J*Y
%    where Y is a square matrix with the same dimension as J.
%    Corresponding m-file:
%        function rossler6(t,X,a,b,c,E,D,w)
%             Y = [X(7), X(8), X(9), X(10), X(11), X(12);
%                 X(13), X(14), X(15), X(16), X(17), X(19);
%                 X(19), X(20), X(21), X(22), X(23), X(24);
%                 X(25), X(26), X(27), X(28), X(29), X(30);
%                 X(31), X(32), X(33), X(34), X(35), X(36);
%                 X(37), X(38), X(39), X(40), X(41), X(42);
%                 ];
%             f = zeros(36,1);
% 
%             % Rossler equations
% 
%             f(1) = -w1*X(2)-X(3)+ E*(X(4)-X(1));
%             f(2) = w1*X(1)+a*X(2);
%             f(3) = b +X(3)*(X(1)-c);
%             f(4) = -w2*X(5)-X(6)+ E*(X(1)-X(4));
%             f(5) = w2*X(4)+a*X(5);
%             f(6) = b +X(6)*(X(4)-c);
% 
% 
%             %Linearized system
%             Jac = [ -E -w1 -1 E 0 0;
%                     w1 a 0 0 0 0;
%                     X(3) 0 -c 0 0 0;
%                     E 0 0 -E -w2 -1;
%                     0 0 0 w2 a 0;
%                     0 0 0 X(6) 0 -c;
%                     ];
% 
%             %Variational equation   
%             f(7:42)=Jac*Y;


n1=n; n2=n1*(n1+1);
%  Number of steps
nit = round((tend-tstart)/stept);
% Memory allocation 
y=zeros(n2,1); cum=zeros(n1,1); y0=y;
gsc=cum; znorm=cum;
% Initial values
y(1:n)=ystart(:);
for i=1:n1 
    y((n1+1)*i)=1.0; 
end;
t=tstart;
% Main loop
stdData= zeros(6,1)';
for ITERLYAP=1:nit
    % Solutuion of extended ODE system 
    stdData=stdData;
    [T Y] = ode45(@(t,y) nbt_rossler(t,y,a,b,c,E,D,w,stdData),[t t+stept],y);
    Data(ITERLYAP,1:6)=Y(end,1:6);
    stdData = std(Data(:,1:6),0,1);
    t=t+stept;
    y=Y(size(Y,1),:);
    for i=1:n1 
      for j=1:n1 
          y0(n1*i+j)=y(n1*j+i); 
      end;
    end;
%
%construct new orthonormal basis by gram-schmidt
%
  znorm(1)=0.0;
  for j=1:n1 
      znorm(1)=znorm(1)+y0(n1*j+1)^2; 
  end;
  znorm(1)=sqrt(znorm(1));
  for j=1:n1 
      y0(n1*j+1)=y0(n1*j+1)/znorm(1); 
  end;

  for j=2:n1
      for k=1:(j-1)
          gsc(k)=0.0;
          for l=1:n1 
              gsc(k)=gsc(k)+y0(n1*l+j)*y0(n1*l+k); 
          end;
      end;
 
      for k=1:n1
          for l=1:(j-1)
              y0(n1*k+j)=y0(n1*k+j)-gsc(l)*y0(n1*k+l);
          end;
      end;

      znorm(j)=0.0;
      for k=1:n1 
          znorm(j)=znorm(j)+y0(n1*k+j)^2; 
      end;
      znorm(j)=sqrt(znorm(j));

      for k=1:n1 
          y0(n1*k+j)=y0(n1*k+j)/znorm(j); 
      end;
  end;
%
%       update running vector magnitudes
%
  for k=1:n1 
      cum(k)=cum(k)+log(znorm(k)); 
  end;
%
%       normalize exponent
%

  for k=1:n1 
      lp(k)=cum(k)/(t-tstart); 
%     lp(k)=cum(k);
  end;

% Output modification

  if ITERLYAP==1
     Lexp=lp;
     Texp=t;
  else
     Lexp=[Lexp; lp];
     Texp=[Texp; t];
  end;

  if (mod(ITERLYAP,ioutp)==0)
     fprintf('t=%6.4f',t);
     for k=1:n1 
         fprintf(' %10.6f',lp(k)); 
     end;
     fprintf('\n');
  end;

  for i=1:n1 
      for j=1:n1
          y(n1*j+i)=y0(n1*i+j);
      end;
  end;
% ITERLYAP
end;

%------EXAMPLE

%% uncoupled system
% w1 = 1+0.015; % natural frequency of system 1
% w2 = 1-0.015; % natural frequency of system 2
% w = [w1 w2];
% % rossler system parameters 
% a = 0.15;
% b = 0.2;
% c = 10;
% % coupling constant
% E = 0; % we impose that the systems are not coupled (increasing E we increase the coupling between the two systems)
% % D determins the gaussian delta correlated noise term (2*D*std*randn)
% D = 0;% noise
% % simulation settings
% % tstart - start values of independent value (time t)
% % stept - step on t-variable for Gram-Schmidt renormalization procedure.
% % tend - finish value of time
% stept = 2*pi/100; %time 2*pi/1000
% tstart = 0;% tend
% tend = 100;%time
% %  Number of steps
% nit = round((tend-tstart)/stept);
% stdData = zeros(6,1);
% x0 = [1 1 1 1 1 1]; %initial condition
% [T,Res,data]=nbt_runrossler(6,tstart,stept,tend,x0,100,a,b,c,E,D,w);
% % Data: [x1 y1 z1 x2 y2 z2]
% x1 = data(:,1);
% x2 = data(:,4);
% y1 = data(:,2);
% y2 = data(:,5);
% z1 = data(:,3);
% z2 = data(:,6);
% 
% %--- instantaneous phase and frequency
% phase1 = unwrap(atan2(y1,x1));% phase
% phase2 = unwrap(atan2(y2,x2));
% 
% F1 = diff(phase1)/stept; % frequency expressed as time derivative of the phase
% F2 = diff(phase2)/stept; % frequency expressed as time derivative of the phase
% %---
% n = 1;
% m = 1;
% %--- relative phase and relative frequency
% Rphase = n*phase1-m*phase2; % relative phase
% Rfreq = (n*mean(F1)-m*mean(F2)); %relative frequency
% figure
% subplot(3,3,1)
% plot3(x1,y1,z1,'r')
% hold on
% plot3(x2,y2,z2,'b')
% xlabel('x')
% ylabel('y')
% zlabel('z')
% title('Rossler Attractors in 3D space')
% grid on 
% axis tight
% subplot(3,3,2)
% plot(x1,x2, 'k')
% xlabel('x1')
% ylabel('x2')
% hold on
% grid on 
% axis tight
% title('Projections of the actractor of the coupled system on the plane x_{1}(t),x_{2}(t)')
% subplot(3,3,3)
% plot(linspace(0,100,length(Rphase)),Rphase, 'k')
% xlabel('time')
% ylabel('radians')
% hold on
% grid on 
% axis tight
% title('RELATIVE PHASE')