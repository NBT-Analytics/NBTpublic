% nbt_doCoher - Compute coherence among channels for a given frequency
% range
%
% Usage:
%   CoherenceObject = nbt_doCoher(Signal,SignalInfo,FrequencyBand,interval)
%
% Inputs:
%   Signal
%   SignalInfo
%   FrequencyBand - vector of dimension 1x2, i.e. [8 13]
%   interval - vector of dimension 1x2, express the time interval (in sec) one wants
%               to analyse, i.e. [0 100]
%               warning: the length of the signal must be >> (2?9*Fs)
%               length in sec of the hamming window used to compute the coherence
%
% Outputs:
%   CoherenceObject - update the Coherence Biomarker  
%
% Example:
%    Coherence8_13Hz = nbt_doCoher(Signal,SignalInfo,[8 13])
%
% References:
% 
% See also: 
%  
  
%------------------------------------------------------------------------------------
% Originally created by Giuseppina Schiavone (2011), see NBT website (http://www.nbtwiki.net) for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
% 9 October 2013: Added Fisher Z transform by advice of Vladimir Miskovic (Department of Psychology
% State University of New York at Binghamton)
% 2 April 2013: Added ICoherence (imaginary part of Coherence) by advice of
% Vladimir Miskovic
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
function CoherenceObject = nbt_doCoher(Signal,SignalInfo,FrequencyBand,interval)
%--- input checks
error(nargchk(4,4,nargin))

%%   give information to the user	
disp(' ')
disp('Command window code:')
disp(['CoherenceObject = nbt_doCoher(Signal,SignalInfo,FrequencyBand)'])
disp(' ')
disp(['Computing Coherence for ',SignalInfo.file_name])

%% remove artifact intervals	

Signal = nbt_RemoveIntervals(Signal,SignalInfo);

%% Signal in the selected interval
Fs = SignalInfo.converted_sample_frequency;
if interval(1) == 0
    Signal = Signal(1:interval(2)*Fs,:);
else
    Signal = Signal(interval(1)*Fs:interval(2)*Fs,:);
end
%% Initialize the biomarker object

CoherenceObject = nbt_Coher(size(Signal,2));

%% Compute markervalues. Add here your algorithm to compute the biomarker
%--- window function
W_length = min(size(Signal,1)/5,2^10);
W = hamming(W_length);
% if length(Signal(:,1))<= W_length
%     error(['The time interval is too short. The minimum time interval for this signal = is )' num2str(round(W_length/Fs))])
% end
%--- extract frequency vector f from coherence function
[t,f]=mscohere(Signal(:,1),Signal(:,1),W,[],W_length,Fs);
Index = find(floor(f)>= FrequencyBand(1,1) &  floor(f)<= FrequencyBand(1,2));
FrequencyIndex= [Index(1) Index(end)];
%--- compute coherence matrix
CoherenceMatrix = nan(size(Signal(:,:),2),size(Signal(:,:),2));
CoherenceMatrixI = nan(size(Signal(:,:),2),size(Signal(:,:),2));
disp([' Frequency band ', num2str(FrequencyBand(1,1)), '-', num2str(FrequencyBand(1,2)),' Hz'])

try
  for i=1:size(Signal(:,:),2)
       disp([' channel ', num2str(i), ' ...'])
       [Pxx] = cpsd(Signal(:,i), Signal(:,i), W, [], W_length, Fs);
        for j=i+1:size(Signal(:,:),2)
            [Pyy] = cpsd(Signal(:,j), Signal(:,j), W, [], W_length, Fs);
            [Pxy] = cpsd(Signal(:,i), Signal(:,j), W, [], W_length, Fs);
            Cxy=Pxy./sqrt(Pxx.*Pyy);
            Coh  = (abs(Cxy)).^2;
            ICoh = (imag(Cxy)).^2;
            % mean of the coherence function is computed along each
            % frequency band
            Coh = 0.5*log((1+Coh)./(1-Coh)); %first do Fisher's Z
            CoherenceMatrix(i,j) = nanmean(Coh(FrequencyIndex(1):FrequencyIndex(2)));
            CoherenceMatrix(i,j) = (exp(2*CoherenceMatrix(i,j))-1)./(exp(2*CoherenceMatrix(i,j))+1); %now do an inverse-Fisher's Z to transform back to coherence
            ICoh = 0.5*log((1+ICoh)./(1-ICoh)); %first do Fisher's Z
            ICoherenceMatrix(i,j) = nanmean(ICoh(FrequencyIndex(1):FrequencyIndex(2)));
            ICoherenceMatrix(i,j) = (exp(2*ICoherenceMatrix(i,j))-1)./(exp(2*ICoherenceMatrix(i,j))+1); %now do an inverse-Fisher's Z to transform back to coherence
        end
  end
catch Er
  fprintf('Unable to process the Coherence Matrix \n');
  rethrow(Er)
end

CoherenceObject.Coherence = CoherenceMatrix;
CoherenceObject.ICoherence = ICoherenceMatrix;
CoherenceObject.interval = interval;
SignalInfo.frequencyRange = FrequencyBand;
%% update biomarker objects (here we used the biomarker template):
CoherenceObject = nbt_UpdateBiomarkerInfo(CoherenceObject, SignalInfo);

end

