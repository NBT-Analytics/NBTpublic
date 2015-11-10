% Start the NBT nbt_gui
%
% Usage:
%   nbt_gui
%
% Inputs:
%
% Outputs:
%
% Example:
%    nbt_gui
%
% References:
%
% See also:
%

%------------------------------------------------------------------------------------
% Originally created by Simon-Shlomo Poil (2011), see NBT website for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) 2011  Simon-Shlomo Poil  (Neuronal Oscillations and Cognition group,
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

function nbt_gui(varargin)

%% check if EEGlab is running
standalone = 1;
if(~isempty(findobj('Tag','EEGLAB')));
    standalone = 0;
end

if(isempty(varargin))
    docked = 0;
else
    docked = 1;
end

try
    hh = findobj('Tag','NBT');
    close(hh)
catch
end
if(isempty(varargin))
    NBT_version = nbt_GetVersion;
    
    %% Make menu
    if(standalone)
    NBTMenu = figure('Units','pixels', 'name',NBT_version,'numbertitle','off', 'Userdata', {[] []},'Tag','NBT','DockControls','off','Position',[390.0000  456.7500 810  88.5000], ...
        'MenuBar','none','NextPlot','new','Resize','off');
   
   %make sure the GUI is onscreen
     NBTMenu=nbt_movegui(NBTMenu);

        try
            nbt_set_name(evalin('base','Signal'),evalin('base','SignalInfo'));
        catch
            nbt_set_name([])
        end
    else
    NBTMenu = figure('Units','pixels', 'name',['Undocked NBT (EEGLAB) ' NBT_version],'numbertitle','off', 'Userdata', {[] []},'Tag','NBT','DockControls','off','Position',[390.0000  456.7500  810  0.5], ...
        'MenuBar','none','NextPlot','new','Resize','off');
        
    end
    
else
    NBTMenu  = uimenu( varargin{1}, 'Label', 'NBT','Tag','NBTinEEGlab');
    standalone = 0;
end

if (standalone)
    %%  NBT standalone GUI
    %define menu
    FileSub = uimenu(NBTMenu,'label', ' &File ');
    uimenu( FileSub, 'label', 'Load NBT Signal', 'callback', '[Signal,SignalInfo,SignalPath]=nbt_load_file;nbt_set_name(Signal, SignalInfo);');
    uimenu( FileSub, 'label', 'Import files into NBT format', 'callback', ['nbt_import_files']);
    uimenu( FileSub, 'label', 'Save NBT Signal', 'callback', ['nbt_SaveSignal(Signal,SignalInfo,[]);']);
    FileSubImportSub = uimenu(FileSub, 'label', ' &Import options');
    uimenu( FileSubImportSub, 'label', 'Import BrainVision Analyzer files', 'callback', 'nbt_import_files([],[], @nbt_loadbv);');
    FileSubExportSub = uimenu(FileSub,'label', ' &Export options');
    uimenu(FileSubExportSub,'label', 'Export to BrainVision Analyzer format', 'callback', 'nbt_EEGLABwrp(@pop_writebva, Signal, SignalInfo, SignalPath, 0);');
    uimenu( FileSubExportSub, 'label', 'Export NBT Signal to a matrix', 'callback', 'ExSignal = nbt_exportSignal(Signal, SignalInfo);');
    uimenu( FileSubExportSub, 'label', 'Export Biomarker [in dev]', 'callback', 'nbt_export_biomarker');
  
    
    VisSub=uimenu( NBTMenu, 'label', ' &Visualization');
    uimenu(VisSub,'label', 'Plot Signals', 'callback', 'nbt_plot(Signal,SignalInfo)');
    uimenu(VisSub,'label', 'Plot time-frequency plot and power spectrum of one channel', 'callback', 'nbt_plot_TF_and_spectrum_one_channel(Signal,SignalInfo)')
    ch_loc = uimenu(VisSub,'label', 'Channel locations');
    uimenu(ch_loc,'label','by name', 'callback','nbt_EEGLABwrp(@nbt_plotchanloc,Signal,SignalInfo, SignalPath,0,''name'');');
    uimenu(ch_loc,'label','by number', 'callback','nbt_EEGLABwrp(@nbt_plotchanloc,Signal,SignalInfo, SignalPath,0,''number'');');
   
    PreProc = uimenu(NBTMenu, 'label', '&Pre-processing');
    uimenu(PreProc,'label', 'Remove artifacts current NBT Signal', 'callback', 'SignalInfo=nbt_get_artifacts(Signal,SignalInfo,SignalPath);');
    uimenu(PreProc,'label', 'Remove artifacts multiple NBT Signals', 'callback', 'nbt_NBTcompute(@nbt_get_artifacts);');
    uimenu(PreProc,'label', 'Find & add bad channel to Info.BadChannels','callback',['[Signal,SignalInfo] = nbt_EEGLABwrp(@nbt_FindBadChannels, Signal, SignalInfo, SignalPath,0);']);
    uimenu(PreProc,'label', 'Re-reference to average reference (exclude bad channels)','callback', ['[Signal, SignalInfo] = nbt_EEGLABwrp(@nbt_ReRef,Signal, SignalInfo, [],0,[]);']);
   ICAsub = uimenu(PreProc, 'label', '&ICA');
    uimenu(ICAsub,'label', 'Run ICA on good channels only','callback',['[Signal, SignalInfo] = nbt_EEGLABwrp2(@nbt_filterbeforeICA, Signal, SignalInfo, SignalPath,0, ''EEG.data = nbt_filter_firHp(EEG.data,0.5,EEG.srate,4);'',4);[Signal, SignalInfo] = nbt_EEGLABwrp2(@nbt_rejectICAcomp, Signal, SignalInfo, SignalPath, 0,''EEG.data = nbt_filter_firHp(EEG.data,0.5,EEG.srate,4);'',4,1);']);
    uimenu(ICAsub,'label', 'Filter ICA components', 'callback',['[Signal, SignalInfo] = nbt_EEGLABwrp(@nbt_rejectICAcomp, Signal, SignalInfo, SignalPath, 0,''EEG.data = nbt_filter_firHp(EEG.data,0.5,EEG.srate,4);'',4,1);'],'Tag','NBTICAfilter');
    VisICAsub = uimenu(ICAsub, 'label', '&Visualize ICA');
    uimenu(VisICAsub, 'label', 'Plot component activations', 'callback', '[Signal, SignalInfo]=nbt_EEGLABwrp2(@pop_eegplot, Signal, SignalInfo, SignalPath,0, 0, 1, 1);')
    uimenu(VisICAsub, 'label', 'Reject component by map', 'callback', '[Signal, SignalInfo]=nbt_EEGLABwrp(@pop_selectcomps, Signal, SignalInfo, SignalPath,1);')
    uimenu(ICAsub, 'label', 'Plot spectra and maps', 'callback', '[Signal, SignalInfo]=nbt_EEGLABwrp(@pop_spectopo, Signal, SignalInfo, SignalPath,0, 0);')
    uimenu(VisICAsub, 'label', 'Component statistics', 'callback', '[Signal, SignalInfo]=nbt_EEGLABwrp(@pop_signalstat, Signal, SignalInfo, SignalPath,0,1);') 
	uimenu(ICAsub,'label', 'Mark ICA components as bad', 'callback','[Signal, SignalInfo] = nbt_EEGLABwrp(@nbt_MarkICBadChannel,Signal,SignalInfo,SignalPath,0);');
   	uimenu(ICAsub,'label', 'Reject filtered ICA components','callback',['[Signal, SignalInfo] = nbt_EEGLABwrp(@nbt_rejectICAcomp,Signal,SignalInfo,SignalPath,0,[],[],2);'],'Enable','off','Tag','NBTICAreject');
    uimenu(ICAsub,'label', 'Auto reject ICA components', 'callback',['[Signal, SignalInfo] = nbt_EEGLABwrp(@nbt_AutoRejectICA,Signal,SignalInfo,SignalPath,0,[],1);'],'Enable','on');
    AutoCleanMenuSub = uimenu(PreProc, 'label', '&Auto Clean functions');
    AutoCleanMenuSetup = uimenu(AutoCleanMenuSub,'label','Setup');
    uimenu(AutoCleanMenuSetup,'label', 'Set Eye Channels','callback','nbt_setEyeCh');
    uimenu(AutoCleanMenuSetup,'label', 'Set Non-EEG Channel', 'callback', 'nbt_setNonEEGCh');
    
    uimenu(AutoCleanMenuSub,'label', 'NBT Auto clean signals','callback', 'nbt_NBTcompute(@nbt_AutoClean)');
    uimenu(AutoCleanMenuSub,'label', 'Run FASTER', 'callback','FASTER_GUI');
    uimenu(AutoCleanMenuSub,'label', 'Auto reject ICA components', 'callback',['[Signal, SignalInfo] = nbt_EEGLABwrp(@nbt_AutoRejectICA,Signal,SignalInfo,SignalPath,0,[],1);'],'Enable','on');
%     uimenu(ICAsub,'label', 'Mark ICA components as bad', 'callback','[Signal, SignalInfo] = nbt_EEGLABwrp(@nbt_MarkICBadChannel,Signal,SignalInfo,SignalPath,0);');
%     
    CompBio = uimenu(NBTMenu, 'label', ' &Compute biomarkers ');
    perSignal = uimenu(CompBio, 'label', ' &For current NBT Signal');
    uimenu(perSignal,'label', 'Amplitudes', 'callback', 'nbt_runAmplitude(Signal,SignalInfo,SignalPath)');
    uimenu(perSignal,'label', 'Correlations', 'callback', 'nbt_runCorrelations(Signal,SignalInfo,SignalPath)');
    uimenu(perSignal,'label', 'DFA', 'callback', ['SettingsDFA = [];nbt_runDFA_gui(Signal, SignalInfo, SignalPath);clear SettingsDFA']);
    uimenu(perSignal,'label', 'Coherence', 'callback',['SettingsCoher = [];nbt_runCoher_gui(Signal, SignalInfo, SignalPath);clear SettingsCoher']);
    uimenu(perSignal,'label', 'Phase Locking Value', 'callback', ['SettingsPLV = [];nbt_runPhaseLocking_gui(Signal, SignalInfo, SignalPath);clear SettingsPLV']);
    
    perFolder = uimenu(CompBio, 'label', ' &For multiple NBT Signals');
    uimenu(perFolder,'label', 'Amplitudes', 'callback', 'nbt_NBTcompute(@nbt_runAmplitude)');
    uimenu(perFolder,'label', 'Amplitude correlations', 'callback', ['AmplitudeCorrSettings=[];nbt_NBTcompute(@nbt_doAmplitudeCorr_gui);clear AmplitudeCorrSettings;']);
    uimenu(perFolder,'label', 'Coherence', 'callback',['SettingsCoher = []; nbt_NBTcompute(@nbt_runCoher_gui);clear SettingsCoher']);
    uimenu(perFolder,'label', 'Correlations', 'callback', 'nbt_NBTcompute(@nbt_runCorrelations)');
    uimenu(perFolder,'label', 'DFA', 'callback',['SettingsDFA = [];nbt_NBTcompute(@nbt_runDFA_gui);clear SettingsDFA']);
    uimenu(perFolder,'label', 'Life- & waitingtime', 'callback', ['OscBurstSettings=[];nbt_NBTcompute(@nbt_doOscBursts_gui);clear OscBurstSettings;']);
    uimenu(perFolder,'label', 'Phase Locking Value', 'callback', ['SettingsPLV = [];nbt_NBTcompute(@nbt_runPhaseLocking_gui); clear SettingsPLV']);
    uimenu(perFolder,'label', 'Spectral biomarkers', 'callback', ['FrequencyBandsInput=[];nbt_NBTcompute(@nbt_runPeakFit);clear FrequencyBandsInput']);
    uimenu(perFolder,'label', 'Cross-Frequency PLV', 'callback', ['FrequencyBands=[];nbt_NBTcompute(@nbt_runCrossPhaseLocking_gui);clear FrequencyBands;']);
    uimenu(CompBio,'label', 'List biomarkers in current signal', 'callback', 'nbt_list_biomarkers(SignalInfo,SignalPath)');
    
    Stat = uimenu(NBTMenu, 'label', ' &Biomarker statistics');
    uimenu(Stat, 'label', ' &Current Signal', 'callback',  ['nbt_statistics_group([SignalPath  SignalInfo.file_name ''.mat''])'  ]);
    uimenu(Stat, 'label', ' &Statistics GUI','callback', 'nbt_selectrunstatistics;');
    
    
    nbt_commonMenu
    
    StartEEGlab = uimenu(NBTMenu, 'label', '&EEGlab','Separator', 'on');
    uimenu(StartEEGlab, 'label', ' Start EEGlab ','callback',['nbt_dockmenu'],'Tag','NBTdock');
    
    movegui(NBTMenu,'center')
    
    try
    if(evalin('base', 'isfield(SignalInfo.Interface.EEG,''NBTEEGtmp'')'))
        hh = findobj('Tag','NBTICAfilter');
        set(hh,'Enable','off');
        hh = findobj('Tag','NBTICAreject');
        set(hh,'Enable','on');
    end
    catch
    end
    
else
    %% Menu in EEGLAB
    FileSub = uimenu(NBTMenu, 'label', 'File');
    uimenu( FileSub, 'label', 'Load NBT Signal', 'callback', ['[ALLEEG EEG CURRENTSET]= eeg_store(ALLEEG, EEG,CURRENTSET);[EEG SignalPath]=nbt_NBTsignal2EEGlab(); [ALLEEG EEG CURRENTSET]= eeg_store(ALLEEG, EEG); eeglab redraw']);
    uimenu( FileSub, 'label', 'Save as NBT Signal', 'callback', ['nbt_EEGlab2NBTsignal(EEG,1);']);
    uimenu( FileSub, 'label', 'Import files into NBT format', 'callback', ['nbt_import_files;']);
    FileSubImportSub = uimenu(FileSub, 'label', ' &Import options');
    uimenu( FileSubImportSub, 'label', 'Import BrainVision Analyzer files', 'callback', 'nbt_import_files([],[], @nbt_loadbv);');
    FileSubExportSub = uimenu(FileSub,'label', ' &Export options');
    uimenu(FileSubExportSub,'label', 'Export to BrainVision Analyzer format', 'callback', 'pop_writebva(EEG);');
    
    
    %     uimenu( FileSub, 'label', 'Read EGI .raw', 'callback', ['[ALLEEG EEG CURRENTSET]= eeg_store(ALLEEG, EEG,CURRENTSET);EEG=nbt_ReadEGIraw(0); [ALLEEG EEG CURRENTSET]= eeg_store(ALLEEG, EEG); eeglab redraw']);
    %     uimenu( FileSub, 'label', 'Read EGI .raw segment', 'callback', ['[ALLEEG EEG CURRENTSET]= eeg_store(ALLEEG, EEG,CURRENTSET);EEG=nbt_ReadEGIraw(1); [ALLEEG EEG CURRENTSET]= eeg_store(ALLEEG, EEG); eeglab redraw']);
    
    PreProc = uimenu(NBTMenu, 'label', '&Pre-processing tools');
    uimenu(PreProc,'label', 'Find & add bad channel to Info.BadChannels','callback',['[ALLEEG EEG CURRENTSET]= eeg_store(ALLEEG, EEG,CURRENTSET);EEG=nbt_FindBadChannels(EEG);[ALLEEG EEG CURRENTSET]= eeg_store(ALLEEG, EEG,CURRENTSET); eeglab redraw']);
    uimenu(PreProc,'label', 'Re-reference to average reference (exclude bad channels)','callback', ['[ALLEEG EEG CURRENTSET]= eeg_store(ALLEEG, EEG,CURRENTSET); EEG=nbt_AverageReference(EEG);[ALLEEG EEG CURRENTSET]= eeg_store(ALLEEG, EEG,CURRENTSET); eeglab redraw']);
    ICAsub = uimenu(PreProc, 'label', '&ICA');
    uimenu(ICAsub,'label', 'Run ICA on good channels only','callback',['[ALLEEG EEG CURRENTSET]= eeg_store(ALLEEG, EEG,CURRENTSET);EEG = nbt_filterbeforeICA(EEG, ''EEG.data = nbt_filter_firHp(EEG.data,0.5,EEG.srate,4);'',4);[ALLEEG EEG CURRENTSET]= eeg_store(ALLEEG, EEG,CURRENTSET); eeglab redraw']);
    uimenu(ICAsub,'label', 'Filter ICA components', 'callback',['EEG = nbt_rejectICAcomp(EEG,''EEG.data = nbt_filter_firHp(EEG.data,0.5,EEG.srate,4);'',4,1);'],'Tag','NBTICAfilter');
    uimenu(ICAsub,'label', 'Reject filtered ICA components','callback',['EEG = nbt_rejectICAcomp(EEG,[],[],2);[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);'],'Enable','off','Tag','NBTICAreject');
    uimenu(ICAsub,'label', 'Auto reject ICA components', 'callback',['EEG  = nbt_AutoRejectICA(EEG,[],1);[ALLEEG, EEG] = eeg_store(ALLEEG, EEG,CURRENTSET);'],'Enable','on');
    uimenu(ICAsub,'label', 'Mark ICA components as bad', 'callback','EEG=nbt_MarkICBadChannel(EEG);');
    
    VisSub=uimenu( NBTMenu, 'label', '&Visualization tools');
    uimenu(VisSub,'label', 'Plot Signals', 'callback', 'nbt_eegplot(EEG)');
    uimenu(VisSub,'label', 'Plot bad channels', 'callback', 'nbt_plotBadChannels(EEG)');
    
    Stat = uimenu(NBTMenu, 'label', '&Biomarker statistics');
    uimenu(Stat, 'label', ' &Statistics GUI','callback', 'nbt_selectrunstatistics;');
    
    
    nbt_commonMenu
    
    MenuTools = uimenu( NBTMenu, 'label', 'Menu tools' ,'Separator', 'on');
    uimenu( MenuTools, 'label', 'Close EEGLAB, open NBT', 'callback', ['nbt_closeEEGLAB']);
    if(docked)
        uimenu(MenuTools, 'label', 'Undock NBT','callback',['nbt_dockmenu'],'Tag','NBTdock');
    else
        uimenu(MenuTools, 'label', 'Dock NBT','callback',['nbt_dockmenu'],'Tag','NBTdock');
    end
end


    function nbt_commonMenu %nested function
        HelpMenu = uimenu(NBTMenu, 'label', '&Help');
        uimenu(HelpMenu, 'label','NBT wiki', 'callback','web https://www.nbtwiki.net -browser');
        uimenu(HelpMenu, 'label','Tutorials', 'callback','web https://www.nbtwiki.net/doku.php?id=tutorial:start -browser');
        uimenu(HelpMenu, 'label','Documentation', 'callback','web https://www.nbtwiki.net/doku.php?id=nbtdocumentation:start -browser');
        uimenu(HelpMenu, 'label','Get involved', 'callback','web https://www.nbtwiki.net/doku.php?id=nbtdev:start -browser');
        uimenu(HelpMenu, 'label','Copyrights','Separator', 'on',  'callback','web https://www.nbtwiki.net/doku.php?id=copyrights -browser');
        uimenu(HelpMenu, 'label', 'About NBT','Separator', 'on', 'callback',['help NBT']);
    end


end
