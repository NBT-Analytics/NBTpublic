% nbt_doPhaseLocking - Phase Locking among channels for a given frequency
% range
%
% Usage:
%   PhaseLockingObject =
%   nbt_doPhaseLocking(Signal,SignalInfo,FrequencyBand,interval,filterorder
%   ,windowleng,overlap,indexPhase)
%
% Inputs:
%   Signal
%   SignalInfo
%   FrequencyBand - vector of dimension 1x2, i.e. [8 13]
%   interval - vector of dimension 1x2, express the time interval (in sec) one wants
%               to analyse, i.e. [0 100]
%   filterorder(opt)
%   windowleng - length of the sliding window in seconds (by default, no sliding window method is used)
%   overlap - 20 if 20 % overlap
%   indexPhase [n m] - small integer
%
% Outputs:
%   PhaseLockingObject - update the Phase Locking Biomarker  
%
% Example:
%    phase lock computed over the entired interval [0 100] s
%    PhaseLocking8_13Hz =
%    nbt_doPhaseLocking(Signal,SignalInfo,[8 13],[0 100],[],[],[],[1 1])
%
%    phase lock computed with sliding window of 1s with 20% overlap
%    PhaseLocking8_13Hz =
%    nbt_doPhaseLocking(Signal,SignalInfo,[8 13],[0 100],[],1,20,[1 1])
%
% References:
%   Tass, P. and Rosenblum, MG and Weule, J. and Kurths, J. and Pikovsky, A. and Volkmann, J. and Schnitzler, A. and Freund, H.J.,
%   Detection of n: m phase locking from noisy data: application to
%   magnetoencephalography, Physical Review Letters, 81, 15, 3291-3294,1998, APS
%
%   Mormann, F. and Lehnertz, K. and David, P. and E Elger, C., Mean phase coherence as a measure for phase synchronization 
%   and its application to the EEG of epilepsy patients},Physica D:
%   Nonlinear Phenomena, 144, 3-4, 358-369, 2000
%
%   Michael G. Rosenblum, Arkady S. Pikovsky, and J???rgen Kurths, 
%   From Phase to Lag Synchronization in Coupled Chaotic Oscillators
%   PHYSICAL REVIEW	LETTERS, VOLUME 78, NUMBER 22, 2 JUNE 1997
% 
%   Michael Rosenblum, Arkady Pikovsky, Ju?rgen Kurths Carsten Sch?afer, and Peter A. Tass,
%   Phase synchronization: from theory to data analysis
%   Handbook of Biological Physics, Elsevier Science, Series Editor A.J.
%   Hoff, Vol. 4, Neuro-informatics, Editors: F. Moss and S. Gielen, Chapter 9, pp. 279-321, 2001.
%
% See also: 
%   nbt_doCrossPhaseLocking
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
function PhaseLockingObject = nbt_doPhaseLocking(Signal,SignalInfo,FrequencyBand,interval,filterorder,windowleng,overlap,indexPhase)

%--- Input checks
error(nargchk(7,8,nargin))

%% assigning fields:

disp(' ')
disp('Command window code:')
disp(['PhaseLockingObject = nbt_doPhaseLocking(Signal,SignalInfo,FrequencyBand,interval,filterorder)'])
disp(' ')

disp(['Computing Phase Locking for ',SignalInfo.file_name])

%% remove artifact intervals	

Signal = nbt_RemoveIntervals(Signal,SignalInfo);

%--- Compute markervalues. Add here your algorithm to compute the biomarker

%% Signal in the selected interval
Fs = SignalInfo.converted_sample_frequency;
if ~isempty(interval)   
if interval(1) == 0
    Signal = Signal(1:interval(2)*Fs,:);
else
    Signal = Signal(interval(1)*Fs:interval(2)*Fs,:);
end
end

%% check that the filter order is filtorder<<signal length/(3*2)

if exist('filterorder', 'var')
%     if filterorder >= size(Signal,1)/(3*2)
%         error('The signal length must be at least 3 times the filter order')
%     end
else
        
filterorder = 2/FrequencyBand(1);
end

if ~exist('overlap', 'var') || isempty(overlap)
    overlap = [];%100/20;
else
     overlap = (100-overlap)/100;
end


if ~exist('windowleng', 'var') 
    windowleng = [];% 500ms
else
    windowleng = windowleng; 

end

if ~exist('indexPhase', 'var') || isempty(indexPhase)
    indexPhase = [1 1];% 500ms
else
    indexPhase = indexPhase; 

end

%% check that the higher frequency respects the relationship f_band2/(fs/2)<1
% if (FrequencyBand(2)/(Fs/2))>1
%      error('The highest frequency in the frequency band must be minor that the half of the sampling frequency')
% end
nchannels = size(Signal(:,:),2);
signallength = size(Signal(:,:),1);
%% filtering with FIR and hilbert transform
% we filter the two signals using the same filter
disp('Zero-Phase Filtering and Hilbert Transform...')
b1 = fir1(floor(filterorder*Fs),[FrequencyBand(1) FrequencyBand(2)]/(Fs/2));
for k = 1:nchannels
    FilteredSignal(:,k) = filtfilt(b1,1,double(Signal(:,k)));
end
SignalHilb = hilbert(FilteredSignal);
disp('Instantaneous Phase...')
phase = unwrap(angle(SignalHilb));
% exclude 10% of the signal before and after because of distorsion
% introduced by hilbert transform
perc10w =  floor(signallength*0.1);
phase = phase(perc10w:end-perc10w,:);
SignalInfo.frequencyRange = FrequencyBand;
%% compute phase locking

% windowing the signal (compromise between statistical accuracy and stationarity)
%   Mormann, F. and Lehnertz, K. and David, P. and E Elger, C., Mean phase coherence as a measure for phase synchronization 
%   and its application to the EEG of epilepsy patients},Physica D:
%   Nonlinear Phenomena, 144, 3-4, 358-369, 2000
%searation in window of 4096 samples and 20% overlapping ( = 23 sec)
% Since the most time-consuming part of the algorithm is a fast Fourier transform (FFT) algorithm for calculation of the 
% Hilbert transform (cf. Eq. (6)), the computational speed of the algorithm depends on the window length of N sampling points like .
%% Initialize the biomarker object

PLV = nan(size(Signal(:,:),2),size(Signal(:,:),2));
Instphase = phase;
index1nm = nan(size(Signal(:,:),2),size(Signal(:,:),2));
index2nm = nan(size(Signal(:,:),2),size(Signal(:,:),2));
index3nm = nan(size(Signal(:,:),2),size(Signal(:,:),2));
n = indexPhase(1);
m = indexPhase(2);

PLV_in_time = [];
index1nm_in_time = [];
index2nm_in_time = [];
index3nm_in_time = [];
time_int = [];

disp('Computing PLV ...')
% if (interval(2)-interval(1))>Twind
if ~isempty(windowleng)
    Nwind = windowleng*Fs;% 500msec*FS
    Twind = Nwind/Fs; % length of the window in seconds
    nx = size(Signal(:,:),1);                            % size of signal
    w = hanning(Nwind)';                          % hamming window
    nw = length(w);   % size of window
    WindowStep = floor(nw*overlap);
    
    PhaseLockingObject =nbt_PhaseLocking(signallength,nchannels);

    for k=1:nchannels
        
        for j=k+1:nchannels
            disp([' channels ', num2str(k), ' ,' num2str(j), '...'])
            pos=1;
            jump = 0;
            while (pos+nw-1 <= nx)                       % while enough signal left
                jump = jump+1;
                y1 = FilteredSignal(pos:pos+nw-1,k).*w';
                y2 = FilteredSignal(pos:pos+nw-1,j).*w';
                h1=hilbert(y1);   
                h2=hilbert(y2);
                [phase1w]=unwrap(angle(h1));
                [phase2w]=unwrap(angle(h2));
                perc10w =  floor(nw*0.1);
                phase1w = phase1w(perc10w:end-perc10w);
                phase2w = phase2w(perc10w:end-perc10w);
                    
                    try
                    RP=n*phase1w-m*phase2w;
                    P_L_V(jump)=abs(sum(exp(i*RP)))/length(RP); 
                    [ind1nm(jump),ind2nm(jump),ind3nm(jump)] = nbt_n_m_detection(phase1w,phase2w,n,m);                    
                    
                    catch Er
                        fprintf('Unable to process the Phase Locking \n');
                        rethrow(Er)
                    end

                    %%%% process window y %%%%
                    pos = pos + WindowStep;                 % 20%overlap next window
                    
            end
        PLV_in_time(k,j,:) =  P_L_V;
        time_int = ((1+(nw-1)/2):WindowStep:((pos-WindowStep)+(nw-1)/2))/Fs;
        index1nm(k,j) = mean(ind1nm);
        index2nm(k,j) = mean(ind2nm);
        index3nm(k,j) = mean(ind3nm);
        PLV(k,j) = mean(P_L_V);
        index1nm_in_time(k,j,:) = ind1nm;
        index2nm_in_time(k,j,:) = ind2nm;
        index3nm_in_time(k,j,:) = ind3nm;
        
        end
    end

else
    PhaseLockingObject =nbt_PhaseLocking(signallength,nchannels);
    for k=1:nchannels
%         disp([' channel ', num2str(k), ' ...'])
        for j=k+1:nchannels
           disp([' channels ', num2str(k), ' ,' num2str(j), '...'])

                phase1 = phase(:,k);           % make window y
                phase2 = phase(:,j);
            
            try 
               RP=n*phase1-m*phase2;
               PLV(k,j)=abs(sum(exp(i*RP)))/length(RP); 
               [index1nm(k,j),index2nm(k,j),index3nm(k,j)] = nbt_n_m_detection(phase1,phase2,n,m);
            catch Er
               fprintf('Unable to process the Phase Locking \n');
               rethrow(Er)
            end
        end
    end
    
end   

PhaseLockingObject.Ratio = [n m];
PhaseLockingObject.PLV = PLV;
PhaseLockingObject.Instphase = Instphase;
% SignalInfo.frequencyRange = FrequencyBand;
PhaseLockingObject.filterorder = filterorder;
PhaseLockingObject.Ratio = [n m];
PhaseLockingObject.interval = interval;
% PhaseLockingObject.synchlag = synchlag;


PhaseLockingObject.IndexE = index1nm; %index based on the Shannon entropy
PhaseLockingObject.IndexCP = index2nm;%based on the conditional probability
PhaseLockingObject.IndexF = index3nm;%based on the intensity of the first Fourier mode of the distribution 
PhaseLockingObject.PLV_in_time = PLV_in_time;
PhaseLockingObject.time_int = time_int;
PhaseLockingObject.IndexE_in_time = index1nm_in_time;
PhaseLockingObject.IndexCP_in_time = index2nm_in_time;
PhaseLockingObject.IndexF_in_time = index3nm_in_time;

SignalInfo.frequencyRange = FrequencyBand;

%% update biomarker objects (here we used the biomarker template):
PhaseLockingObject = nbt_UpdateBiomarkerInfo(PhaseLockingObject, SignalInfo);
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

% EXAMPLE  considering two coupled nonidentical Rossler systems

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
% D = 0.2;% noise
% % simulation settings
% % tstart - start values of independent value (time t)
% % stept - step on t-variable for Gram-Schmidt renormalization procedure.
% % tend - finish value of time
% stept = 2*pi/1000; %time 2*pi/1000
% tstart = 0;% tend
% tend = 10;%time
% %  Number of steps
% nit = round((tend-tstart)/stept);
% stdData = zeros(6,1);
% [T,Res,data]=nbt_runrossler(6,tstart,stept,tend,[1 1 1 1 1 1],100,a,b,c,E,D,w);
% % Res: lyap exp, lyapunov exponent is given as average e1/(N*dt)=e1/T
% % Data: [x1 y1 z1 x2 y2 z2]
% x1 = data(:,1);
% x2 = data(:,4);
% y1 = data(:,2);
% y2 = data(:,5);
% z1 = data(:,3);
% z2 = data(:,6);
% figure 
% plot(x1)
% hold on
% plot(x2)
% % u and v, are mixture of the signal x1 and x2 so that we imitate a real situation for MEG data: each MEG sensor measures
% % signal originating from more than one area of neural activity
% % u and v does not lead to spurious detection of synchronization, although
% % u and v are correlated
% mu = 0.02;
% u = (1-mu)*x1+mu*x2;
% v = (1-mu)*x2+mu*x1;
% 
% figure(1)
% plot(u,'b')
% hold on
% plot(v,'r')
% title('signals')
% % hypothesis n:m = 1:1
% h2=hilbert(u);
% h1=hilbert(v);
% [phase2]=unwrap(angle(h2));
% [phase1]=unwrap(angle(h1));
% % --- detect n:m 
% %   Tass, P. and Rosenblum, MG and Weule, J. and Kurths, J. and Pikovsky, A. and Volkmann, J. and Schnitzler, A. and Freund, H.J.,
% %   Detection of n: m phase locking from noisy data: application to
% %   magnetoencephalography, Physical Review Letters, 81, 15, 3291-3294,
% %   1998, APS
% g = 1;
% for n = 1:2
%     for m = 1:2
%         [index1nm,index2nm,index3nm] = nbt_n_m_detection(phase1,phase2,n,m);
%         values(g,:) = [index1nm index2nm];
%         ind(g,:) =[n m];
%         g = g+1;
%     end
% end
% [I nm] = max(values(:,1)+values(:,2));
% n = ind(nm,1);
% m = ind(nm,2);      
% RP=n*phase1-m*phase2;
% % distribution of the cyclic relative phase
% CRP = rem(RP,2*pi);
% 
% Nbins = round(exp(0.626+0.4*log(length(RP)-1)));
% range = linspace(-pi,pi,Nbins);
% dCRP = hist(CRP,range);
% dCRP = dCRP/length(CRP);
% figure
% subplot(2,1,1)
% plot(RP)
% title('Relative Phase')
% xlabel('samples')
% subplot(2,1,2)
% bar(range,dCRP)
% axis tight
% title('distribution of the cyclic relative phase')
% xlabel('rad')
% 
% PLV=abs(sum(exp(i*RP))/length(RP));  %Relative Phase Value or mean phase coherence 
% % phase locking value: measure of the intertrial variability of phase difference
% % phase locking value close to 1, means that phase difference
% % varies little across the trial
% phaseRLV=angle(sum(exp(i*RP))/length(RP));% Phase of RPV
% 
% %--- similarity function characterizes Lag Synchronization
% % it means that synchronization can appean at a determined time shift
% k = 1;
% tau = 0:1:100;
% for g = 1:length(tau);
%     for j = 1:length(u)-tau(g)
%         S(j) = ((v(j+tau(g))-u(j))^2);
%     end   
%     Stau(k) = mean(S)/((mean(u.^2)*mean(v.^2))^(1/2));
%     k = k+1;
% end
% 
% [sigmatau indtau] = min(Stau); 
% figure
% hold on 
% plot(tau,Stau)
% % tau at which Stau is minimum can represent the shift between x1 and x2
% % this shift is related tothe phase difference as tau =
% % deltaphase/frequency (deltaphase = mean(phase1-phase2))
% %
% % if x1 = x2 (w1 = w2): Complete synchronization: S(tau) reaches its
% % minimum for sigmatau = 0 for tau = 0
% % if x1 and x2 are indipendent S(tau) will be about 1 for all tau
% % if S(tau) has its minimum for nonzerotau it means that there is a lag
% % between the two processes
% %
% % increasing E (coupling factor)
% % the states of the systems
% % become identical, but shifted in time with respect to
% % each other (Stau has minimum for nonzerotau)
% 
% 
% 
% % try to play with the value w1 w2, E and D
% % if w1 = w2, the sistems are identical for any values of E: 
% %       RLV = 1, complete synchronization (note that increasing the noise with D, RPV can change slightly) 
% %       the similarity function is zero for tau = 0, meaning that there is
% %       no phase lag
% 
