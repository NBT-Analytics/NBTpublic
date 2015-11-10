%   nbt_NBTcompute(NBTfunction_handle,SignalName,LoadDir,SaveDir, SignalLoadHandle,SignalFileExt)
%   loops trough LoadDir and subfolders, and applies the function NBTfunction_handle to all files,
%   stores results in biomarker objects in analysis files. Skips NBT Info and
%   analysis files. Other not .mat files can be present in target folder, if you
%   specify SignalFileExt to be '.mat'.
%
% Inputs:
% -NBTfunction_handle = handle to function that you want to apply to your
%   NBT signals. See nbt_analysis_template for example.
% -SignalName = name of the Signal you want to use (sometimes there are several data matrices per file, in that case choose a name, otherwise
%   choose 'Signal.
% -LoadDir = full path to directory where your files are.
%
% optional:
% -SaveDir: if the directory you want to save the analysis files is
%   different than the LoadDir,specify it here (full path)
% -SignalLoadHandle = ?Simon?
% -SignalFileExt = extention of files you want to use

%--------------------------------------------------------------------------
% Copyright (C) 2008  Neuronal Oscillations and Cognition group, 
% Department of Integrative Neurophysiology, Center for Neurogenomics and 
% Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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
%--------------------------------------------------------------------------

function nbt_NBTcomputeInfo(NBTfunction_handle,SignalName,LoadDir,SaveDir, SignalLoadHandle,SignalFileExt, varargin)


%--- init Setup


if(~exist('SignalName','var'))
    SignalName = input('Which Signal do you want to use? (e.g., Signal, CLEANSignal, ICASignal) ','s');
else
    if(isempty(SignalName))
      SignalName = input('Which Signal do you want to use? ','s');  
    end
end
% specify folder containing files
if(~exist('LoadDir','var'))
        LoadDir = uigetdir('C:\','Select folder with NBT signals');
else
    if (isempty(LoadDir))
        LoadDir = uigetdir('C:\','Select folder with NBT signals');
    end
end

if(~exist('SaveDir','var'))
    SaveDir = LoadDir;
else
    if (isempty(SaveDir))
        SaveDir = LoadDir;
    end
end
%inputcheck
if(~exist('SignalFileExt','var'))
    SignalFileExt = 'mat';
    SignalLoadHandle = [];
else
    if(isempty(SignalFileExt))
        SignalFileExt = 'mat';
        SignalLoadHandle = [];
    end
end

%--- looping through all files in folder
d = dir(LoadDir);
%--- for files copied from a mac
startindex = 0;
for i = 1:length(d)
    if  strcmp(d(i).name(1),'.') || strcmp(d(i).name(1:2),'..') || strcmp(d(i).name(1:2),'._') 
        startindex = i+1;
    end
end

%---
for j= startindex:length(d)
  %  if (d(j).isdir)
  %      nbt_NBTcompute(NBTfunction_handle,SignalName, [SaveDir '/' d(j).name], [LoadDir '/' d(j).name], SignalLoadHandle,SignalFileExt,varargin)
  %  else
  if(~d(j).isdir)
        if(~isempty(strfind(d(j).name,SignalFileExt)));    %Skip files with extensions other than wanted
           % if isempty(strfind(d(j).name,'info'));         %Skip Info files
                if isempty(strfind(d(j).name,'analysis')); %Skip analysis files
                    disp(d(j).name)
                    %--- load Signal and SignalInfo
                    if(~isempty(SignalLoadHandle))     %load using SignalLoadHandle
                        EEG = SignalLoadHandle([d(j).name]);
                        EEG = eeg_checkset(EEG);
                        Signal = EEG.data';
                        try % load info_object
                            load ([d(j).name])
                            SignalInfo = eval([SignalName 'Info']);
                        catch
                            SignalInfo = nbt_CreateInfoObject(d(j).name,SignalFileExt,EEG.srate);
                        end
                    else % load NBTSignal file
                        clear([SignalName])
                        clear([SignalName 'Info'])
                      %  load ([LoadDir,'/',d(j).name],SignalName)
                        try
                        load ([LoadDir,'/',d(j).name(1:end-4),'_info.mat'],[SignalName,'Info'])
                        catch
                            load ([LoadDir,'/',d(j).name],[SignalName 'Info'])
                        end
                        
                        
                        %%% insure old signal is deleted!!! (old format compatibility)
                        clear Signal
                        s=whos;
                        for ii=1:length(s)
                            if(strcmp(s(ii).name,[SignalName 'Info']))
                                Signal = [];
                      %          Signal = eval(SignalName);
                                try
                                    SignalInfo = eval([SignalName 'Info']);
                                catch
                                    try
                                        load([SignalInfo.file_name,'_info.mat'])
                                        SignalInfo = eval([SignalName 'Info']);
                                    catch %ok create the info object
                                        SignalInfo = nbt_CreateInfoObject(d(j).name, 'mat', Signal.Fs, Signal);
                                    end
                                end
                            end
                        end
                    end
                    
                    %--- apply the function to the signal:
                    
                    if(exist('Signal','var'))                 
                        %--- Run analysis
                        %try
                      if(isempty(varargin))
                            NBTfunction_handle(double(Signal(:,:)), SignalInfo,SaveDir);
                      else

                           NBTfunction_handle(double(Signal(:,:)), SignalInfo,SaveDir,varargin{:});
                           
                      end
                        %catch NBTcomputeErr
                         %   warning(['nbt_NBTcompute: Error in analysis, skipping file',LoadDir,'/',d(j).name])
                          %  NBTcomputeErr
                       % end
                    else
                        warning(['No Signal in file: ',LoadDir,'/',d(j).name])
                    end
                end
            end
        end
    end
end
