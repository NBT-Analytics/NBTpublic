% nbt_rossler - contains the equations of two coupled rossler systems, it
% is used by nbt_runrossler to solve the equations
%
% Usage:
%   f = nbt_rossler(t,X,a,b,c,E,D,w,stdData)
%
% Inputs:
%      t - time instant
%      X - start point of trajectory of ODE system.
%      a,b,c - Rossler system parameters
%      E - coupling strength >=0
%      D - noise influence >=0
%      w - 1x2 vector containing the natural frequencies of the two
%      oscillators w = [w1 w2]
%
% Outputs:
%   f
%
% Example:
%   
% References:
% 
% See also: 
%   nbt_runrossler
%  
  
%------------------------------------------------------------------------------------
% Originally created by Giuseppina Schiavone (2011), see NBT website
% (http://www.nbtwiki.net) for current email address
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



function f = nbt_rossler(t,X,a,b,c,E,D,w,stdData)

% two coupled nonidentical Rossler  system
%
%   dx1/dt = -w1y1-z1+GaussianDeltaCorrelatedNoise1 + E*(x2-x1)
%   dy1/dt = w1+a*y1
%   dz1/dt = b +z1*(x1-c)
%   dx2/dt = -w2y2-z2+GaussianDeltaCorrelatedNoise2 + E*(x1-x2)
%   dy2/dt = w2+a*y2
%   dz2/dt = b +z2*(x2-c)
%
%   a governs topological type of Rossler attractor
%   b,c parameters
%   w1,w2 governs natural frequency of an individual system 
%       w1 = w2 locked near 1:1, same natural frequency (identical systems)
%       w1 = w0 +deltaw; w2 = w0+ deltaw (nonientical system, set of 
%           frequencies w1,w2 Gaussian distributed around the mean value w0
%           and with variance (deltaw)?2)
%   E coupling constant, 
%       E -> 0 uncoupled systems
%       E >> 0 coupled systems
%   GaussianDelta CorrelatedNoise : 2*D*rand*std(x1), 2*D*rand*std(x1)
%       2sigma?2 dirac(x-x')
%
%   References: 
%   Pikovsky, AS and Rosenblum, MG and Kurths, J., Synchronization in a population of globally coupled chaotic oscillators},
%   EPL (Europhysics Letters), 34(3), 165-170, 1996, IOP Publishing
%
%   Tass, P. and Rosenblum, MG and Weule, J. and Kurths, J. and Pikovsky, A. and Volkmann, J. and Schnitzler, A. and Freund, H.J.,
%   Detection of n: m phase locking from noisy data: application to
%   magnetoencephalography, Physical Review Letters, 81, 15, 3291-3294, 1998, APS
%
%   LIU Yong, BI Qin-sheng, CHEN Yu-shu, Phase synchronization between nonlinearly coupled R ?ossler
%   systems,Appl. Math. Mech. -Engl. Ed., 2008, 29(6):697?704
%
%   Michael G. Rosenblum, Arkady S. Pikovsky, and Jürgen Kurths, 
%   From Phase to Lag Synchronization in Coupled Chaotic Oscillators
%   PHYSICAL REVIEW	LETTERS, VOLUME 78, NUMBER 22, 2 JUNE 1997


% Values of parameters

w1 = w(1);
w2 = w(2);

% x1 = X(1);
% y1 = X(2);
% z1 = X(3);
% x2 = X(4);
% y2 = X(5);
% z2 = X(6);

Y = [X(7), X(8), X(9), X(10), X(11), X(12);
    X(13), X(14), X(15), X(16), X(17), X(19);
    X(19), X(20), X(21), X(22), X(23), X(24);
    X(25), X(26), X(27), X(28), X(29), X(30);
    X(31), X(32), X(33), X(34), X(35), X(36);
    X(37), X(38), X(39), X(40), X(41), X(42)];
f = zeros(36,1);

% Rossler equations

f(1) = -w1*X(2)-X(3)+ E*(X(4)-X(1))+2*D*stdData(1)*randn(1);
f(2) = w1*X(1)+a*X(2);
f(3) = b +X(3)*(X(1)-c);
f(4) = -w2*X(5)-X(6)+ E*(X(1)-X(4))+2*D*stdData(4)*randn(1);
f(5) = w2*X(4)+a*X(5);
f(6) = b +X(6)*(X(4)-c);


%Linearized system
Jac = [-E, -w1, -1, E, 0, 0;
        w1, a, 0, 0, 0, 0;
        X(3), 0, X(1)-c, 0, 0, 0;
        E, 0, 0, -E, -w2, -1;
        0, 0, 0, w2, a, 0;
        0, 0, 0, X(6), 0, X(4)-c];

%Variational equation   
f(1:6) = f(1:6);
f(7:42)=Jac*Y;

%Output data must be a column vector


