% nbt_n_m_detection - Computes the n:m synchronization indices for give
% phases and n:m ratio
%
% Usage:
%   [index1nm,index2nm, index3nm] = nbt_n_m_detection(phase1,phase2,n,m)
%
% Inputs:
%   phase1 - instantaneous phase of the first signal
%   phase2 - instantaneous phase of the second signal
%   n - integer
%   m - integer
%
% Outputs:
%   index1nm - index based on shannon entropy
%   index2nm - index based on conditional probability 
%   index3nm - index based on intensity of the first fourier mode
%
% Example:
%   
% References:
%   Tass, P. and Rosenblum, MG and Weule, J. and Kurths, J. and Pikovsky, A. and Volkmann, J. and Schnitzler, A. and Freund, H.J.,
%   Detection of n: m phase locking from noisy data: application to
%   magnetoencephalography, Physical Review Letters, 81, 15, 3291-3294,
%   1998, APS
%
%   Michael Rosenblum, Arkady Pikovsky, Ju?rgen Kurths Carsten Sch?afer, and Peter A. Tass,
%   Phase synchronization: from theory to data analysis
%   Handbook of Biological Physics, Elsevier Science, Series Editor A.J.
%   Hoff, Vol. 4, Neuro-informatics, Editors: F. Moss and S. Gielen,
%   Chapter 9, pp. 279-321, 2001.
%
%   Otnes R., Enochson L. (1972) Digital time series analysis, John Wiley &
%   Sons, New York
% 
% See also: 
%   nbt_n_m_surrogate_detection
%  
  
%------------------------------------------------------------------------------------
% Originally created by Giuseppina Schiavone (2011), see NBT website (http://www.nbtwiki.net) for current email address
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




function [index1nm,index2nm, index3nm] = nbt_n_m_detection(phase1,phase2,n,m)

RP = n*unwrap(phase1)-m*unwrap(phase2);
%--- 
% distribution of the cyclic relative phase
CRP = (rem(RP,2*pi));
Nbins = round(exp(0.626+0.4*log(length(RP)-1)));
range = linspace(-pi,pi,Nbins);
dCRP = hist(CRP,range);
dCRP = dCRP/length(CRP);
close all
% figure
% bar(range,dCRP)
% axis tight
% the estimate of this index strongly depends on the number of bins used
% for computation of the histogram.
    
%% 1. Index1: n:m synchronization index based on the Shannon entropy

S = -nansum(dCRP.*log(dCRP)); % entropy of the distribution of the cyclic relative phase
Smax = log(length(dCRP));
index1nm = (Smax-S)/Smax;
% 0<=Index1nm<=1
% if Index1nm=0 --> uniform distribution (no synchronization)
% if Index1nm=1 --> Dirac-like distribution (perfect synchronization)
%% 2. Index2: based on the conditional probability
Nint = 10;
int_m = linspace(0,2*pi*m,Nint);
mod_phase1 = mod(phase1,2*pi*m);
for j = 1:Nint-1
        int1 = int_m(j);
        int2 = int_m(j+1);

        [theta index] = find(mod_phase1 <= int2 & mod_phase1 >= int1);
        M = length(theta);
        ni = mod(phase2(index),2*pi*n);
        sum(exp(i*ni/n))/M;
        expM(j) = sum(exp(i*ni/n))/M;
        if isnan(expM(j))
            
            expM(j) = 0;
        end
end
index2nm = sum(abs(expM))/Nint;



% abs(r_int) = 1 indicates complete dependence between the two phases 
% abs(r_int) = 0 indicates no dependence at all
% --- average over all bins:
% index2nm measures the conditional probability for phase2 to have a
% certain value provided phase1 in a certain bin 


% find n and m we try different values and pick up those that give larger
% indices

%% 3. Index3 Intensity of the first Fourier mode of the distribution 
% it also varies from 0 to 1. The advantage of this index is that its
% computation involves no parameters
index3nm = sqrt((mean(cos(dCRP)).^2) +mean((sin(dCRP))).^2);
