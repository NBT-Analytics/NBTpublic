% nbt_doCrossPhaseLocking - Cross Phase Locking among channels for a two frequency
% ranges
%
% Usage:
%   PhaseLockingObject =
%   nbt_doPhaseLocking(Signal,SignalInfo,FrequencyBands,filterorder,indexPhase)
%
% Inputs:
%   Signal
%   SignalInfo
%   FrequencyBands - vector of dimension 2x2, i.e. [8 13; 20 50]
%   filterorder - number (set to [] for default value)
%   indexPhase - vector 2x1 [n m](synchronization ratio n:m, small integer, default value [1 1])
%   opt  take binary value [0,1] and for 1 the script computes phaselocking
%   between different frequency bands
%
% Outputs:
%   CrossPhaseLockingObject - update the Cross Phase Locking Biomarker  
%
% Example:
%    CrossPhaseLocking8_13Hz20_50Hz =
%    nbt_doCrossPhaseLocking(Signal,SignalInfo,[8 13; 20 50],[],[1 1])
%
% References:
% 
% See also: 
%   nbt_doPhaseLocking
%  
  
%------------------------------------------------------------------------------------
% Originally created by Giuseppina Schiavone (2010), see NBT website (http://www.nbtwiki.net) for current email address
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
function CrossPhaseLockingObject = nbt_doCrossPhaseLocking(Signal,SignalInfo,FrequencyBands,filterorder,indexPhase,opt)
%--- Input checks
error(nargchk(5,6,nargin))

%% assigning fields:

disp(' ')
disp('Command window code:')
disp(['CrossPhaseLockingObject = nbt_doCrossPhaseLocking(Signal,SignalInfo,FrequencyBands,filterorder,indexPhase)'])
disp(' ')

disp(['Computing Cross Phase Locking for ',SignalInfo.file_name])

%% remove artifact intervals	

Signal = nbt_RemoveIntervals(Signal,SignalInfo);
%% Initialize the biomarker object
CrossPhaseLockingObject = nbt_CrossPhaseLocking(size(Signal(:,:),2));

%% Compute markervalues. Add here your algorithm to compute the biomarker

%--- filter settings
Fs = SignalInfo.converted_sample_frequency;
if ~exist('opt', 'var')
    opt = [];
end
if ~exist('indexPhase', 'var') || isempty(indexPhase)
    indexPhase = [1 1];% 500ms
else
    indexPhase = indexPhase; 

end

n = indexPhase(1);
m = indexPhase(2);
CrossPhaseLockingObject.crossRatio = [n m];
%--- initialization
plf =  []; 
phase =  [];
% P = []; 
%--- filtering
if isempty(filterorder)
    minf = min(FrequencyBands(:));
    filterorder=2/minf;
end
b1 = fir1(floor(filterorder*Fs),[FrequencyBands(1,1) FrequencyBands(1,2)]/(Fs/2));  
b2 = fir1(floor(filterorder*Fs),[FrequencyBands(2,1) FrequencyBands(2,2)]/(Fs/2));
% [b1,a1] = butter(filterorder,[FrequencyBands(1,1) FrequencyBands(1,2)]/(Fs/2));
% [b2,a2] = butter(filterorder,[FrequencyBands(2,1) FrequencyBands(2,2)]/(Fs/2));
% Signal = Signal(1:1000,:);
%--- compute phase locking
tic
if isempty(opt)
    opt=0;
end
if ~opt==0 
    disp('Cross frequency phase locking within channel')
    try
        for k=1:size(Signal(:,:),2)
            Signal1 = filtfilt(b1,1,double(Signal(:,k)));
            Signal2 = filtfilt(b2,1,double(Signal(:,k)));            
            h1=hilbert(Signal1);
            h2=hilbert(Signal2);
            [phase1]=unwrap(angle(h1));
            [phase2]=unwrap(angle(h2));
            perc10w =  floor(length(Signal1)*0.1);
            phase1 = phase1(perc10w:end-perc10w);
            phase2 = phase2(perc10w:end-perc10w);
            P12=n*phase1-m*phase2;
%             P(:,k,j)=n*phase1-m*phase2;
            plf(k)=abs(sum(exp(i*P12))/length(P12));
            phase(k)=angle(sum(exp(i*P12))/length(P12));
        end
    catch Er
        fprintf('Unable to process the Phase Locking \n');
        rethrow(Er)
    end
else
    disp('Cross frequency phase locking between channels')
    try
    
    for k=1:size(Signal(:,:),2)
        disp([' channel ', num2str(k), ' ...'])
        for j=1:size(Signal(:,:),2)
            Signal1 = filtfilt(b1,1,double(Signal(:,k)));
            Signal2 = filtfilt(b2,1,double(Signal(:,j)));            
            h1=hilbert(Signal1);
            h2=hilbert(Signal2);
            [phase1]=unwrap(angle(h1));
            [phase2]=unwrap(angle(h2));
            perc10w =  floor(length(Signal1)*0.1);
            phase1 = phase1(perc10w:end-perc10w);
            phase2 = phase2(perc10w:end-perc10w);
            P12=n*phase1-m*phase2;
%             P(:,k,j)=n*phase1-m*phase2;
            plf(k,j)=abs(sum(exp(i*P12))/length(P12));
            phase(k,j)=angle(sum(exp(i*P12))/length(P12));
        end

    end
    
    catch Er
        fprintf('Unable to process the Phase Locking \n');
        rethrow(Er)
    end
end
    t = toc;

fprintf('Computation time for %d-channels %f seconds \n', size(Signal(:,:),2), t);
% PhaseLockingObject.P = P;
CrossPhaseLockingObject.crossplf = plf;
CrossPhaseLockingObject.crossphase = phase;
SignalInfo.frequencyRange = FrequencyBands;
%% update biomarker objects (here we used the biomarker template):
CrossPhaseLockingObject = nbt_UpdateBiomarkerInfo(CrossPhaseLockingObject, SignalInfo);
end
