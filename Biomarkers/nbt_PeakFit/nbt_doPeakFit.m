% Calculates several spectral measures.
%
% Usage:
%   nbt_doPeakFit
%
% Inputs:
% FrequencyBandsInput: A 2 column vector with frequency bands where spectral
% measures are calculated (e.g..[8 13; 4 7]). Will override default
% settings.
%
% PSDWindow: The window used for the PSD (Welch Method), default is a 2^9
% long hamming window
%
% PSDFreqResolution: The zero-padded frequency resoultion of the PSD (given
% by Sampling frequency/ window length , the window length is rounded to up
% to a length of the power of two. ). Zero padding in the frequency domain is equal to
% interpolation in the time domain, and does not increase the actual
% frequency resolution of the data.
%
% PSDOverlap: Overlap for the Welch method (default is 0)
%
% Outputs:
%
% Example:
%
%
% References:
%
% See also:
%

%------------------------------------------------------------------------------------
% Originally created by Simon-Shlomo Poil (2009), see NBT website for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) 2009  Simon-Shlomo Poil (Neuronal Oscillations and Cognition group,
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
% ---------------------------------------------------------------------------------------



function PeakFitObject = nbt_doPeakFit(NBTSignal, InfoObject, FrequencyBandsInput, PSDWindow, PSDFreqResolution, PSDOverlap)
%% Copyright (c) 2009, Simon-Shlomo Poil(Center for Neurogenomics and
%% Cognitive Research (CNCR), VU University Amsterdam) based on algoritms
%% by Rick Jansen, VU University Amsterdam


%% input checks
error(nargchk(2,6,nargin))

if(~exist('FrequencyBandsInput','var'))
    FrequencyBandsInput = [];
end
if(~exist('PSDWindow','var'))
    PSDWindow = hamming(2^9);
end
if(~exist('PSDFreqResolution','var'))
    PSDFreqResolution = 2^14;
else
    PSDFreqResolution = 2^(nextpow2(1/(PSDFreqResolution/InfoObject.converted_sample_frequency))); %because padded resolution is given by SamplingFreq/WindowLength
end
if(~exist('PSDOverlap','var'))
    PSDOverlap = 0;
end


PeakFitObject = nbt_PeakFit(size(NBTSignal,2));
PeakFitObject.PSDFreqResolution = InfoObject.converted_sample_frequency/PSDFreqResolution;
PeakFitObject.PSDWindow = PSDWindow;
PeakFitObject.PSDOverlap = PSDOverlap;

%Prepare Signal
NBTSignal = nbt_RemoveIntervals(NBTSignal,InfoObject);
[NBTSignal] = nbt_filter_firHp(NBTSignal,0.5,InfoObject.converted_sample_frequency,4); %this high-pass is done to get better a PSD


for ChId=1:size(NBTSignal(:,:),2)
    [p1,f1]=pwelch(NBTSignal(:,ChId),PSDWindow,PSDOverlap,PSDFreqResolution,InfoObject.converted_sample_frequency); %2^9
    
    PeakFitObject.p{ChId,1} = p1;
    PeakFitObject.f = f1;
    
    %% Find Alpha peak
    %define Alpha peak range
    a = find(f1 >4, 1 );
    b = find(f1 >14, 1 );
    loweredge = find(f1>0.5,1);
    upperedge = find(f1>42,1);
    
    %we fit a 1/f baseline
    try
        [pks,locs] = findpeaks(p1,'MINPEAKHEIGHT',prctile(p1,90));
        if ~(50<pks(1)<200)
            pks(1)=130;
        end
        s=fit(log(f1([locs(1):a,b:upperedge])),log((p1([locs(1):a,b:upperedge]))),'poly1');
        PeakFitObject.OneOverF_Alpha{ChId,1}={exp(s.p2),s.p1};
        zeta2=exp(s.p2).*f1(2:end).^s.p1;
        p_minus1overf=p1(2:end)-zeta2;
        %Subtract this 1/f baseline
        PeakFitObject.Pminus1overf(ChId) = sum(p_minus1overf);
        PeakFitObject.Fminus1overf(ChId) = sum(p_minus1overf > 0.5*median(p_minus1overf));
    catch
    end
    %and fit Gaussian to the peak
    try
        s1=fit(f1(a+1:b+1),p_minus1overf(a:b),'gauss1','lower',[0 3 -100 ],'upper',[1000 20 200],'MaxIter',100000,'MaxFunEvals',200000);%,'startpoint',[start mu 3 50 -1],'lower',[0 0 -100 -100 ],'upper',[1000 40 200 2000 0],'MaxIter',1000);
        %find the confidence interval
        confidenceInterval =predint(s,s1.b1,0.95,'functional');
        if((s1.a1+s(s1.b1)) > confidenceInterval(2))
            PeakFitObject.AlphaFreq(ChId,1) = s1.b1;
            PeakFitObject.corrected_power(ChId,1)= s1.a1;
            PeakFitObject.PeakWidth(ChId,1)= s1.c1;
        end
    catch
    end
    
    %% Find second alpha peak if it exists
    try
        s1=fit(f1(a:b),p_minus1overf(a:b),'gauss2','lower',[0 3 -100 ],'upper',[1000 20 200],'MaxIter',100000,'MaxFunEvals',200000);
        confidenceInterval1 =predint(s,s1.b1,0.95,'functional');
        confidenceInterval2 =predint(s,s1.b2,0.95,'functional');
        if (((s1.a1+s(s1.b1)) > confidenceInterval1(2)) && (((s1.a2+s(s1.b2)) > confidenceInterval2(2))))
            PeakFitObject.AlphaFreq1(ChId,1) = s1.b1;
            PeakFitObject.Alpha1corrected_power(ChId,1)= s1.a1;
            PeakFitObject.Alpha1PeakWidth(ChId,1)= s1.c1;
            PeakFitObject.AlphaFreq2(ChId,1) = s1.b2;
            PeakFitObject.Alpha2corrected_power(ChId,1)= s1.a2;
            PeakFitObject.Alpha2PeakWidth(ChId,1)= s1.c2;
        end
    catch
    end
    %% Find TF theta see e.g. Klimesch 1999, EEG alpha and theta
    % oscillations reflect cognitive and memory performance: a review
    % and analysis, Brain Research Reviews 29:169-195
    try
        freqIndex = find(f1 < s1.b1);
        [dummy,index] = min(p1(2:freqIndex(end)));
        
        PeakFitObject.TF(ChId,1) = f1(index+1);
    catch
        PeakFitObject.TF(ChId,1) = nan(1,1);
    end
    
    %% find beta peak
    % This can be tricky (because of the wide freqency range), so we first estimate the peak location using a
    % Central Frequency estitimate
    findex1 = find(f1 >= 13,1);
    findex2 = find(f1 <= 30,1,'last');
    
    BetaFreq = sum(p1(findex1:findex2).*f1(findex1:findex2))/sum(p1(findex1:findex2));
    % see van Aerde 2009, J Physiol,
    %we fit a 1/f baseline
    if (BetaFreq >= 17 && BetaFreq <= 22)
        a = find(f1>16,1);
        b = find(f1>23,1);
    elseif (BetaFreq >=22)
        a = find(f1>21,1);
        b = find(f1>42,1);
    else
        a = find(f1>13,1);
        b = find(f1>23,1);
    end
    
    loweregde = find(f1>12,1); %>11
    upperegde = find(f1>45,1);
    try
        s=fit(f1([loweregde:a,b:upperegde]),p1([loweregde:a,b:upperegde]),'power2','robust','on', 'MaxIter', 20000,'MaxFunEvals',40000);%,'upper',[100000 0],'lower',[0 -10] );
        
        %Subtract this 1/f baseline
        p_minus1overf=p1(2:end)-s(f1(2:end));
        PeakFitObject.OneOverF_Beta{ChId,1}={s.a,s.b,s.c};
        s1=fit(f1(a:b),p_minus1overf(a:b),'gauss1','lower',[0 12 -100 ],'upper',[1000 32 200],'MaxIter',100000,'MaxFunEvals',200000);%,'startpoint',[start mu 3 50 -1],'lower',[0 0 -100 -100 ],'upper',[1000 40 200 2000 0],'MaxIter',1000);
        %find the confidence interval
        confidenceInterval =predint(s,s1.b1,0.95,'functional');
        %sometimes this give NaN values
        if(isnan(confidenceInterval(2)))
            if(s1.a1/s(s1.b1) > 0.5)
                confidenceInterval(2) = s(s1.b1); %which we try to correct for.
            end
        end
        
        if((s1.a1+s(s1.b1)) > confidenceInterval(2))
            PeakFitObject.BetaFreq(ChId,1) = s1.b1;
            PeakFitObject.Betacorrected_power(ChId,1)= s1.a1;
            PeakFitObject.BetaPeakWidth(ChId,1)= s1.c1;
        end
    catch
    end
    %% Find second beta peak (if it exists)
    % adding new algorithm per 12 april 2012. Now only fitting the second
    % peak.
    try
        %First we estimate the position of the second peak
        a = find(f1>(s1.b1+s1.c1/2),1); % it should exists above the width of the dominant beta peak
        b = find(f1>BetaFreq+6,1); % and within certain range.
        % then we fit as above with an additional detrend to make the fit
        % easier
        
        s1=fit(f1(a+1:b+1),nbt_fastdetrend(p_minus1overf(a:b)),'gauss1','lower',[0 12 -100 ],'upper',[1000 32 200],'MaxIter',100000,'MaxFunEvals',200000);%,'startpoint',[start mu 3 50 -1],'lower',[0 0 -100 -100 ],'upper',[1000 40 200 2000 0],'MaxIter',1000);
        
        confidenceInterval =predint(s,s1.b1,0.95,'functional');
        if(isnan(confidenceInterval(2)))
            if(s1.a1/s(s1.b1) > 0.5)
                confidenceInterval(2) = s(s1.b1); %which we try to correct for.
            end
        end
        if (((s1.a1+s(s1.b1)) > confidenceInterval(2)))
            %PeakFitObject.BetaFreq1(ChId,1) = s1.b1; not used anymore.
            %PeakFitObject.Beta1corrected_power(ChId,1)= s1.a1;
            %PeakFitObject.Beta1PeakWidth(ChId,1)= s1.c1;
            if(s1.b1> BetaFreq && s1.b1 > (0.2+BetaFreq+PeakFitObject.BetaPeakWidth(ChId)/2))
                PeakFitObject.BetaFreq2(ChId,1) = s1.b1;
                PeakFitObject.Beta2corrected_power(ChId,1)= s1.a1;
                PeakFitObject.Beta2PeakWidth(ChId,1)= s1.c1;
                PeakFitObject.Beta2PeakDistance(ChId,1) = PeakFitObject.BetaFreq(ChId,1) - s1.b1;
            end
        end
    catch
    end
    
    %Power spectrum analysis. Only if FrequencyBands exists
    if(~isempty(FrequencyBandsInput))
        PeakFitObject.FrequencyBands = FrequencyBandsInput;
        FrequencyBands = FrequencyBandsInput;
    else
        %determine frequencyBands
        FrequencyBands=nbt_FindFrequencyBands(PeakFitObject,ChId,p1,f1);
        PeakFitObject.FrequencyBands{ChId,1} = FrequencyBands;
    end
    
         try
             PeakFitObject.IAF(ChId,1) = FrequencyBands(10,1);
         catch
         end
    
    AbsolutePower = nan(size(FrequencyBands,1),1);
    RelativePower = nan(size(FrequencyBands,1),1);
    for i=1:1:size(FrequencyBands,1)
        if(isnan(FrequencyBands(i,1)) || isnan(FrequencyBands(i,2)))
            continue
        end
        findex1 = find(f1 >= FrequencyBands(i,1),1);
        findex2 = find(f1 <= FrequencyBands(i,2),1,'last');
        
        AbsolutePower(i) = sum(p1(findex1:findex2));
        
        findex3 = find(f1 >= 0,1);
        findex4 = find(f1 <= 45,1,'last');
        
        try
            PeakFitObject.AbsolutePower{i,1}(ChId) = AbsolutePower(i);
            PeakFitObject.RelativePower{i,1}(ChId) = AbsolutePower(i)/sum(p1(findex3:findex4));
            RelativePower(i) = PeakFitObject.RelativePower{i,1}(ChId);
            % for the following biomarkers see Vural et al 2010.
            PeakFitObject.CentralFreq{i,1}(ChId) = sum(p1(findex1:findex2).*f1(findex1:findex2))/sum(p1(findex1:findex2));
            PeakFitObject.CentralPower{i,1}(ChId) = p1(find(PeakFitObject.CentralFreq{i,1}(ChId) >= f1,1));
            PeakFitObject.Bandwidth{i,1}(ChId)   = sqrt(sum((f1(findex1:findex2) - PeakFitObject.CentralFreq{i,1}(ChId)).^2 .* p1(findex1:findex2))/sum(p1(findex1:findex2)));
            temprange = findex1:findex2;
            PeakFitObject.SpectralEdge{i,1}(ChId) = f1(temprange(find(cumsum(p1(findex1:findex2))./sum(p1(findex1:findex2)) >= 0.9,1)));
        catch
        end
        clear temprange;
    end
    
    %Frequency band ratio
    for i=1:(length(AbsolutePower))
        try
            tmpc = PeakFitObject.AbsPowerRatio{i,1};
        catch
            PeakFitObject.AbsPowerRatio{i,1} = cell(length(AbsolutePower),1);
            tmpc = PeakFitObject.AbsPowerRatio{i,1};
        end
        for mm=1:length(AbsolutePower)
            tmpc{mm,1}(ChId) = AbsolutePower(mm)./AbsolutePower(i);
        end
        PeakFitObject.AbsPowerRatio{i,1} = tmpc;
        
        try
            tmpc = PeakFitObject.RelPowerRatio{i,1};
        catch
            PeakFitObject.RelPowerRatio{i,1} = cell(length(RelativePower),1);
            tmpc = PeakFitObject.RelPowerRatio{i,1};
        end
        for mm=1:length(RelativePower)
            tmpc{mm,1}(ChId) = RelativePower(mm)./RelativePower(i);
        end
        PeakFitObject.RelPowerRatio{i,1} = tmpc;
    end
end
    %% splitting up bioms per classical frequency bands
            PeakFitObject.Bandwidth_Delta = PeakFitObject.Bandwidth{1};
            PeakFitObject.Bandwidth_Theta = PeakFitObject.Bandwidth{2};
            PeakFitObject.Bandwidth_Alpha = PeakFitObject.Bandwidth{3};
            PeakFitObject.Bandwidth_Beta = PeakFitObject.Bandwidth{4};
            PeakFitObject.Bandwidth_Gamma = PeakFitObject.Bandwidth{5};
            
            PeakFitObject.CentralFreq_Delta = PeakFitObject.CentralFreq{1};
            PeakFitObject.CentralFreq_Theta = PeakFitObject.CentralFreq{2};
            PeakFitObject.CentralFreq_Alpha = PeakFitObject.CentralFreq{3};
            PeakFitObject.CentralFreq_Beta = PeakFitObject.CentralFreq{4};
            PeakFitObject.CentralFreq_Gamma = PeakFitObject.CentralFreq{5};
            PeakFitObject.CentralFreq_Broadband = PeakFitObject.CentralFreq{6};
            PeakFitObject.CentralFreq_Alpha1 =PeakFitObject.CentralFreq{7};
            PeakFitObject.CentralFreq_Alpha2 = PeakFitObject.CentralFreq{8};
            
            PeakFitObject.SpectralEdge_Delta = PeakFitObject.SpectralEdge{1};
            PeakFitObject.SpectralEdge_Theta = PeakFitObject.SpectralEdge{2};
            PeakFitObject.SpectralEdge_Alpha = PeakFitObject.SpectralEdge{3};
            PeakFitObject.SpectralEdge_Beta = PeakFitObject.SpectralEdge{4};
            PeakFitObject.SpectralEdge_Gamma = PeakFitObject.SpectralEdge{5};

            PeakFitObject.AbsolutePower_Delta = PeakFitObject.AbsolutePower{1};
            PeakFitObject.AbsolutePower_Theta = PeakFitObject.AbsolutePower{2};
            PeakFitObject.AbsolutePower_Alpha = PeakFitObject.AbsolutePower{3};
            PeakFitObject.AbsolutePower_Beta = PeakFitObject.AbsolutePower{4};
            PeakFitObject.AbsolutePower_Gamma = PeakFitObject.AbsolutePower{5};
            PeakFitObject.AbsolutePower_Broadband = PeakFitObject.AbsolutePower{6};
            PeakFitObject.AbsolutePower_Alpha1 = PeakFitObject.AbsolutePower{7};
            PeakFitObject.AbsolutePower_Alpha2 = PeakFitObject.AbsolutePower{8};
            
            PeakFitObject.RelativePower_Delta = PeakFitObject.RelativePower{1};
            PeakFitObject.RelativePower_Theta = PeakFitObject.RelativePower{2};
            PeakFitObject.RelativePower_Alpha = PeakFitObject.RelativePower{3};
            PeakFitObject.RelativePower_Beta = PeakFitObject.RelativePower{4};
            PeakFitObject.RelativePower_Gamma = PeakFitObject.RelativePower{5};
            
%Update information
% assignin('base','thenewPeakFitObject',PeakFitObject);
%PeakFitObject.p=[];
PeakFitObject = nbt_UpdateBiomarkerInfo(PeakFitObject, InfoObject);

end

function FrequencyBands=nbt_FindFrequencyBands(PeakFitObject,ChId,p,frq)
%Fixed frquency bands
FrequencyBands = [1 4]; %delta
FrequencyBands = [FrequencyBands; 4 8]; % theta
FrequencyBands = [FrequencyBands; 8 13]; % alpha
FrequencyBands = [FrequencyBands; 13 30]; %beta
FrequencyBands = [FrequencyBands; 30 45]; %gamma
FrequencyBands = [FrequencyBands; 1 45]; %broadband;
FrequencyBands = [FrequencyBands; 8 10]; %lower alpha
FrequencyBands = [FrequencyBands; 10 13];% upper alpha
%find frequency bands based on IAF the indiviual alpha frequency.
%Adapted from Klimesch et al 1999;
%find f1, f2
if(isnan(PeakFitObject.TF(ChId)) || PeakFitObject.TF(ChId) < 2)
    f1 =  8;
else
    f1 = PeakFitObject.TF(ChId);
end
if(isnan(PeakFitObject.AlphaFreq(ChId)))
    f2 =  13;
else
    f2 =  abs(5 - (PeakFitObject.AlphaFreq(ChId)-1))+ PeakFitObject.AlphaFreq(ChId);
end

%IAF
IAF=sum(p(find(frq >= f1,1):find(frq <=f2,1,'last')).*frq(find(frq >= f1,1):find(frq <=f2,1,'last')))/sum(p(find(frq >= f1,1):find(frq <=f2,1,'last')));
f2 =abs( 5 - (IAF - 1)) + IAF;
IAF=sum(p(find(frq >= f1,1):find(frq <=f2,1,'last')).*frq(find(frq >= f1,1):find(frq <=f2,1,'last')))/sum(p(find(frq >= f1,1):find(frq <=f2,1,'last')));
%IDelta
FrequencyBands = [FrequencyBands; 1, f1];
%ITheta
FrequencyBands = [FrequencyBands; f1 - 2, f1];
%Alpha1
FrequencyBands = [FrequencyBands; IAF-4, IAF-2];
%Alpha2
FrequencyBands = [FrequencyBands; IAF-2, IAF];
%Alpha3
FrequencyBands = [FrequencyBands; IAF, IAF+2];
%Alpha all
FrequencyBands = [FrequencyBands; IAF-4, IAF+2];
%Ibeta
FrequencyBands = [FrequencyBands; IAF+2, 30];
end
