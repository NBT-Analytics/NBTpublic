% Copyright (C) 2012  Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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
%

% ChangeLog - see version control log for details
% <date> - Version <#> - <text>

function nbt_NBTRunAnalysisAll(varargin)
disp('version 7')
script = NBTwrapper();
nbt_NBTcomputeInfo(script,'AutoICASignal',pwd,pwd)
end


function NBTfunction_handle = NBTwrapper()

theta_hp = 4;
theta_lp = 8;
theta_fo = 2/4;

alpha_hp = 8;
alpha_lp = 13;
alpha_fo = 2/8;

beta_hp = 13;
beta_lp = 30;
beta_fo = 2/13;

DFAshortFit = 3;
DFAlongFit = 20;
DFAshortCalc = 1;
DFAlongCalc = 25;
DFA_Overlap = 0.5;
DFA_Plot = 0;
ChannelToPlot = 1;

    function NBTscript(Signal, SignalInfo, SaveDir)
% 
% % % %% Theta frequency
%      
%          [AmplitudeEnvelope, AmplitudeEnvelopeInfo] = nbt_GetAmplitudeEnvelope(Signal,SignalInfo,theta_hp,theta_lp,theta_fo);
% 
%      %    [DFAobject,DFA_exp] = nbt_doDFA(Signal, InfoObject, FitInterval, CalcInterval, DFA_Overlap, DFA_Plot, ChannelToPlot, res_logbin); 
%          
%          [DFA_theta,DFA_exp] = nbt_doDFA(AmplitudeEnvelope, AmplitudeEnvelopeInfo, [DFAshortFit DFAlongFit], [DFAshortCalc DFAlongCalc], DFA_Overlap, DFA_Plot, ChannelToPlot, []);
%          nbt_SaveClearObject('DFA_theta', SignalInfo, SaveDir)   
%          
% % % %% Alpha       
%         
%           [AmplitudeEnvelope, AmplitudeEnvelopeInfo]= nbt_GetAmplitudeEnvelope(Signal,SignalInfo,alpha_hp,alpha_lp,alpha_fo);
%           
%          [DFA_alpha,DFA_exp] = nbt_doDFA(AmplitudeEnvelope, AmplitudeEnvelopeInfo, [DFAshortFit DFAlongFit], [DFAshortCalc DFAlongCalc], DFA_Overlap, DFA_Plot, ChannelToPlot, []);
%          nbt_SaveClearObject('DFA_alpha', SignalInfo, SaveDir)
%        
% % % %% Beta 
% 
%           [AmplitudeEnvelope, AmplitudeEnvelopeInfo] = nbt_GetAmplitudeEnvelope(Signal,SignalInfo,beta_hp,beta_lp,beta_fo);
%          
%          [DFA_beta,DFA_exp] = nbt_doDFA( AmplitudeEnvelope, AmplitudeEnvelopeInfo, [DFAshortFit DFAlongFit], [DFAshortCalc DFAlongCalc], DFA_Overlap, DFA_Plot, ChannelToPlot, []);
%          nbt_SaveClearObject('DFA_beta', SignalInfo, SaveDir,1)    
         
%          [amplitude_1_4_Hz amplitude_4_8_Hz amplitude_8_13_Hz amplitude_13_30_Hz amplitude_30_45_Hz amplitude_1_4_Hz_Normalized amplitude_4_8_Hz_Normalized amplitude_8_13_Hz_Normalized  ...
%           amplitude_13_30_Hz_Normalized amplitude_30_45_Hz_Normalized] = nbt_doAmplitude(Signal,SignalInfo);
%      
%           nbt_SaveClearObject('amplitude_4_8_Hz',SignalInfo,SaveDir);
%           nbt_SaveClearObject('amplitude_8_13_Hz',SignalInfo,SaveDir);
%           nbt_SaveClearObject('amplitude_13_30_Hz',SignalInfo,SaveDir);
%          
%           nbt_SaveClearObject('amplitude_4_8_Hz_Normalized',SignalInfo,SaveDir);
%           nbt_SaveClearObject('amplitude_8_13_Hz_Normalized',SignalInfo,SaveDir);          
%           nbt_SaveClearObject('amplitude_13_30_Hz_Normalized',SignalInfo,SaveDir);
          
          nbt_importARSQStudent(SignalInfo.file_name, SignalInfo, SaveDir) %requies Beviouralbiomarkers.xls
          nbt_UpdateFromLogBook(Signal,SignalInfo,pwd,'NBTLogbook.xls','RawSignal')
         
    end

NBTfunction_handle = @NBTscript;
end


function ICASignalInfo=nbt_LoadNewChanloc()
load NewChanloc.mat
end
