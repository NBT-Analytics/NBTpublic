% nbt_runDFA_gui(Signal, SignalInfo, SaveDir) - GUI support function for
% running DFA
%
% Usage:
%  nbt_runDFA_gui(Signal, SignalInfo, SaveDir)
%
% Inputs:
%   Signal
%   SignalInfo
%   SaveDir
%
% Outputs:
%
% Example:    
%
% References:
% 
% See also: 
%  
  
%------------------------------------------------------------------------------------
% Originally created by Giuseppina Schiavone (2012), see NBT website (http://www.nbtwiki.net) for current email address
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



function nbt_runDFA_gui(Signal, SignalInfo, SaveDir)
SettingsDFA = evalin('base','SettingsDFA');
duration = floor(size(Signal,1)/SignalInfo.converted_sample_frequency);
display(['Signal duration: ' num2str(duration) ' sec' ])
if ~exist('SettingsDFA','var') || isempty(SettingsDFA)
    Frange = (input('Specify frequency range in Hz [lowF highF] (i.e. [8 13]): '));
    hp = Frange(1);
    lp = Frange(2);
    fir_order = input('Specify filter order (press Enter for default): '); % at least two oscillation cycles are covered by the filter window
    if isempty (fir_order)
        fir_order = 2/hp;
    end
%--- The DFA is not accurate for very short windows nor for long windows,
    Fs = SignalInfo.converted_sample_frequency;
    %
    Overlap = (input('Specify windows overlap (for default=0.5 press Enter): '));
    if isempty(Overlap)
        Overlap = 0.5;
    end
    logbin = (input('Specify bins for logarithmic window scale (for default=10 press Enter): '));
    if isempty(logbin)
        logbin = 10;
    end
    N = size(Signal,1);
    FitInterval = [5 0.1*(N/Fs)]; %default, max window length imposed = 0.1*signal_length
    CalcInterval = [0.1 N/Fs];
    % CalcInterval = [0.5*FitInterval(1) 5*FitInterval(2)];
    display('Compute DFA on 10 random noise timeseries ...');
    display('This initial processing will take some seconds and allows you to select a proper fitting interval for the DFA ...');
    display([ 'Calculation interval from ' num2str(CalcInterval(1)) ' to ' num2str(CalcInterval(2)) ' sec']);
    display([ 'Default Fitting Interval from ' num2str(FitInterval(1)) ' to ' num2str(FitInterval(2)) ' sec']);
%--- test with random noise chose a fitting interval
Nrand = 10;
NoiseSignal = randn(N,Nrand);
NoiseSignalInfo = nbt_Info;
NoiseSignalInfo.converted_sample_frequency = Fs;
[NoiseSignal,NoiseSignalInfo] = nbt_GetAmplitudeEnvelope(NoiseSignal, NoiseSignalInfo, hp, lp, fir_order);
% t1 = tic;
[DFAobject,DFA_exp] = nbt_doDFA(NoiseSignal,NoiseSignalInfo,FitInterval, CalcInterval, Overlap, 0, 0, logbin);
% toc(t1) (about 20 sec)


DFA_x = DFAobject.DFA_x;
for ChannelID = 1:Nrand % loop over noise
    DFA_y = DFAobject.DFA_y{ChannelID,1};
    DFA_SmallTime_LogSample = min(find(DFA_x>=CalcInterval(1)*Fs));		%
    DFA_LargeTime_LogSample = max(find(DFA_x<=CalcInterval(2)*Fs));
    DFA_SmallTimeFit_LogSample = min(find(DFA_x>=FitInterval(1)*Fs));
    DFA_LargeTimeFit_LogSample = max(find(DFA_x<=FitInterval(2)*Fs));
    X = [ones(1,DFA_LargeTimeFit_LogSample-DFA_SmallTimeFit_LogSample+1)' log10(DFA_x(DFA_SmallTimeFit_LogSample:DFA_LargeTimeFit_LogSample))'];
    Y = log10(DFA_y(DFA_SmallTimeFit_LogSample:DFA_LargeTimeFit_LogSample));
    DFA_exp = X\Y; %least-square fit
    DFA_exp = DFA_exp(2);
    DFAobject.MarkerValues(ChannelID,1) = DFA_exp;
end
% mean DFA_y  and exp over the 10 random noise    
for i = 1:Nrand
    DFA_y(:,i) = DFAobject.DFA_y{i,1};
end
DFA_y = mean(DFA_y,2);
DFA_exp = mean(DFAobject.MarkerValues);
DFA_exp_std = 1.96*std(DFAobject.MarkerValues);
figure('Name', 'DFA on random noise timeseries')
hold on
plot(log10(DFA_x(DFA_SmallTimeFit_LogSample:DFA_LargeTimeFit_LogSample)/Fs),log10(DFA_y(DFA_SmallTimeFit_LogSample:DFA_LargeTimeFit_LogSample)),'ro')
LineHandle=lsline;
plot(log10(DFA_x(DFA_SmallTime_LogSample:DFA_LargeTime_LogSample)/Fs),log10(DFA_y(DFA_SmallTime_LogSample:DFA_LargeTime_LogSample)),'k.')
grid on
axis([log10(min(DFA_x/Fs))-0.1 log10(max(DFA_x/Fs))+0.1 log10(min(DFA_y(3:end)))-0.1 log10(max(DFA_y))+0.1])
plot(ones(size(DFA_y))*log10(FitInterval(1)),log10(DFA_y),'b--')
plot(ones(size(DFA_y))*log10(FitInterval(2)),log10(DFA_y),'b--')
xlabel('log_{10}(time), [Seconds]','Fontsize',12)
ylabel('log_{10} F(time)','Fontsize',12)
title(['DFA-exp= ' num2str(DFA_exp) ' \pm ' num2str(DFA_exp_std)],'Fontsize',12)   
    
    
%---    
display(['For the default fitting interval mean DFA-exp= ' num2str(DFA_exp) ' \pm ' num2str(DFA_exp_std)]);
option = lower(input('Do you want to select another fitting interval? Y/N [Y]: ', 's'));
     
if option == 'y'
    [FitInterval] = nbt_doDFA_rand(DFAobject, Nrand, FitInterval, CalcInterval,Fs);
%     CalcInterval = [0.5*FitInterval(1) 1.5*FitInterval(2)];
    CalcInterval = [0.5*FitInterval(1) N/Fs];
    display('Compute DFA on EEG signal ...');
    [Signal,SignalInfo] = nbt_GetAmplitudeEnvelope(Signal, SignalInfo, hp, lp, fir_order);
    name = genvarname (['DFA' num2str(hp) '_' num2str(lp) 'Hz']);
    eval([name '= nbt_doDFA(Signal,SignalInfo,FitInterval, CalcInterval, Overlap, 0, 0, logbin)']);
    SettingsDFA.hp = hp;
    SettingsDFA.lp = lp;
    SettingsDFA.fir_order = fir_order;
    SettingsDFA.FitInterval = FitInterval;
    SettingsDFA.CalcInterval = CalcInterval;
    SettingsDFA.Overlap = Overlap;
    SettingsDFA.logbin = logbin;
    assignin('base','SettingsDFA',SettingsDFA);
    close(gcf)
else
%     CalcInterval = [FitInterval(1)*0.9 FitInterval(2)*1.1];
%     CalcInterval = [0.5*FitInterval(1) 1.5*FitInterval(2)];
    CalcInterval = [0.5*FitInterval(1) N/Fs];
    display('Compute DFA on EEG signal ...');
    [Signal,SignalInfo] = nbt_GetAmplitudeEnvelope(Signal, SignalInfo, hp, lp, fir_order);
    name = genvarname (['DFA' num2str(hp) '_' num2str(lp) 'Hz']);
    eval([name '= nbt_doDFA(Signal,SignalInfo,FitInterval, CalcInterval, Overlap, 0, 0, logbin)']);
    SettingsDFA.hp = hp;
    SettingsDFA.lp = lp;
    SettingsDFA.fir_order = fir_order;
    SettingsDFA.FitInterval = FitInterval;
    SettingsDFA.CalcInterval = CalcInterval;
    SettingsDFA.Overlap = Overlap;
    SettingsDFA.logbin = logbin;
    assignin('base','SettingsDFA',SettingsDFA);
    close(gcf)
end

else
    N = size(Signal,1);
    Fs = SignalInfo.converted_sample_frequency;
    hp = SettingsDFA.hp;
    lp = SettingsDFA.lp;
    fir_order = SettingsDFA.fir_order;
    FitInterval = SettingsDFA.FitInterval;
    CalcInterval = [0.5*FitInterval(1) N/Fs];%SettingsDFA.CalcInterval;
    Overlap = SettingsDFA.Overlap;
    logbin = SettingsDFA.logbin;
    name = genvarname (['DFA' num2str(hp) '_' num2str(lp) 'Hz']); 
    [Signal,SignalInfo] = nbt_GetAmplitudeEnvelope(Signal, SignalInfo, hp, lp, fir_order);
    name = genvarname (['DFA' num2str(hp) '_' num2str(lp) 'Hz']);
    eval([name '= nbt_doDFA(Signal,SignalInfo,FitInterval, CalcInterval, Overlap, 0, 0, logbin)']);
end
nbt_SaveClearObject(name,SignalInfo,SaveDir);
eval(['evalin(''caller'',''clear ' name ''');']);
