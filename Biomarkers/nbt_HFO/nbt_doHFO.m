% =========================================================================
% *** Function nbt_doHFO
% ***
% *** automatic time-frequency algorithm for detection of HFOs
% *** for more details refer to the publication
% *** http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0094381
% ***
% ***----------------------------------------------------------------------
% *** Analysis:
% *** 1. Filter data in the range [hp lp]
% *** 2. Calculate Hilbert envelope of the band passed signal
% *** 3. Calculate threshold = mean(env)+ 3 SD(env)
% *** 4. Stage 1 - detection of Events of Interest
% *** 5. Merge EoIs with inter-event-interval less than 10 ms into one EoI
% *** 6. Reject events not having a minimum of 6 peaks above 2 SD
% *** 7. Stage 2 -recognition of HFOs among EoIs
% ***
% -------------------------------------------------------------------------
% *** input parameteres:
% *** data - raw EEG signal
% *** fs - frequency sampling rate
% *** hp - high pass frequency for filtering
% *** lp - low pass frequency for filtering
% *** channel_name - name of the channel
% ***
% *** ---------------------------------------------------------------------
% *** Example:
% *** 30 sec of recording from human ECoG, recording channel is HL1-HL2
% *** which corresponds to bipolar montage from two electrodes placed at
% *** hippocampus left
% *** for more details, refer to publication, data taken from patient 1
% ***
% *** load('example.mat')
% *** [HFOobj, results] = nbt_doHFO(data, 2000, 80, 500, channel_name);
% ***
% *** ---------------------------------------------------------------------
% *** for Matlab R12
% *** version 1.0 (Apr 2014)
% *** (c)  Sergey Burnos
% *** email: sergey.burnos@gmail.com
% ***
% *** ---------------------------------------------------------------------
% *** History
% *** 140408 sb created v1.0
% ***

% =========================================================================
function [HFOobj, results] = nbt_doHFO(Signal,SignalInfo,hp,lp, channel_name)
%NBT interface

try
    fs = SignalInfo.converted_sample_frequency;
    HFOobj = nbt_HFO;
catch %in case: standalone 
    fs = SignalInfo;
end
% ---------------------------------------------------------------------
% set parameters

% main parameters
HFOobj.time_thr = ceil(0.006*fs); % 6 ms
HFOobj.fs = fs;
HFOobj.channel_name = channel_name;
% filtering
HFOobj.hp = hp;
HFOobj.lp = lp;
HFOobj.Fst1 = (hp-10)/(fs/2); % parameters for filtering
HFOobj.Fp1 = hp/(fs/2);
HFOobj.Fp2 = lp/(fs/2);
HFOobj.Fst2 = (lp+10)/(fs/2);
HFOobj.Ast1 = 40;
HFOobj.Ap = 0.5;
HFOobj.Ast2 = 40;
% merge IoEs
HFOobj.maxIntervalToJoin = 0.01*HFOobj.fs; % 10 ms
% reject events with less than 6 peaks
HFOobj.minNumberOscillatins = 6;
HFOobj.dFactor = 2;
% Stage 2
HFOobj.bound_min_peak = 40; % Hz, minimum boundary for the lowest ("deepest") point
HFOobj.ratio_thr = 0.5; % threshold for ratio
HFOobj.min_trough = 0.2; % 20 %
HFOobj.limit_fr = 500;
HFOobj.start_fr = 60; % limits for peak frequencies

% ---------------------------------------------------------------------
% 1.
% filtering
Signal_filtered=filtering(Signal, HFOobj);

% ---------------------------------------------------------------------
% 2.
% envelope
env = abs(hilbert(Signal_filtered));

% ---------------------------------------------------------------------
% 3.
% threshold
HFOobj.THR = 3 * std(env) + mean(env);

% ---------------------------------------------------------------------
% 4.
% Stage 1 - detection of EoIs
env(1)=0; env(length(env))=0; % assign the first and last positions at 0 point

pred_env(2:length(env))=env(1:length(env)-1);
pred_env(1)=pred_env(2);
if size(pred_env,1)~=size(env,1) % check the size if it's not been transposed
    pred_env=pred_env';
end

t1=find(pred_env<(HFOobj.THR/2) & env>=(HFOobj.THR/2));    % find zero crossings rising
t2=find(pred_env>(HFOobj.THR/2) & env<=(HFOobj.THR/2));    % find zero crossings falling

trig=find(pred_env<HFOobj.THR & env>=HFOobj.THR); % check if envelope crosses the THR level rising
trig_end=find(pred_env>=HFOobj.THR & env<HFOobj.THR); % check if envelope crosses the THR level falling

nDetectionCounter = 0;
% initialize struct
Detections=struct('channel_name','','start','','peak','', 'stop','',...
    'peakAmplitude', '');

% check every trigger point, where envelope crosses the threshold,
% find start and end points (t1 and t2), t2-t1 = duration of event;
% start and end points defined as the envelope crosses half of the
% threshold for each EoIs

for i=1:numel(trig)
    
    % check for time threshold duration, all times are in pt
    if trig_end(i)-trig(i) >= HFOobj.time_thr
        
        nDetectionCounter = nDetectionCounter + 1;
        k=find(t1<=trig(i) & t2>=trig(i)); % find the starting and end points of envelope
        Detections(nDetectionCounter).channel_name = HFOobj.channel_name;
        
        % check if it does not start before 0 moment
        if t1(k)>0
            Detections(nDetectionCounter).start = t1(k);
        else
            Detections(nDetectionCounter).start = 1;
        end
        
        % check if it does not end after last moment
        if t2(k) <= length(env)
            Detections(nDetectionCounter).stop = t2(k);
        else
            Detections(nDetectionCounter).stop = length(env);
        end
        
        [ peakAmplitude , ind_peak ]   = max(env(t1(k):t2(k)));
        Detections(nDetectionCounter).peak = (ind_peak + t1(k));
        Detections(nDetectionCounter).peakAmplitude = peakAmplitude;
        
    end
end

if (nDetectionCounter > 0)
    
    % -----------------------------------------------------------------
    % 5.
    % Merge EoIs
    joinedDetections = joinDetections(Detections, HFOobj);
    
    % -----------------------------------------------------------------
    % 6.
    % Check for sufficient number of oscillations
    results = checkOscillations(joinedDetections, Signal_filtered, ...
        mean(abs(Signal_filtered)), std(abs(Signal_filtered)), HFOobj);
    
    % -----------------------------------------------------------------
    % 7.
    % Stage 2 - recognition of HFOs among EoIs
    results = PS_validation_all(results, Signal, env, HFOobj);
    
else
    % initialize struct
    results(1).channel_name =  channel_name;
    results(1).start  =  -1;
    results(1).stop   =  -1;
    results(1).peak   =  -1;
    results(1).peakHFOFrequency = 0;
    results(1).troughFrequency = 0;
    results(1).peakLowFrequency = 0;
    results(1).peakAmplitude   =  0;
end

try
    HFOobj = nbt_UpdateBiomarkerInfo(HFOobj, SignalInfo);
    HFOobj.results = results;
catch 
    %in case: standalone: do nothing here.
end
end

% =========================================================================
function result=filtering(Signal, p)

% Filter Signal in the range [hp lp]
% ---------------------------------------------------------------------
% filtering by using IIR Cauer filter
size_check=size(Signal,1);

fil_design=fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',...
    p.Fst1,p.Fp1,p.Fp2,p.Fst2,p.Ast1,p.Ap,p.Ast2);
filter_design=design(fil_design,'ellip'); % band pass IIR filter
[B,A]= sos2tf(filter_design.sosMatrix,filter_design.ScaleValues);
Signal=filtfilt(B,A,Signal); %zero-phase filtering

% check the size if it's not been transposed
if size(Signal,1)~=size_check
    Signal=Signal';
end

result=Signal;
end

% =========================================================================
function joinedDetections = joinDetections(Detections, p)

% Merge EoIs with inter-event-interval less than 10 ms into one EoI
nOrigDetections    = length(Detections);

% fill result with first detection
joinedDetections = struct('channel_name','','start','','peak','', 'stop', '');
joinedDetections(1).channel_name   =  Detections(1).channel_name;
joinedDetections(1).start    =  Detections(1).start;
joinedDetections(1).stop  =  Detections(1).stop;
joinedDetections(1).peak  =  Detections(1).peak;
joinedDetections(1).peakAmplitude  =  Detections(1).peakAmplitude;
nDetectionCounter = 1;

for n = 2 : nOrigDetections
    
    % join detection
    if Detections(n).start > joinedDetections(nDetectionCounter).start
        
        nDiff = Detections(n).start - joinedDetections(nDetectionCounter).stop;
        
        if nDiff < p.maxIntervalToJoin
            
            joinedDetections(nDetectionCounter).stop = Detections(n).stop;
            
            if joinedDetections(nDetectionCounter).peakAmplitude < ...
                    Detections(n).peakAmplitude
                
                joinedDetections(nDetectionCounter).peakAmplitude = ...
                    Detections(n).peakAmplitude;
                joinedDetections(nDetectionCounter).peak=Detections(n).peak;
                
            end
            
        else
            
            % initialize struct
            nDetectionCounter = nDetectionCounter + 1;
            joinedDetections(nDetectionCounter).channel_name   =  Detections(n).channel_name;
            joinedDetections(nDetectionCounter).start =  Detections(n).start;
            joinedDetections(nDetectionCounter).stop =  Detections(n).stop;
            joinedDetections(nDetectionCounter).peak  =  Detections(n).peak;
            joinedDetections(nDetectionCounter).peakAmplitude  =  Detections(n).peakAmplitude;
            
        end
    end
end

end

% =========================================================================
function checkedOscillations = checkOscillations(Detections, Signal, ...
    AbsoluteMean, AbsoluteStd, p)

% Reject events not having a minimum of 6 peaks above 2 SD
% ---------------------------------------------------------------------
% set parameters
nDetectionCounter = 0;

for n = 1 : length(Detections)
    
    % get EEG for interval
    intervalEEG = Signal(Detections(n).start : Detections(n).stop);
    
    % compute abs values for oscillation interval
    absEEG = abs(intervalEEG);
    
    % look for zeros
    zeroVec=find(intervalEEG(1:end-1).*intervalEEG(2:end)<0);
    nZeros=numel(zeroVec);
    
    nMaxCounter = 0;
    
    if nZeros > 0
        
        % look for maxima with sufficient amplitude between zeros
        for ii = 1 : nZeros-1
            
            lStart = zeroVec(ii);
            lEnd   = zeroVec(ii+1);
            dMax = max(absEEG(lStart:lEnd));
            
            if dMax > AbsoluteMean + p.dFactor * AbsoluteStd;
                
                nMaxCounter = nMaxCounter + 1;
                
            end
        end
    end
    
    if nMaxCounter  >= p.minNumberOscillatins
        
        nDetectionCounter = nDetectionCounter + 1;
        
        checkedOscillations(nDetectionCounter).channel_name  = ...
            Detections(n).channel_name; %#ok<AGROW>
        checkedOscillations(nDetectionCounter).start    = ...
            Detections(n).start; %#ok<AGROW>
        checkedOscillations(nDetectionCounter).stop     = ...
            Detections(n).stop; %#ok<AGROW>
        checkedOscillations(nDetectionCounter).peak     = ...
            Detections(n).peak; %#ok<AGROW>
        checkedOscillations(nDetectionCounter).peakHFOFrequency =  0; %#ok<AGROW>
        checkedOscillations(nDetectionCounter).troughFrequency  =  0; %#ok<AGROW>
        checkedOscillations(nDetectionCounter).peakLowFrequency =  0; %#ok<AGROW>
        checkedOscillations(nDetectionCounter).peakAmplitude    = ...
            Detections(n).peakAmplitude; %#ok<AGROW>
        
    end
end

if nDetectionCounter < 1
    
    % initialize struct
    checkedOscillations(1).channel_name =  p.channel_name;
    checkedOscillations(1).start =  -1;
    checkedOscillations(1).stop =  -1;
    checkedOscillations(1).peak =  -1;
    checkedOscillations(1).peakHFOFrequency =  0;
    checkedOscillations(1).troughFrequency  =  0;
    checkedOscillations(1).peakLowFrequency =  0;
    checkedOscillations(1).peakAmplitude    =  0;
    
end
end

% =========================================================================
function PSvalidated = PS_validation_all(Detections, Signal, env, p)

% Stage 2 - recognition of HFOs among EoIs
% -----------------------------------------------------------------------------
% set parameters
nDetectionCounter = 0;

for n = 1 : length(Detections)
    
    if Detections(n).peak ~= -1
        
        % find the sec interval where the peak occurs
        det_start = Detections(n).peak-Detections(n).start;
        det_stop  = Detections(n).stop-Detections(n).peak;
        
        % define 0.5 sec interval where HFOs occur and take for
        % analysis 0.1 sec before + interval (0.5 sec) + 0.4 sec after
        % in total 1 sec around an HFO is analyzed
        
        if floor(Detections(n).peak/(p.fs/2)) == 0 % First 0.5 sec
            
            det_peak = Detections(n).peak;
            intervalST=Signal(1: p.fs);
            interval_env=env(1: p.fs);
            
        elseif (floor(Detections(n).peak/(p.fs/2)) == ...
                length(Signal)/(p.fs/2) -1) % last 0.5 sec
            
            det_peak = mod(Detections(n).peak, p.fs);
            intervalST=Signal(length(Signal)-p.fs+1: length(Signal));
            interval_env=env(length(Signal)-p.fs+1: length(Signal));
        
            
        else
            
            det_peak = mod(Detections(n).peak, (p.fs/2))+floor(0.1*p.fs);
            t_peak_interval = floor(Detections(n).peak/(p.fs/2));
            intervalST = Signal(t_peak_interval*p.fs/2+1-floor(0.1*p.fs):...
                t_peak_interval*p.fs/2+ceil(0.9*p.fs));
            interval_env=env(t_peak_interval*p.fs/2+1-floor(0.1*p.fs):...
                t_peak_interval*p.fs/2+ceil(0.9*p.fs));
            
        end
        
        
        %--------------------------------------------------------------------------
        % calculate S-transform frequency from 0 to limit_fr,
        [STSignal, ~ , ~] = st(intervalST, 0, p.limit_fr, 1/p.fs, 1); % S-transform
        
        % -----------------------------------------------------------------------------
        % analyze instantaneous power spectra
        true_HFO=0; % counter for recognized HFOs
        
        for tcheck = max(det_peak-det_start,1):1:det_peak+det_stop
            
            % check if the envelope is above half of the peak+threshold
            if interval_env(tcheck)>1/2*(Detections(n).peakAmplitude+p.THR)
                
                % for maximum upper start_f frequency
                [maxV, maxF] = max(abs(STSignal(p.start_fr:end, tcheck)).^2); % HFO peak
                maxF = maxF + p.start_fr-1;
                
                % search for minimum before found maximum
                [ minV , minF] = min(abs(STSignal(p.bound_min_peak:maxF, tcheck)).^2); %the trough
                minF=minF+p.bound_min_peak-1;
                
                % check for sufficient difference
                [peaks, ~]=findpeaks(abs(STSignal(1:minF, tcheck)).^2); % Low frequcny peak
                if isempty(peaks)
                    fpeaks=floor(minF/2);
                    peaks=abs(STSignal(fpeaks, tcheck)).^2;
                end
                
                ratio_HFO = 10*log10(maxV) - 10*log10(minV); % ratio between HFO peak and the trough
                
                ratio_LowFr = 10*log10(peaks(end)) - 10*log10(minV); % ratio between Low Frequency peak and the trough
                
                % check the difference and check for sufficient trough
                if (ratio_HFO > p.ratio_thr * ratio_LowFr) && (ratio_HFO>p.min_trough*10*log10(maxV)) && (maxF<500)
                    
                    true_HFO=true_HFO+0;
                    
                else
                    
                    true_HFO=true_HFO+1;
                    
                end
            end
            
        end
        
        if (true_HFO==0) % all conditions are satisfied
            
            % search for peak
            tcheck=det_peak;
            [~, maxF] = max(abs(STSignal(p.start_fr:end, tcheck)).^2);
            maxF = maxF + p.start_fr-1;
            
            % search for minimum before found maximum
            [ ~ , minF] = min(abs(STSignal(p.bound_min_peak:maxF, tcheck)).^2); %the trough
            minF=minF+p.bound_min_peak-1;
            
            % check for sufficient difference
            [~, fpeaks]=findpeaks(abs(STSignal(1:minF, tcheck)).^2);
            
            nDetectionCounter = nDetectionCounter + 1;
            
            % times are translates to seconds
            PSvalidated(nDetectionCounter).channel_name     =  Detections(n).channel_name; %#ok<AGROW>
            PSvalidated(nDetectionCounter).start            =  Detections(n).start/p.fs; %#ok<AGROW>
            PSvalidated(nDetectionCounter).stop             =  Detections(n).stop/p.fs; %#ok<AGROW>
            PSvalidated(nDetectionCounter).peak             =  Detections(n).peak/p.fs; %#ok<AGROW>
            PSvalidated(nDetectionCounter).peakHFOFrequency =  maxF; %#ok<AGROW>
            PSvalidated(nDetectionCounter).troughFrequency  =  minF; %#ok<AGROW>
            PSvalidated(nDetectionCounter).peakLowFrequency =  fpeaks(end); %#ok<AGROW>
            PSvalidated(nDetectionCounter).peakAmplitude    =  Detections(n).peakAmplitude; %#ok<AGROW>
            
        end
    end
end

if nDetectionCounter < 1
    
    % initialize struct
    PSvalidated(1).channel_name =  p.channel_name;
    PSvalidated(1).start =  -1;
    PSvalidated(1).stop =  -1;
    PSvalidated(1).peak =  -1;
    PSvalidated(1).peakHFOFrequency =  0;
    PSvalidated(1).troughFrequency  =  0;
    PSvalidated(1).peakLowFrequency =  0;
    PSvalidated(1).peakAmplitude    =  0;
    
end

end