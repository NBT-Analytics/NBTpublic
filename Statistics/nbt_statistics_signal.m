% Compute and visualize statistics of a biomarker of one signal
%
% Usage: nbt_statistics_signal(directory,biomarker,statistic,plotting)
%
% Inputs:
% directory = path to directoy with NBT files
% biomarker = name of biomarker, as it is written in the analysis file
% statistic = 'mean' (default) or 'median'
% plotting = 0 (default) or 1. If plotting =1, a pdf will be generated with a plot of the statistics
%
% For example:
%
% References:
%
% See also:
% nbt_statistics_conditions, nbt_statistics_groups

%------------------------------------------------------------------------------------
% Originally created by Rick Jansen (2010), see NBT website for current email
% address
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
% ---------------------------------------------------------------------------------------
function nbt_statistics_signal(varargin)

%% assign fields

fontsize=8;
P=varargin;
nargs=length(P);

if (nargs<1 | isempty(P{1}))[path]=uigetfile([],'select NBT file'); else path = P{1}; end;


if (nargs<2 | isempty(P{2}))
    % get biomarker
    
    if(isdir(path))
        d=dir(path);
        %--- for files copied from a mac
        startindex = 0;
        for i = 1:length(d)
            if  strcmp(d(i).name(1),'.') || strcmp(d(i).name(1:2),'..') || strcmp(d(i).name(1:2),'._')
                startindex = i+1;
            end
        end
        %---
        for i=startindex:length(d)
            if ~isempty(findstr('analysis',d(i).name))
                [biomarker_objects,biomarkers] = nbt_ExtractBiomarkers([path,'/', d(i).name]);
                break
            end
        end
        
    else
        [biomarker_objects,biomarkers] = nbt_ExtractBiomarkers([path(1:end-4) '_analysis.mat']);
    end
    
    [selection,ok]=listdlg('liststring',biomarker_objects, 'SelectionMode','single', 'ListSize',[250 300],'PromptString','Select biomarker (must have 129 values!)');
    biomarker_object=biomarker_objects{selection};
    [selection1,ok]=listdlg('liststring',biomarkers{selection},'SelectionMode','single', 'ListSize',[250 300],'PromptString','Select biomarker (must have 129 values!)');
    biomarker=strcat(biomarker_object,'.',biomarkers{selection}(selection1));
    biomarker=inputdlg('edit biomarker name?','',1,biomarker);
    biomarker=cell2mat(biomarker);
else biomarker = P{2};
end

c1_regions=[];
if(isdir(path))
    SignalInfo=nbt_getInfoObject(path,'Signal'); % get one Info file for locations channels, in case of EEG data
else
    SignalInfo=load([path(1:end-4) '_info.mat']);
    flds = fieldnames(SignalInfo);
    if length(flds) == 1
        SignalInfo = eval(['SignalInfo.',flds{1}]);
    else
        [selfld,ok]=listdlg('liststring',flds, 'SelectionMode','single', 'ListSize',[250 300],'PromptString','Select NBT Info Object');
        SignalInfo = eval(['SignalInfo.',flds{selfld}]);
    end
end
disp(' ')
disp('Command window code:')
disp(['nbt_statistics_signal(',char(39),path,char(39),',',char(39),biomarker,char(39),');'])
disp(' ')

%% get biomarkers from analysis files
if(isdir(path))
    [c1,s1,p1,unit]=nbt_load_analysis(path,[],biomarker,@nbt_get_biomarker,[],[],[]);
else
    [c1,unit] = nbt_get_biomarker([path(1:end-4) '_analysis.mat'],biomarker,[]);
end

number_of_biomarkers=size(c1,1);
number_of_subjects=size(c1,2);

% c1 contains the biomarkers (129 - length vector)

%% get subregions in case of 129-channel EEG data

if (isfield(SignalInfo.Interface,'EEG') && number_of_biomarkers==129)
    for i=1:number_of_subjects
        c1_regions(:,i) = nbt_get_regions(c1(:,i),[],SignalInfo);
    end
end
% c1_regions contains the biomarker averaged within the six subregions

%%        get figure handle
done=0;
figHandles = findobj('Type','figure');
for i=1:length(figHandles)
    if strcmp(get(figHandles(i),'Tag'),'stat_sig')
        figure(figHandles(i))
        done=1;
    end
end
if ~done
    figure()
    set(gcf,'Tag','stat_sig');
end
set(gcf,'name','NBT: signal statistics EEG','numbertitle','off');
clf
set(gcf,'position',[215         546        1280         431])

%% color scales:
vmax=max(c1);
vmin=min(c1);
rmax=max(c1_regions);
rmin=min(c1_regions);
cmax = max([vmax, rmax]);
cmin = min([vmin, rmin]);

%% plot grand average per channel:
xa=-2;
subplot(2,3,4)
topoplot(c1',SignalInfo.Interface.EEG.chanlocs,'headrad','rim');
cb = colorbar('westoutside');
set(get(cb,'title'),'String',unit);
caxis([cmin,cmax])
set(gca,'fontsize',fontsize)

subplot(2,3,5)
nbt_plot_EEG_channels(c1,cmin,cmax,SignalInfo.Interface.EEG.chanlocs)
axis equal
cb = colorbar('westoutside');
set(get(cb,'title'),'String',unit);
caxis([cmin,cmax])
set(gca,'fontsize',fontsize)

%% in case of 129-channel EEG data, we also plot the sub-regions:
if isfield(SignalInfo.Interface,'EEG') && number_of_biomarkers==129
    %% plot grand average subregions
    subplot(2,3,6)
    nbt_plot_subregions(c1_regions,1,cmin,cmax)
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String',unit);
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)
end

%%                            add Info to plot
y=0.1;
subplot(2,3,1)
text(0.5,y,'Interpolated topoplot','horizontalalignment','center')
axis off
subplot(2,3,3);text(0.5,y,'Mean per subregion','horizontalalignment','center')
axis off
subplot(2,3,2)
text(0.5,y,'Actual channels','horizontalalignment','center')
axis off
subplot(2,3,2)
title(['Statistics for ',regexprep(biomarker,'_',' '),' in ', SignalInfo.file_name],'interpreter','none');

