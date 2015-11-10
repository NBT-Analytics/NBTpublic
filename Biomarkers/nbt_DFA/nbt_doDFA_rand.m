% [FitInterval] = nbt_doDFA_rand(DFAobject, Nrand, FitInterval0, CalcInterval,Fs); allows the user to
% select end test a specific fitting interval
%
% Usage:
%  FitInterval] = nbt_doDFA_rand(DFAobject, Nrand, FitInterval0,
%  CalcInterval,Fs);
%
% Inputs:
%       DFAobject, 
%       Nrand, 
%       FitInterval0, 
%       CalcInterval, 
%       Overlap, 
%       logbin,
%       Fs
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


function [FitInterval] = nbt_doDFA_rand(DFAobject, Nrand, FitInterval0, CalcInterval,Fs);


[x y] = ginput(2);
FitInterval = [10^x(1) 10^x(2)];
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
cla
hold on
plot(log10(DFA_x(DFA_SmallTimeFit_LogSample:DFA_LargeTimeFit_LogSample)/Fs),log10(DFA_y(DFA_SmallTimeFit_LogSample:DFA_LargeTimeFit_LogSample)),'ro')
LineHandle=lsline;
plot(log10(DFA_x(DFA_SmallTime_LogSample:DFA_LargeTime_LogSample)/Fs),log10(DFA_y(DFA_SmallTime_LogSample:DFA_LargeTime_LogSample)),'k.')
grid on
axis([log10(min(DFA_x/Fs))-0.1 log10(max(DFA_x/Fs))+0.1 log10(min(DFA_y(3:end)))-0.1 log10(max(DFA_y))+0.1])
plot(ones(size(DFA_y))*log10(FitInterval(1)),log10(DFA_y),'r--')
plot(ones(size(DFA_y))*log10(FitInterval(2)),log10(DFA_y),'r--')
plot(ones(size(DFA_y))*log10(FitInterval0(1)),log10(DFA_y),'b--')
plot(ones(size(DFA_y))*log10(FitInterval0(2)),log10(DFA_y),'b--')
xlabel('log_{10}(time), [Seconds]','Fontsize',12)
ylabel('log_{10} F(time)','Fontsize',12)
title(['DFA-exp= ' num2str(DFA_exp) ' \pm ' num2str(DFA_exp_std)],'Fontsize',12)   
confirm = 'n';
confirm = lower(input([ 'Do you confirm the fitting interval with mean DFA-exp= ' num2str(DFA_exp) ' \pm ' num2str(DFA_exp_std) '? Y/N [Y]: '] , 's'));

% repeat the previous sequency until the user is sadisfact with his choise

while confirm ~= 'y'

    [x y] = ginput(2);
    FitInterval = [10^x(1) 10^x(2)];
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
cla
hold on
plot(log10(DFA_x(DFA_SmallTimeFit_LogSample:DFA_LargeTimeFit_LogSample)/Fs),log10(DFA_y(DFA_SmallTimeFit_LogSample:DFA_LargeTimeFit_LogSample)),'ro')
LineHandle=lsline;
plot(log10(DFA_x(DFA_SmallTime_LogSample:DFA_LargeTime_LogSample)/Fs),log10(DFA_y(DFA_SmallTime_LogSample:DFA_LargeTime_LogSample)),'k.')
grid on
axis([log10(min(DFA_x/Fs))-0.1 log10(max(DFA_x/Fs))+0.1 log10(min(DFA_y(3:end)))-0.1 log10(max(DFA_y))+0.1])
plot(ones(size(DFA_y))*log10(FitInterval(1)),log10(DFA_y),'r--')
plot(ones(size(DFA_y))*log10(FitInterval(2)),log10(DFA_y),'r--')
plot(ones(size(DFA_y))*log10(FitInterval0(1)),log10(DFA_y),'b--')
plot(ones(size(DFA_y))*log10(FitInterval0(2)),log10(DFA_y),'b--')
xlabel('log_{10}(time), [Seconds]','Fontsize',12)
ylabel('log_{10} F(time)','Fontsize',12)
title(['DFA-exp= ' num2str(DFA_exp) ' \pm ' num2str(DFA_exp_std)],'Fontsize',12)     
confirm = lower(input([ 'Do you confirm the fitting interval with mean DFA-exp= ' num2str(DFA_exp) ' \pm ' num2str(DFA_exp_std) '? Y/N [Y]: '] , 's'));

end

    


