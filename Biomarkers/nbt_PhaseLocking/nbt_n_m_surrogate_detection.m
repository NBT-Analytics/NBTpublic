% nbt_n_m_surrogate_detection - Computes the n:m synchronization ratio
% integers
% using phases of the signals and phases of surrogate data (white noise filtered as the original signals)
%
%
% Usage:
%   [n m] =
%   nbt_n_m_surrogate_detection(phase1,phase2,phase1rand,phase2rand)
%
% Inputs:
%   phase1 - instantaneous phase of the first signal
%   phase2 - instantaneous phase of the second signal
%   phase1rand - instantaneous phase of the first surrogate signal
%   phase2rand - instantaneous phase of the second surrogate signal
%
% Outputs:
%   n - integer
%   m - integer
%
% Example:
%   
% References:
%   Tass, P. and Rosenblum, MG and Weule, J. and Kurths, J. and Pikovsky, A. and Volkmann, J. and Schnitzler, A. and Freund, H.J.,
%   Detection of n: m phase locking from noisy data: application to
%   magnetoencephalography, Physical Review Letters, 81, 15, 3291-3294,
%   1998, APS
% 
% See also: 
%   nbt_n_m_detection
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


function [n m] = nbt_n_m_surrogate_detection(phase1,phase2,phase1rand,phase2rand)

t0 = 5;
j = 1;
for i=t0+1:length(phase1)-t0
    phase1w = phase1(i-t0:i+t0);
    phase2w = phase2(i-t0:i+t0);
            g = 1;
            for n = 1:2;
                for m = 1:2;
                [index1nm,index2nm,index3nm] = nbt_n_m_detection(phase1w,phase2w,n,m);
                values(g,:) = [index1nm index2nm];
                ind(g,:) =[n m];
                g = g+1;
                end
            end
            I1(j,:) = values(:,1);
            I2(j,:) = values(:,2);          
            j = j+1;
end
%
% % --- detect n:m surrogate

j = 1;
for i=t0+1:length(phase1)-t0
    phase1w = phase1rand(i-t0:i+t0);
%     plot(phase1w)
%     pause(1)
    phase2w = phase2rand(i-t0:i+t0);
            g = 1;
            for nR = 1:2
                for mR = 1:2
                [index1nmR,index2nmR,index3nmR] = nbt_n_m_detection(phase1w,phase2w,n,m);
                valuesR(g,:) = [index1nmR index2nmR];
                indR(g,:) =[nR mR];
                g = g+1;
                end
            end
            I1R(j,:) = valuesR(:,1);
            I2R(j,:) = valuesR(:,2);
            
            j = j+1;

end

perc1R = prctile(I1R,95,1);
perc2R = prctile(I2R,95,1);

for i = 1:4
    max1(i) = max(I1(:,i)-perc1R(i));
    if max1(i) <0
        max1(i) = 0;
    end
    max2(i) = max(I2(:,i)-perc2R(i));
    if max1(i) <0
        max1(i) = 0;
    end
end
% sum of the index: the maximum will give n m values
sumInd = max1 +max2;
[sumIndmax indMax] = max(sumInd);
n = ind(indMax,1);
m = ind(indMax,2);
