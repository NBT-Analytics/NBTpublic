% nbt_selectrunstatistics - this function is part of the statistics GUI, it allows
% to select specific statistical test and run the test for
% biomarkers/groups/channels or regions
%
% Usage:
%  G = nbt_selectrunstatistics(G);
%
% Inputs:
%   G is the struct variable containing informations on the selected groups
%      i.e.:  G(1).fileslist contains information on the files of Group 1
%           G(1).biomarkerslist list of selected biomarkers for the
%           statistics
%           G(1).chansregs list of the channels and the regions relected
% Outputs:
%  G updated version of the input,
%
%
% Example:
%   G = nbt_selectrunstatistics(G);
%
% References:
%
% See also:
%  nbt_load_analysis,
%  nbt_run_stat_group, nbt_run_stat_2groups_or_2conditions,
%  nbt_plot_2conditions_topo, nbt_statisticslog

%------------------------------------------------------------------------------------
% Originally created by Giuseppina Schiavone (2012), see NBT website (http://www.nbtwiki.net) for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
% Resturcture of GUI layout : Simon-Shlomo Poil, 2012-2013
%
% Copyright (C) 2012  Giuseppina Schiavone  (Neuronal Oscillations and Cognition group,
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
% --------------


function nbt_selectrunstatistics
global questions
global G

try
    G = evalin('base','G');
catch
    G = [];
end
if (isempty(G))
    nbt_definegroups;
end
nbt_selectbiomarkers;


G = evalin('base','G');

%----------------------
% First we build the Interface
%----------------------
StatSelection = figure('Units','pixels', 'name','NBT: Select Statistics' ,'numbertitle','off','Position',[1  1  625  750],...
    'MenuBar','none','NextPlot','new','Resize','on');
% fit figure to screen, adapt to screen resolution
% nbt_movegui(StatSelection); % messes up the figure dimensions!

% This loads the statistical tests- these needs to be set in nbt_statisticslog.
statindex = 1;
while (~isempty(nbt_statisticslog(statindex)))
    s = nbt_statisticslog(statindex);
    statList{statindex} = s.statfuncname;
    statindex = statindex + 1;
end
hp3 = uipanel(StatSelection,'Title','SELECT TEST','FontSize',10,'Units','pixels','Position',[10 520 360 200],'BackgroundColor','w','fontweight','bold');
ListStat = uicontrol(hp3,'Units', 'pixels','style','listbox','Max',1,'Units', 'pixels','Position',[5 5 350 180],'fontsize',10,'String',statList,'BackgroundColor','w');
% biomarkers
hp2 = uipanel(StatSelection,'Title','SELECT BIOMARKER(S)','FontSize',10,'Units','pixels','Position',[10 300 360 200],'BackgroundColor','w','fontweight','bold');

ListBiom = uicontrol(hp2,'Units', 'pixels','style','listbox','Max',length(G(1).biomarkerslist),'Units', 'pixels','Position',[5 5 350 180],'fontsize',10,'String',G(1).biomarkerslist,'BackgroundColor','w');

% regions or channels
reglist{1} = 'Channels';
reglist{2} = 'Regions';
reglist{3} = 'Match channels';

hp = uipanel(StatSelection,'Title','SELECT CHANNELS OR REGIONS','FontSize',10,'Units','pixels','Position',[10 220 360 70],'BackgroundColor','w','fontweight','bold');
ListRegion = uicontrol(hp,'Units', 'pixels','style','listbox','Min',0,'Max',2,'Units', 'pixels','Position',[5 5 350 50],'fontsize',10,'String',reglist,'BackgroundColor','w','tag','ListRegion');

% channel selection button
ChannelsButton = uicontrol(StatSelection,'Style','pushbutton','String','Select Channels and Regions','Position',[400 240 200 30],'fontsize',12);%,'callback',@ChannelsButton_Callback);
set(ChannelsButton,'callback','nbt_selectchansregs;');

% select Group

for i = 1:length(G)
    gname = G(i).fileslist(1).group_name;
    
    groupList{i} = ['Group ' num2str(i) ' : ' gname];
end

hp4 = uipanel(StatSelection,'Title','SELECT GROUP(S)','FontSize',10,'Units','pixels','Position',[10 110 360 100],'BackgroundColor','w','fontweight','bold');
ListGroup = uicontrol(hp4,'Units', 'pixels','style','listbox','Max',length(groupList),'Units', 'pixels','Position',[5 5 350 80],'fontsize',10,'String',groupList,'BackgroundColor','w','tag','ListGroup');
% run test
RunButton = uicontrol(StatSelection,'Style','pushbutton','String','Run Test','Position',[500 5 100 50],'fontsize',10,'callback',@get_settings, 'Tag', 'NBTstatRunButton');
% join button
joinButton = uicontrol(StatSelection,'Style','pushbutton','String','Join Groups','Position',[5 70 70 30],'fontsize',8,'callback',@join_groups);
% create difference group button
groupdiffButton = uicontrol(StatSelection,'Style','pushbutton','String','Difference Group','Position',[280 70 100 30],'fontsize',8,'callback',@diff_group);
% create difference group button
definegroupButton = uicontrol(StatSelection,'Style','pushbutton','String','Define New Group(s)','Position',[400 140 150 30],'fontsize',12,'callback',@define_new_groups);
% create difference group button
addgroupButton = uicontrol(StatSelection,'Style','pushbutton','String','Update Groups List','Position',[130 40 110 30],'fontsize',8,'callback',@add_new_groups);
% remove group(s)
removeGroupButton = uicontrol(StatSelection,'Style','pushbutton','String','Remove Group(s)','Position',[80 70 100 30],'fontsize',8,'callback',@remove_groups);
% save group(s)
saveGroupButton = uicontrol(StatSelection,'Style','pushbutton','String','Save Group(s)','Position',[185 70 90 30],'fontsize',8,'callback',@save_groups);
% compare bioms
CompareBio = uicontrol(StatSelection,'Style','pushbutton','String','Compare biomarkers','Position',[5 10 150 30],'fontsize',8,'callback','nbt_comparebiomarkers(G)');
PrintVisualize = uicontrol(StatSelection,'Style','pushbutton','String','NBT Print Visualizaiton','Position',[230 10 150 30],'fontsize',8,'callback',@Print_Visualize);

% move up
upButton = uicontrol(StatSelection,'Style','pushbutton','String','/\','Position',[370 165 25 25],'fontsize',8,'callback',@up_group);
% move down
downButton = uicontrol(StatSelection,'Style','pushbutton','String','\/','Position',[370 140 25 25],'fontsize',8,'callback',@down_group);


    function get_settings(d1,d2) %call at click on Run button
        disp('Waiting for statistics ...')
        HrunStat = findobj( 'Tag', 'NBTstatRunButton');
        set(HrunStat, 'String', 'Calculating..')
        drawnow
        %%----------------------
        %% get settings
        %%----------------------
        % --- get statistics test (one)
        statTest = get(ListStat,'Value');
        nameTest = get(ListStat,'String');
        nameTest = nameTest(statTest);
        % --- get channels or regions (one)
        regs_or_chans_index = get(ListRegion,'Value');
        regs_or_chans_name = get(ListRegion,'String');
        regs_or_chans_name = regs_or_chans_name(regs_or_chans_index);
        % --- get biomarkers (one or more)
        bioms_ind = get(ListBiom,'Value');
        bioms_name = get(ListBiom,'String');
        bioms_name = bioms_name(bioms_ind);
        % --- get group (one or more)
        group_ind = get(ListGroup,'Value');
        group_name = get(ListGroup,'String');
        group_name = group_name(group_ind);
        
        %         save bioms_name bioms_name
        %         clear bioms_name
        %         load bioms_name
        
        %% ---- adding grand average hack in here - let's structure better in the new format
        if(statTest == 1) % Grand average PSD
            figure; hold on;
            nbt_plotGrandAveragePSD(G(group_ind(1)).fileslist,G(group_ind(1)).chansregs.channel_nr,'b');
            nbt_plotGrandAveragePSD(G(group_ind(2)).fileslist,G(group_ind(2)).chansregs.channel_nr,'r');
            
            return %just breaking here..
        end
         
        
        %% ----------------------
        % within a group
        %----------------------
        if length(group_ind) == 1
            G = evalin('base','G');
            Group = G(group_ind);
            try
                NCHANNELS = length(Group.chansregs.chanloc);
            catch
                error('You need to define which channels to analyze first, click Select Channels and Regions')
            end
            
            % load biomarker data from analysis files
            path = Group.fileslist.path;
            n_files = length(Group.fileslist);
            %----------------------
            % Load biomarkers
            %----------------------
            [B_values_cell,Sub,Proj,unit] = nbt_checkif_groupdiff(Group,G,n_files,bioms_name,path);
            
            %----------------------
            % check biomarkers dimensionality
            %----------------------
            [dimens_diff,biomPerChans,IndexbiomNotPerChans] = nbt_dimension_check(B_values_cell,NCHANNELS);
            
            % load statistical test
            s = nbt_statisticslog(statTest);
            
            %----------------------
            % biomarkers for channels or regions
            %----------------------
            if ~isempty(biomPerChans)
                B_values = nbt_extractBiomPerChans(biomPerChans,B_values_cell);
                % select channels or regions
                if strcmp(regs_or_chans_name,'Channels')
                    chans = Group.chansregs.channel_nr;
                    B_gebruik(:,:,:) = B_values(chans,:,:);
                    regs = [];
                elseif strcmp(regs_or_chans_name,'Regions')
                    regions = Group.chansregs.listregdata;
                    for j = 1:n_files % subject
                        for l = 1:length(bioms_name) % biomarker
                            B = B_values(:,j,l);
                            B_gebruik(:,j,l) = get_regions(B,regions,s);
                        end
                    end
                    regs = regions;
                elseif strcmp(regs_or_chans_name,'Match channels');
                    GrpMatchId = input('Please write group number to match: ');
                    GroupM = G(GrpMatchId);
                    ChannelsToUse = GroupM.chansregs.channel_nr;
                    
                    %Match values in Group2 to the chanlocs in Group 1
                    for mm=1:size(B_values,3)
                        NewValuesB(:,:,mm) = nbt_reshape2Chanlocs(B_values(:,:,mm), Group.chansregs.chanloc, GroupM.chansregs.chanloc) ;
                    end
                    B_gebruik(:,:,:) = NewValuesB(ChannelsToUse,:,:);
                    regs =[];
                end
                
                clear B B_values
                
                %----------------------
                % Run Statistics
                %----------------------
                for i = 1:length(bioms_name(biomPerChans))
                    bioms_name2 = bioms_name(biomPerChans);
                    disp(['Run ', s.statfuncname, ' for ', bioms_name2{i}])
                    B(:,:) = B_gebruik(:,:,i);
                    %             unit{1,i} = 'tmpset';
                    [stat_results(i)] = nbt_run_stat_group(Group,B,s,bioms_name2{i},regs,unit{1,i});
                end
                
                try
                    B=evalin('base','stat_results');
                    stat_results=appendStruct(stat_results,B);
                    stat_results.update=now;
                catch
                end
                assignin('base','stat_results',stat_results);
                assignin('base','stat_update',now);
                clear stat_results
                
            end
            %----------------------
            % biomarkers with different dimensionality
            %----------------------
            
            if ~isempty(IndexbiomNotPerChans)
                clear B
                %         stat_results = evalin('base','stat_results');
                for dim = 1:length(IndexbiomNotPerChans)
                    dimBio = IndexbiomNotPerChans{dim};
                    dim_B_values(:,:,:) = nbt_extractBiomNotPerChans(dimBio,B_values_cell);
                    % load statistical test
                    s = nbt_statisticslog(statTest);
                    %----------------------
                    % Run Statistics
                    %----------------------
                    for dim2 = 1:length(bioms_name(dimBio))
                        bioms_name2 = bioms_name(dimBio);
                        disp(['Run ', s.statfuncname, ' for ', bioms_name2{dim2}])
                        B(:,:) = dim_B_values(:,:,dim2);
                        %                 unit{1,dim2} = 'tmpset';
                        [stat_results(dimBio(dim2))] = nbt_run_stat_noChansBiom(Group,B,s,bioms_name2{dim2},unit{1,dim2});
                        [firstname,secondname]=strtok(bioms_name2{dim2},'.');
                        
                        data = load([Group.fileslist(1).path '/' Group.fileslist(1).name],firstname);
                        name = genvarname(char(fields(data)));
                        
                        if eval(['isa(data.' name ',''nbt_questionnaire'')']);
                            eval(['questions = data.' name '.Questions;'])
                            questions = questions(1:size(B,1));
                            
                            if isfield(stat_results,'p')
                                set(get(gca, 'YLabel'), 'String','')
                                set(gca, 'Ytick',1:length(questions))
                                set(gca, 'Yticklabel',[])
                                %                     xlim = get(gca,'xlim');
                                xlim = get(gca,'xlim');
                                for ticklab = 1:length(questions)
                                    text(xlim(1)+1,ticklab,questions{ticklab},'rotation',-60,'fontsize',8)
                                end
                            end
                        else
                            %                             questions = 1:size(B,1);
                        end
                        clear data
                        %
                        
                        
                    end
                end
                try
                    B=evalin('base','stat_results');
                    stat_results=appendStruct(stat_results,B);
                    
                catch
                end
                assignin('base','stat_results',stat_results);
                assignin('base','stat_update',now);
                clear stat_results
            end
            %% ----------------------
            % Between two groups
            %----------------------
        elseif length(group_ind) == 2
            G = evalin('base','G');
            Group1 = G(group_ind(1));
            Group2 = G(group_ind(2));
            
            try
                NCHANNELS = length(Group1.chansregs.chanloc);
            catch
                error('You need to define which channels to analyze first, click Select Channels and Regions')
            end
            
            nameG2 = Group2.fileslist.group_name;
            path2 = Group2.fileslist.path;
            n_files2 = length(Group2.fileslist);
            nameG1 = Group1.fileslist.group_name;
            path1 = Group1.fileslist.path;
            n_files1 = length(Group1.fileslist);
            % load biomarkers
            %----------------------
            % Load biomarkers
            %----------------------
            [B_values1_cell,Sub1,Proj1,unit] = nbt_checkif_groupdiff(Group1,G,n_files1,bioms_name,path1);
            [B_values2_cell,Sub2,Proj2,unit] = nbt_checkif_groupdiff(Group2,G,n_files2,bioms_name,path2);
            
            if(strcmp(class(B_values1_cell{1,1}),'cell')) % our biomarker is nested - experimental part FIXME
                NestIndex = input('Please write the nesting index 1: ');
                if(size(B_values1_cell{1,1}{NestIndex},1) == NCHANNELS)
                    for mm=1:size(B_values1_cell,1)
                        tmpV{mm,1} = B_values1_cell{mm,1}{NestIndex}';
                    end
                    B_values1_cell = tmpV;
                    clear tmpV
                    for mm=1:size(B_values2_cell,1)
                        tmpV{mm,1} = B_values2_cell{mm,1}{NestIndex}';
                    end
                    B_values2_cell = tmpV;
                    clear tmpV
                else %the biomarker is double nested (PeakFit power ratio e.g.)
                    NestIndex2 = input('Please write nesting index 2: ');
                    for mm=1:size(B_values1_cell,1)
                        tmpV{mm,1} = B_values1_cell{mm,1}{NestIndex,1}{NestIndex2}';
                    end
                    B_values1_cell = tmpV;
                    clear tmpV;
                    for mm=1:size(B_values2_cell,1)
                        tmpV{mm,1} = B_values2_cell{mm,1}{NestIndex,1}{NestIndex2}';
                    end
                    B_values2_cell = tmpV;
                end
            end
            
            
            % check that all biomarkers have same dimensionality
            %----------------------
            % check biomarkers dimensionality
            %----------------------
            [dimens_diff,biomPerChans,IndexbiomNotPerChans] = nbt_dimension_check(B_values1_cell,NCHANNELS);
            
            % load statistical test
            s = nbt_statisticslog(statTest);
            %----------------------
            % biomarkers for channels or regions
            %----------------------
            %     stat_results = strcut([]);
            %     assignin('base','stat_results',stat_results);
            % compute statistics and plot biomarkers which have values for all the channels
            
            if ~isempty(biomPerChans)
                B_values1 = nbt_extractBiomPerChans(biomPerChans,B_values1_cell);
                %B_values1(:,:,1) = nbt_FindAbnormalData(B_values1(:,:,1));
                B_values2 = nbt_extractBiomPerChans(biomPerChans,B_values2_cell);
                %B_values2(:,:,1) = nbt_FindAbnormalData(B_values2(:,:,1));
                %warning('Abnormal data removed')
                % select channels or regions
                
                if strcmp(regs_or_chans_name,'Channels')
                    ChannelsToUse = Group1.chansregs.channel_nr;
                    B_gebruik1(:,:,:) = B_values1(ChannelsToUse,:,:);
                    B_gebruik2(:,:,:) = B_values2(ChannelsToUse,:,:);
                    regs = [];
                elseif strcmp(regs_or_chans_name,'Regions')
                    regions = Group1.chansregs.listregdata;
                    % for j = 1:n_files1 % subject
                    for j = 1:size(B_values1, 2)
                        for l = 1:length(bioms_name) % biomarker
                            B1 = B_values1(:,j,l);
                            B_gebruik1(:,j,l) = get_regions(B1,regions,s);
                        end
                    end
                    %  for j = 1:n_files2 % subject
                    for j = 1:size(B_values2, 2)
                        for l = 1:length(bioms_name) % biomarker
                            B2 = B_values2(:,j,l);
                            B_gebruik2(:,j,l) = get_regions(B2,regions,s);
                        end
                    end
                    regs = regions;
                elseif strcmp(regs_or_chans_name,'Match channels');
                    ChannelsToUse = Group1.chansregs.channel_nr;
                    B_gebruik1(:,:,:) = B_values1(ChannelsToUse,:,:);
                    
                    %Match values in Group2 to the chanlocs in Group 1
                    for mm=1:size(B_values2,3)
                        NewValuesB2(:,:,mm) = nbt_reshape2Chanlocs(B_values2(:,:,mm)', Group2.chansregs.chanloc, Group1.chansregs.chanloc)' ;
                    end
                    B_gebruik2(:,:,:) = NewValuesB2(ChannelsToUse,:,:);
                    regs =[];
                end
                clear B1 B_values1 B2 B_values2
                
                
                %----------------------
                % Run Statistics
                %----------------------
                bioms_name2 = bioms_name(biomPerChans);
                for i = 1:length(bioms_name2)
                    disp(['Run ', s.statfuncname, ' for ', bioms_name2{i}])
                    B1(:,:) = B_gebruik1(:,:,i);
                    B2(:,:) = B_gebruik2(:,:,i);
                    [stat_results(biomPerChans(i))] = nbt_run_stat_2groups_or_2conditions(Group1,Group2,B1,B2,s,bioms_name2{i},regs,unit{1,i});
                end
                
                
                %assign results to stat_results in base stack
                
                %----------------------
                % Plot Statistics
                %----------------------
                pvaluesmatrix(s,stat_results(biomPerChans),regs_or_chans_name,bioms_name(biomPerChans),regs,Group1,Group2,nameG1,nameG2)
                
                
                try
                    B=evalin('base','stat_results');
                    stat_results=appendStruct(stat_results,B);
                    stat_results.update=now;
                catch
                end
                assignin('base','stat_results',stat_results);
                assignin('base','stat_update',now);
                clear stat_results
            end
            % compute statistics and plot biomarkers which have values not for all
            % channels (i.e. biomarker extracted from questionnaires)
            %----------------------
            % biomarkers with different dimensionality
            %----------------------
            if ~isempty(IndexbiomNotPerChans)
                clear B1 B2 B
                %         stat_results = evalin('base','stat_results');
                if length(IndexbiomNotPerChans) == 1
                    stop = length(IndexbiomNotPerChans);
                else
                    stop = length(IndexbiomNotPerChans)-1;
                end
                for dim = 1:stop
                    dimBio = IndexbiomNotPerChans{dim};
                    dim_B_values1(:,:,:) = nbt_extractBiomNotPerChans(dimBio,B_values1_cell);
                    dim_B_values2(:,:,:) = nbt_extractBiomNotPerChans(dimBio,B_values2_cell);
                    % load statistical test
                    s = nbt_statisticslog(statTest);
                    if strcmp(s.statfuncname,'Permutation for correlation') || strcmp(s.statfuncname,'Permutation for difference (means)') || strcmp(s.statfuncname,'Permutation for difference (medians)')
                        disp('Test not available for this NBT verison')
                    else
                        
                        %----------------------
                        % Run Statistics
                        %----------------------
                        for dim2 = 1:length(bioms_name(dimBio))
                            bioms_name2 = bioms_name(dimBio);
                            disp(['Run ', s.statfuncname, ' for ', bioms_name2{dim2}])
                            B1(:,:) = dim_B_values1(:,:,dim2);
                            B2(:,:) = dim_B_values2(:,:,dim2);
                            %                 unit{1,dim2} = 'tmpset';
                            
                            %----------------------
                            % Plot Statistics
                            %----------------------
                            try
                                [firstname,secondname]=strtok(bioms_name2{1},'.');
                                
                                data = load([Group1.fileslist(1).path '/' Group1.fileslist(1).name],firstname);
                                name = genvarname(char(fields(data)));
                                
                                if eval(['isa(data.' name ',''nbt_questionnaire'')']);
                                    eval(['questions = data.' name '.Questions;'])
                                    questions = questions(1:size(B1,1));
                                else
                                    questions = 1:size(B1,1);
                                end
                                pvaluesmatrix_noChansBiom(s,stat_results(dimBio(dim2)),bioms_name(dimBio(dim2)),Group1,Group2,nameG1,nameG2);
                                
                                clear data
                                if isfield(stat_results,'p')
                                    set(get(gca, 'YLabel'), 'String','')
                                    set(gca, 'Ytick',1:length(questions))
                                    set(gca, 'Yticklabel',[])
                                    xlim = get(gca,'xlim');
                                    for ticklab = 1:length(questions)
                                        text(xlim(1)+1,ticklab,questions{ticklab},'rotation',-60,'fontsize',8)
                                    end
                                end
                            end
                        end
                    end
                    try
                        B=evalin('base','stat_results');
                        stat_results=appendStruct(stat_results,B);
                    catch
                    end
                    assignin('base','stat_results',stat_results);
                    assignin('base','stat_update',now);
                    clear stat_results
                end
            end
            %% -----------------------
            % For more than 2 groups
            % ------------------------
        elseif length(group_ind) > 2
            %-------------------------
            % First load biomarkers
            %-------------------------
            B_values = cell(length(group_ind),1);
            MaxGroupSize = 0;
            for i=1:length(group_ind)
                Group = G(group_ind(i));
                [B_values_cell,Sub,Proj,unit] = nbt_checkif_groupdiff(Group,G,length(Group.fileslist),bioms_name,Group.fileslist);
                
                [dimens_diff,biomPerChans,IndexbiomNotPerChans] = nbt_dimension_check(B_values_cell, length(Group.chansregs.chanloc));
                
                B_values{i,1} = nbt_extractBiomPerChans(biomPerChans,B_values_cell);
                MaxGroupSize = max(MaxGroupSize, length(Group.fileslist));
            end
            
            
            NCHANNELS=length(Group.chansregs.chanloc);
            s = nbt_statisticslog(statTest);
            stat_results=nbt_run_stat_multiGroup(B_values,s,MaxGroupSize,NCHANNELS, bioms_name,unit);
            
            if (length(group_ind) <=3)
                Group1 = G(group_ind(1));
                Group2  = G(group_ind(2));
                Group3 = G(group_ind(3));
                pvaluesmatrixMulti(s,stat_results,bioms_name,Group1,Group2,Group3)
            else
                pvaluesmatrixMulti(s,stat_results,bioms_name,[],[],[])
            end
            try
                B=evalin('base','stat_results');
                stat_results=appendStruct(stat_results,B);
                stat_results.update=now;
            catch
            end
            assignin('base','stat_results',stat_results);
            assignin('base','stat_update',now);
        end
        
        set(HrunStat, 'String', 'Run Test')
        drawnow
    end

    function plot_test3Groups(d1,d2,x,stat_results,Group1,Group2, Group3)
        
        pos_cursor_unitfig = get(gca,'currentpoint');
        biomarker = round(pos_cursor_unitfig(1,1));
        if  biomarker>0 && biomarker<= size(x,2)
            s = stat_results(biomarker);
            chanloc = Group1.chansregs.chanloc;
            biom = s.biom_name;
            unit = '.';
            nbt_plot_3conditions_topo(Group1,Group2,Group3,chanloc,s,unit,biom);
        end
        %
    end



%-------------------------------------------------
    function pvaluesmatrix_noChansBiom(s,stat_results,bioms_name,Group1,Group2,nameG1,nameG2)
        if isfield(stat_results,'p')
            % ---------compare p-values test results
            x = nan(length(stat_results(1).p), length(stat_results));
            for k = 1:length(stat_results)
                x(:,k)  = log10(stat_results(k).p)';
            end
            y =  x;
            
            h1 = figure('Visible','off');
            ah=bar3(y);
            h2 = figure('Visible','on','numbertitle','off','Name',['p-values of biomarkers for ', s.statfuncname],'position',[10          80       1700      500]);
            %--- adapt to screen resolution
            h2=nbt_movegui(h2);
            %---
            hh=uicontextmenu;
            hh2 = uicontextmenu;
            bh=bar3(x);
            for i=1:length(bh)
                zdata = get(ah(i),'Zdata');
                set(bh(i),'cdata',zdata);
            end
            axis tight
            %     axis image
            %     zlabel('mean difference')
            %     axis off
            grid off
            view(-90,-90)
            colorbar('off')
            coolWarm = load('nbt_CoolWarm.mat','coolWarm');
            coolWarm = coolWarm.coolWarm;
            colormap(coolWarm);
            cbh = colorbar('EastOutside');
            minPValue = -2.6;%min(zdata(:));% Plot log10(P-Values) to trick colour bar
            maxPValue = 0;%max(zdata(:));
            caxis([minPValue maxPValue])
            set(cbh,'YTick',[-2 -1.3010 -1 0])
            set(cbh,'YTicklabel',[0.01 0.05 0.1 1]) %(log scale)
            set(cbh,'XTick',[],'XTickLabel','')
            %     set(get(cbh,'title'),'String','p-values','fontsize',8,'fontweight','b
            %     old');
            DeltaC = (maxPValue-minPValue)/20;
            pos_a = get(gca,'Position');
            %     pos = get(cbh,'Position');
            set(cbh,'Position',[1.5*pos_a(1)+pos_a(3) pos_a(2)+pos_a(4)/3 0.01 0.3 ])
            Pos=get(cbh,'position');
            set(cbh,'units','normalized');
            %         uic=uicontrol('style','slider','units','normalized','position',[Pos(1)-0.015*Pos(1) Pos(2) 0.01 0.3 ],...
            %         'min',minPValue,'max',maxPValue-DeltaC,'value',minPValue,...
            %         'callback',{@Slider_fun,DeltaC,Pos,maxPValue,bh});
            
            for i = 1:length(bioms_name)
                limx = get(gca,'xlim');
                umenu = text(i,limx(1), regexprep(bioms_name{i},'_',' '),'horizontalalignment','right','fontsize',8,'fontweight','bold');
                set(umenu,'uicontextmenu',hh);
            end
            set(gca,'YTick',1:5:size(y,1))
            set(gca,'YTickLabel',1:5:size(y,1),'Fontsize',8)
            set(gca,'XTick',[])
            set(gca,'XTickLabel','','Fontsize',8)
            
            
            set(bh,'uicontextmenu',hh2);
            title(['p-values of biomarkers for ', s.statfuncname, ' for ''', regexprep(nameG2,'_',''),''' vs ''',regexprep(nameG1,'_',''),''''],'fontweight','bold','fontsize',12)
            
            uimenu(hh,'label','Plot topoplot','callback',{@plot_test2Groups2,x,stat_results,Group1,Group2});
            uimenu(hh2,'label','Plot boxplot','callback',{@plot_subj_vs_subj2,x,stat_results,Group1,Group2});
            close(h1)
        else
            disp('Graphic visualization not available.')
        end
    end

% plot pvalue matrix
    function pvaluesmatrix(s,stat_results,regs_or_chans_name,bioms_name,regs,Group1,Group2,nameG1,nameG2)
        if isfield(stat_results,'p')
            
            % ---------compare p-values test results
            x = nan(length(stat_results(1).p), length(stat_results));
            for k = 1:length(stat_results)
                x(:,k)  = log10(stat_results(k).p)';
            end
            y =  x;
            
            h1 = figure('Visible','off');
            ah=bar3(y);
            h2 = figure('Visible','on','numbertitle','off','Name',['p-values of biomarkers for ', s.statfuncname],'position',[10          80       1700      500]);
            %--- adapt to screen resolution
            h2=nbt_movegui(h2);
            %---
            hh=uicontextmenu;
            hh2 = uicontextmenu;
            bh=bar3(x);
            for i=1:length(bh)
                zdata = get(ah(i),'Zdata');
                set(bh(i),'cdata',zdata);
            end
            axis tight
            %     axis image
            %     zlabel('mean difference')
            %     axis off
            grid off
            view(-90,-90)
            colorbar('off')
            coolWarm = load('nbt_CoolWarm.mat','coolWarm');
            coolWarm = coolWarm.coolWarm;
            colormap(coolWarm);
            cbh = colorbar('EastOutside');
            minPValue = -2.6;%min(zdata(:));% Plot log10(P-Values) to trick colour bar
            maxPValue = 0;%max(zdata(:));
            caxis([minPValue maxPValue])
            set(cbh,'YTick',[-2 -1.3010 -1 0])
            set(cbh,'YTicklabel',{' 0.01', ' 0.05', ' 0.1', ' 1'}) %(log scale)
            set(cbh,'XTick',[],'XTickLabel','')
            %     set(get(cbh,'title'),'String','p-values','fontsize',8,'fontweight','b
            %     old');
            DeltaC = (maxPValue-minPValue)/20;
            pos_a = get(gca,'Position');
            %     pos = get(cbh,'Position');
            set(cbh,'Position',[1.5*pos_a(1)+pos_a(3) pos_a(2)+pos_a(4)/3 0.01 0.3 ])
            Pos=get(cbh,'position');
            set(cbh,'units','normalized');
            %         uic=uicontrol('style','slider','units','normalized','position',[Pos(1)-0.015*Pos(1) Pos(2) 0.01 0.3 ],...
            %         'min',minPValue,'max',maxPValue-DeltaC,'value',minPValue,...
            %         'callback',{@Slider_fun,DeltaC,Pos,maxPValue,bh});
            
            if strcmp(regs_or_chans_name,'Channels')
                for i = 1:length(bioms_name)
                    umenu = text(i,-10, regexprep(bioms_name{i},'_',' '),'horizontalalignment','left','fontsize',10,'fontweight','bold');
                    set(umenu,'uicontextmenu',hh);
                end
                set(gca,'YTick',1:5:size(y,1))
                set(gca,'YTickLabel',1:5:size(y,1),'Fontsize',10)
                set(gca,'XTick',[])
                set(gca,'XTickLabel','','Fontsize',10)
                ylabel('Channels')
            elseif strcmp(regs_or_chans_name,'Regions')
                for i = 1:length(bioms_name)
                    umenu = text(i,-0.3,regexprep(bioms_name{i},'_',' '),'horizontalalignment','left','fontsize',10,'fontweight','bold');
                    set(umenu,'uicontextmenu',hh);
                end
                for i= 1:size(x,1)
                    text(size(x,2)+0.5,i, regexprep(regs(i).reg.name,'_',' '),'verticalalignment','base','fontsize',10,'rotation',-30,'fontweight','bold');
                end
                set(gca,'XTick',[])
                set(gca,'XTickLabel','','Fontsize',10)
                set(gca,'YTick',[])
                set(gca,'YTickLabel','','Fontsize',10)
                ylabel('Regions')
            end
            set(bh,'uicontextmenu',hh2);
            title(['p-values of biomarkers for ', s.statfuncname, ' for ''', regexprep(nameG2,'_',''),''' vs ''',regexprep(nameG1,'_',''),''''],'fontweight','bold','fontsize',12)
            
            uimenu(hh,'label','Plot topoplot','callback',{@plot_test2Groups,x,stat_results,regs,Group1,Group2});
            uimenu(hh2,'label','Plot boxplot','callback',{@plot_subj_vs_subj,x,stat_results,regs,Group1,Group2,regs_or_chans_name});
            uicontrol(h2, 'Style', 'pushbutton', 'string', 'Plot topoplots of all biomarkers', 'position', [20 400 200 20],'callback',{@plot_test2GroupsAll,x, stat_results, regs, Group1, Group2});
            close(h1)
            nbt_plotMCcorrection(s,stat_results,bioms_name,nameG1,nameG2);
            
        else
            disp('Graphic visualization not available.')
        end
    end

    function pvaluesmatrixMulti(s,stat_results,bioms_name,Group1,Group2,Group3)
        if isfield(stat_results,'p')
            % ---------compare p-values test results
            
            %
            x = nan(length(stat_results(1).p), length(stat_results));
            for k = 1:length(stat_results)
                x(:,k)  = log10(stat_results(k).p)';
            end
            y =  x;
            
            h1 = figure('Visible','off');
            ah=bar3(y);
            h2 = figure('Visible','on','numbertitle','off','Name',['p-values of biomarkers for ', s.statfuncname],'position',[10          80       1700      500]);
            %--- adapt to screen resolution
            h2=nbt_movegui(h2);
            %---
            bh=bar3(x);
            for i=1:length(bh)
                zdata = get(ah(i),'Zdata');
                set(bh(i),'cdata',zdata);
            end
            axis tight
            %     axis image
            %     zlabel('mean difference')
            %     axis off
            grid off
            view(-90,-90)
            colorbar('off')
            coolWarm = load('nbt_CoolWarm.mat','coolWarm');
            coolWarm = coolWarm.coolWarm;
            colormap(coolWarm);
            cbh = colorbar('EastOutside');
            minPValue = -2.6;%min(zdata(:));% Plot log10(P-Values) to trick colour bar
            maxPValue = 0;%max(zdata(:));
            caxis([minPValue maxPValue])
            set(cbh,'YTick',[-2 -1.3010 -1 0])
            set(cbh,'YTicklabel',{' 0.01', ' 0.05', ' 0.1', ' 1'}) %(log scale)
            set(cbh,'XTick',[],'XTickLabel','')
            %     set(get(cbh,'title'),'String','p-values','fontsize',8,'fontweight','b
            %     old');
            DeltaC = (maxPValue-minPValue)/20;
            pos_a = get(gca,'Position');
            %     pos = get(cbh,'Position');
            set(cbh,'Position',[1.5*pos_a(1)+pos_a(3) pos_a(2)+pos_a(4)/3 0.01 0.3 ])
            Pos=get(cbh,'position');
            set(cbh,'units','normalized');
            %         uic=uicontrol('style','slider','units','normalized','position',[Pos(1)-0.015*Pos(1) Pos(2) 0.01 0.3 ],...
            %         'min',minPValue,'max',maxPValue-DeltaC,'value',minPValue,...
            %         'callback',{@Slider_fun,DeltaC,Pos,maxPValue,bh});
            
            hh = uicontextmenu;
            for i = 1:length(bioms_name)
                umenu = text(i,-10, regexprep(bioms_name{i},'_',' '),'horizontalalignment','left','fontsize',10,'fontweight','bold');
                set(umenu,'uicontextmenu', hh);
            end
            set(gca,'YTick',1:5:size(y,1))
            set(gca,'YTickLabel',1:5:size(y,1),'Fontsize',10)
            set(gca,'XTick',[])
            set(gca,'XTickLabel','','Fontsize',10)
            ylabel('Channels')
            
            hh2 = uicontextmenu;
            set(bh,'uicontextmenu',hh2);
            
            title(['p-values of biomarkers for ', s.statfuncname],'fontweight','bold','fontsize',12)
            uimenu(hh2,'label','Plot boxplot','callback',{@nbt_multcompare, stat_results});
            if(~isempty(Group3))
                uimenu(hh,'label','Plot topoplot','callback',{@plot_test3Groups,x,stat_results,Group1,Group2,Group3});
            end
            close(h1)
            nbt_plotMCcorrection(s,stat_results,bioms_name,'','');
        else
            disp('Graphic visualization not available.')
        end
    end

    function nbt_multcompare(d1, d2, stat_results)
        pos_cursor_unitfig = get(gca,'currentpoint');
        CId = round(pos_cursor_unitfig(1,2));
        BId = round(pos_cursor_unitfig(1,1));
        figure
        multcompare(stat_results(BId).MultiStats{CId,1});
    end

% slider
%     function Slider_fun(d1,d2,DeltaC,Pos,maxPValue,bh)
%         Level=get(gcbo,'Value');
%        col = get(gcf,'color');
%        uicontrol('style','text','units','normalized',...
%            'position',[Pos(1) Pos(2)+Pos(4)+0.1*Pos(4) 0.05 0.02],...
%            'string',['p <= ',sprintf('%4f',10^Level)],'fontsize',8,'BackgroundColor',col,'fontweight','bold');
%          set(findobj(gcf,'tag','Colorbar'),'YLim',[get(gcbo,'Value') maxPValue]);
%          set(findobj(gcf,'tag','Colorbar'),'YTick',linspace(get(gcbo,'Value'),maxPValue,3));
%          set(findobj(gcf,'tag','Colorbar'),'YTicklabel',sprintf('%4f',(10.^(linspace(get(gcbo,'Value'),maxPValue,3)))));
%          for i=1:length(bh)
%             zdata = get(bh(i),'Zdata');
%             ind = find(zdata(:)<=Level);
%             zdata(ind) = Level;
%             set(bh(i),'cdata',zdata);
%          end
%     end

%%
% difference group
    function diff_group(d1,d2)
        G = evalin('base','G');
        % --- get group (one or more)
        group_ind = get(ListGroup,'Value');
        if length(group_ind) >2
            warning('Select only two for difference group creation!')
        elseif length(group_ind) == 1
            warning('Two groups are necessary for difference group creation!')
        elseif length(group_ind) == 2
            if length(G(group_ind(1)).fileslist) == length(G(group_ind(2)).fileslist)
                group_name = get(ListGroup,'String');
                group_name = group_name(group_ind);
                G(end+1).fileslist = struct([]);
                for g = 1: length(group_ind)
                    G(end).fileslist = [G(end).fileslist G(group_ind(g)).fileslist];
                    G(end).biomarkerslist = G(group_ind(g)).biomarkerslist;
                    G(end).chansregs = G(group_ind(g)).chansregs;
                end
                scrsz = get(0,'ScreenSize');
                % fit figure to screen, adapt to screen resolution
                hh2 = figure('Units','pixels', 'name','Define group difference' ,'numbertitle','off','Position',[scrsz(3)/4  scrsz(4)/2  250  120],...
                    'MenuBar','none','NextPlot','new','Resize','on');
                col =  get(hh2,'Color' );
                set(hh2,'CreateFcn','movegui')
                hgsave(hh2,'onscreenfig')
                close(hh2)
                hh2 = hgload('onscreenfig');
                currentFolder = pwd;
                delete([currentFolder '/onscreenfig.fig']);
                step = 40;
                
                nameg1 = group_name{1};
                sep = findstr(nameg1,':');
                nameg1 = nameg1(sep+1:end);
                nameg2 = group_name{2};
                sep = findstr(nameg2,':');
                nameg2 = nameg2(sep+1:end);
                
                text_diff1= uicontrol(hh2,'Style','text','Position',[25 45+step 200 20],'string','Group 1     minus     Group 2','fontsize',10,'fontweight','Bold','BackgroundColor',col);
                text_diff2= uicontrol(hh2,'Style','edit','Position',[25 10+step 80 30],'string',nameg1,'fontsize',10);
                text_diff3= uicontrol(hh2,'Style','text','Position',[115 20+step 20 20],'string',' - ','fontsize',15,'fontweight','Bold','BackgroundColor',col);
                text_diff4= uicontrol(hh2,'Style','edit','Position',[150 10+step 80 30],'string',nameg2,'fontsize',10,'BackgroundColor',col);
                OkButton = uicontrol(hh2,'Style','pushbutton','String','OK','Position',[25 10 200 30],'fontsize',10,'callback',{@confirm_diff_group,G,text_diff2,text_diff4});
            else
                warning('The two groups must have same number of subjects!')
            end
            
        end
        
    end
    function confirm_diff_group(d1,d2,G,text_diff2,text_diff4)
        nameg1 = get(text_diff2,'string');
        %             sep = findstr(nameg1,':');
        %             nameg1 = nameg1(sep+1:end);
        nameg2 = get(text_diff4,'string');
        %             sep = findstr(nameg2,':');
        %             nameg2 = nameg2(sep+1:end);
        
        new_group_name = [nameg1 ' minus ' nameg2] ;
        for g = 1:length(G(end).fileslist)
            G(end).fileslist(g).group_name = new_group_name;
            G(end).group_difference = [nameg1 '-' nameg2];
        end
        groupList{end+1} = ['Group ' num2str(length(G)) ' : ' new_group_name];
        set(ListGroup,'Max',length(groupList),'fontsize',10,'String',groupList,'BackgroundColor','w');
        
        assignin('base','G',G)
        h = get(0,'CurrentFigure');
        close(h)
    end
%%
% move up
    function up_group(d1,d2)
        G = evalin('base','G');
        group_ind = get(ListGroup,'Value');
        group_name = get(ListGroup,'String');
        group_name = group_name(group_ind(1));
        groupList = get(ListGroup,'String');
        ngroups = length(G);
        groupList2 = groupList;
        G2 = G;
        if group_ind(1)~=1
            G2(group_ind(1)-1) = G(group_ind(1));
            G2(group_ind(1)) = G(group_ind(1)-1);
            groupList2{group_ind(1)-1} = groupList{group_ind(1)};
            groupList2{group_ind(1)} = groupList{group_ind(1)-1};
            G = G2;
            groupList = groupList2;
            assignin('base','G',G)
            set(ListGroup,'Max',length(groupList),'fontsize',10,'String',groupList,'BackgroundColor','w');
        end
        
        
    end
% move down
    function down_group(d1,d2)
        G = evalin('base','G');
        group_ind = get(ListGroup,'Value');
        group_name = get(ListGroup,'String');
        group_name = group_name(group_ind(1));
        groupList = get(ListGroup,'String');
        ngroups = length(G);
        groupList2 = groupList;
        G2 = G;
        if group_ind(1)~=ngroups
            G2(group_ind(1)+1) = G(group_ind(1));
            G2(group_ind(1)) = G(group_ind(1)+1);
            groupList2{group_ind(1)+1} = groupList{group_ind(1)};
            groupList2{group_ind(1)} = groupList{group_ind(1)+1};
            G = G2;
            groupList = groupList2;
            assignin('base','G',G)
            set(ListGroup,'Max',length(groupList),'fontsize',10,'String',groupList,'BackgroundColor','w');
        end
    end
% join groups
    function join_groups(d1,d2)
        G = evalin('base','G');
        % --- get group (one or more)
        group_ind = get(ListGroup,'Value');
        group_name = get(ListGroup,'String');
        group_name = group_name(group_ind);
        G(end+1).fileslist = struct([]);
        for g = 1: length(group_ind)
            G(end).fileslist = [G(end).fileslist G(group_ind(g)).fileslist];
            G(end).biomarkerslist = G(group_ind(g)).biomarkerslist;
            G(end).chansregs = G(group_ind(g)).chansregs;
        end
        new_group_name = (cell2mat(inputdlg('Assign a name to the joined group: ' )));
        for g = 1:length(G(end).fileslist)
            G(end).fileslist(g).group_name = new_group_name;
        end
        groupList{end+1} = ['Group ' num2str(length(G)) ' : ' new_group_name];
        set(ListGroup,'Max',length(groupList),'fontsize',10,'String',groupList,'BackgroundColor','w');
        
        assignin('base','G',G)
        
    end
% add group(s)
    function define_new_groups(d1,d2)
        G = evalin('base','G');
        nbt_definegroups;
    end
    function add_new_groups(d1,d2)
        G = evalin('base','G');
        newG = length(G);
        groupList = get(ListGroup,'String');
        oldG = length(groupList);
        if cellfun(@isempty,groupList)
            oldG = 0;
        end
        for i = 1:newG-oldG
            groupList{oldG+i} = ['Group ' num2str(oldG + i) ' : ' G(oldG+i).fileslist(1).group_name];
            try
                G(oldG+i).biomarkerslist = G(oldG).biomarkerslist;
            catch
                warning('Add biomarkers to the list via the Main statistics GUI')
                
            end
            try
                G(oldG+i).chansregs = G(oldG).chansregs;
            catch
                warning('Add channels/regions to the list via the Main statistics GUI')
                
            end
            
        end
        
        set(ListGroup,'Max',length(groupList),'fontsize',10,'String',groupList,'BackgroundColor','w');
        assignin('base','G',G)
        eval(['evalin(''caller'',''clear SelectedFiles'');']);
    end
% remove groups
    function remove_groups(d1,d2)
        G = evalin('base','G');
        group_ind = get(ListGroup,'Value');
        group_name = get(ListGroup,'String');
        
        
        if length(group_name)>1 && length(group_ind)<length(group_name)
            %     g3 = 1;
            %     for g = 1: length(G)
            %         for g2= 1: length(group_ind)
            %             if g ~= group_ind(g2)
            %                 newG(g3) = G(g);
            %                 groupList2{g3} = ['Group ' num2str(g3) ' : ' G(g).fileslist(1).group_name];
            %                 g3 = g3+1;
            %             end
            %         end
            %     end
            temp = 1:length(group_name);
            temp(group_ind) = [];
            newG = G(temp);
            for i = 1:length(newG)
                groupList2{i} = ['Group ' num2str(i) ' : ' G(i).fileslist(1).group_name];
            end
        else
            newG =[];
            groupList2 = {''};
        end
        G = newG;
        groupList = groupList2;
        set(ListGroup,'String','');
        set(ListGroup,'Value',length(groupList));
        set(ListGroup,'Max',length(groupList),'fontsize',10,'String',groupList,'BackgroundColor','w');
        assignin('base','G',G)
        
    end
% save groups
    function save_groups(d1,d2)
        G = evalin('base','G');
        group_ind = get(ListGroup,'Value');
        group_name = get(ListGroup,'String');
        group_name = group_name(group_ind);
        for g = 1:length(group_ind)
            saveG(g) = G(group_ind(g));
        end
        G = saveG;
        [FileName,PathName,FilterIndex] = uiputfile;
        save([PathName '/' FileName],'G');
        
    end
%----
% export bioms
    function export_bioms(d1,d2)
        G = evalin('base','G');
        disp('Export each biomarker in separate .txt files ...')
        disp('Info for converting the txt into .xls: ')
        disp('---> Data delimiters: Tab, semicolon, space');
        disp('---> Columns: subject ID; group name; biomarker name; biomarker values')
        savedir=(uigetdir([],'Select directory for saving .txt biomarkers files'));
        firstraw = {'SubID' 'GroupName' 'BiomarkerName'};
        temp = 1;
        for gindex = 1:length(G)
            if isempty(G(gindex).group_difference)
                newG(temp) =  G(gindex);
                temp = temp+1;
            else
                disp('Biomarker from group difference cannot be exported in .txt.')
            end
        end
        G = newG;
        gindex = 1;
        for biomindex = 1:length(G(gindex).biomarkerslist)
            biomName= G(gindex).biomarkerslist{biomindex};
            
            fid = fopen([savedir '/' biomName '.txt'], 'w');
            firstraw = {'SubID' 'GroupName' 'BiomarkerName'};
            for gindex = 1:length(G)
                for subindex = 1:length(G(gindex).fileslist)
                    filename = G(gindex).fileslist(subindex).name;
                    temp = findstr(filename,'.');
                    subID = filename(temp(1)+1:temp(2)-1);
                    groupName = G(gindex).fileslist(subindex).group_name;
                    path = [G(gindex).fileslist(subindex).path];
                    [Bvalues]=nbt_load_analysis(path,filename,biomName,@nbt_get_biomarker,[],[],[]);
                    successiveraw = {subID groupName biomName};
                    BvaluesReshape =  reshape(Bvalues,size(Bvalues,1)*size(Bvalues,2),1);
                    
                    if subindex == 1 && gindex == 1
                        for biomsample = 1:length(BvaluesReshape)
                            firstraw = [firstraw ['value' num2str(biomsample)]];
                        end
                        form = '%s';
                        for i = 1:length(firstraw)-1
                            form = [form '  %s'];
                        end
                        form = [form '\n'];
                        fprintf(fid, form, firstraw{:});
                    end
                    for biomsample = 1:length(BvaluesReshape)
                        successiveraw = [successiveraw num2str(BvaluesReshape(biomsample))];
                    end
                    
                    fprintf(fid, form, successiveraw{:});
                    clear successiveraw
                end
            end
            fclose(fid);
            disp([biomName '.txt has been successfully saved;'])
        end
        disp('All biomarkers have been successfully exported!')
    end
%----
% get_regions
    function B_regions = get_regions(B,regions,s)
        %         figure
        for i = 1:length(regions);
            chans_in_reg = regions(i).reg.channel_nr;
            %             subplot(1,length(regions),i)
            %             hist(B(chans_in_reg))
            B_regions(i) = s.statistic(B(chans_in_reg));
            %             hold on
            %             plot(B_regions(i),20,'r*')
        end
    end

%-------------------------------------------------
% plots
    function plot_test2Groups(d1,d2,x,stat_results,regs,Group1,Group2)
        pos_cursor_unitfig = get(gca,'currentpoint');
        biomarker = round(pos_cursor_unitfig(1,1));
        if  biomarker>0 && biomarker<= size(x,2)
            s = stat_results(biomarker);
            
            chanloc = Group1.chansregs.chanloc; %chanloc is the same for Group 1 and 2
            channel_nr = Group1.chansregs.channel_nr;
            
            %in case chanloc does not correspond to the channels you want to plot
            if length(chanloc) ~= length(channel_nr)
                
                chanloc=chanloc(1:length(channel_nr));
            end
            
            biom = s.biom_name;
            unit = s.unit;
            nbt_plot_2conditions_topo(Group1,Group2,chanloc,s,unit,biom,regs);
        end
        %
    end

    function plot_test2GroupsAll(d1,d2,x,stat_results,regs,Group1,Group2)
        %This function plots full overview of all biomarkers
        fontsize = 10;
        fig1 = figure('name',['NBT: Statistics (Channels) for all selected biomarkers'],...
            'NumberTitle','off','position',[10          80       1500      500]); %128
        fig1=nbt_movegui(fig1);
        hold on;
        NR_Biomarkers = length(stat_results);
        for biomIndex = 1:NR_Biomarkers
            %FIXME
            s = stat_results(biomIndex);
            biom = s.biom_name;
            unit = s.unit;
            
            chanloc = Group1.chansregs.chanloc;
            channel_nr = Group1.chansregs.channel_nr;
            
            %in case chanloc does not correspond to the channels you want to plot
            if length(chanloc) ~= length(channel_nr)
                
                chanloc=chanloc(1:length(channel_nr));
            end
            
            %nbt_plot_2conditions_topoAll(Group1, Group2, Group1.chansregs.chanloc,s,unit,biom,biomIndex, NR_Biomarkers);
            nbt_plot_2conditions_topoAll(Group1, Group2, chanloc,s,unit,biom,biomIndex, NR_Biomarkers);
        end
    end

%-------------------------------------------------
% plots
    function plot_subj_vs_subj(d1,d2,x,stat_results,regs,Group1,Group2,regs_or_chans_name)
        % this plot is valid when using same subject with different
        % conditions--> this implies that groups have same sumber of subject
        if length(Group1.fileslist) == length(Group2.fileslist)
            G1name = Group1.fileslist.group_name;
            G2name = Group2.fileslist.group_name;
            pos_cursor_unitfig = get(gca,'currentpoint');
            chan_or_reg = round(pos_cursor_unitfig(1,2));
            biomarker = round(pos_cursor_unitfig(1,1));
            
            if  biomarker>0 && biomarker<= size(x,2) && chan_or_reg>0 && chan_or_reg<= size(x,1)
                for i = 1:length(Group1.fileslist)
                    subname1 = Group1.fileslist(i).name;
                    tmp = findstr(subname1,'.');
                    sub1{i} = subname1(tmp(1)+1:tmp(2)-1);
                    subname2 = Group2.fileslist(i).name;
                    tmp = findstr(subname2,'.');
                    sub2{i} = subname2(tmp(1)+1:tmp(2)-1);
                end
                s = stat_results(biomarker);
                biom = s.biom_name;
                g(1,:) = s.c1(chan_or_reg,:);
                g(2,:) = s.c2(chan_or_reg,:);
                pval = sprintf('%.4f',s.p(chan_or_reg));
                
                if strcmp(regs_or_chans_name,'Channels')
                    h4 = figure('Visible','on','numbertitle','off','Name',[biom ' values for channel ' num2str(chan_or_reg) ' for each subjects'],'Position',[1000   200   350   700]);
                elseif strcmp(regs_or_chans_name,'Regions')
                    regname = regexprep(regs(chan_or_reg).reg.name,'_',' ');
                    h4 = figure('Visible','on','numbertitle','off','Name',[biom ' values for reagion ' regname ' for each subjects'],'Position',[1000   200   350   700]);
                end
                h4=nbt_movegui(h4);
                
                hold on
                plot([1.2 1.8],g,'g')
                for i = 1:length(g)
                    text(1.2,g(1,i),sub1{i},'fontsize',10,'horizontalalignment','right')
                    text(1.8,g(2,i),sub2{i},'fontsize',10)
                end
                boxplot(g')
                hold on
                plot(1,mean(g(1,:)),'s','Markerfacecolor','k')
                plot(2,mean(g(2,:)),'s','Markerfacecolor','k')
                text(1.02,mean(g(1,:)),'Mean','fontsize',10)
                text(2.02,mean(g(2,:)),'Mean','fontsize',10)
                xlim([0.8 2.2])
                ylim([min(g(:))-0.1*min(g(:)) max(g(:))+0.1*max(g(:))])
                set(gca,'Xtick', [1 2],'XtickLabel',{[G1name,'(n = ',num2str(length(g(1,:))),')'];[G2name,'(n = ',num2str(length(g(1,:))),')']},'fontsize',10,'fontweight','bold')
                xlabel('')
                ylabel([regexprep(biom,'_',' ')],'fontsize',10,'fontweight','bold')
                if strcmp(regs_or_chans_name,'Channels')
                    title({[regexprep(biom,'_',' ') ' values for '],...
                        [' channel ''' num2str(chan_or_reg) ''' for each subjects (p = ', pval,')']},'fontweight','bold','fontsize',10)
                elseif strcmp(regs_or_chans_name,'Regions')
                    regname = regexprep(regs(chan_or_reg).reg.name,'_',' ');
                    title({[regexprep(biom,'_',' ') ' values for '] ,...
                        ['region ''' regname ''' for each subjects (p = ', pval,')']},'fontweight','bold','fontsize',10)
                end
                
                
            end
        else
            G1name = Group1.fileslist.group_name;
            G2name = Group2.fileslist.group_name;
            pos_cursor_unitfig = get(gca,'currentpoint');
            chan_or_reg = round(pos_cursor_unitfig(1,2));
            biomarker = round(pos_cursor_unitfig(1,1));
            
            if  biomarker>0 && biomarker<= size(x,2) && chan_or_reg>0 && chan_or_reg<= size(x,1)
                for i = 1:length(Group1.fileslist)
                    subname1 = Group1.fileslist(i).name;
                    tmp = findstr(subname1,'.');
                    sub1{i} = subname1(tmp(1)+1:tmp(2)-1);
                end
                for i = 1:length(Group2.fileslist)
                    subname2 = Group2.fileslist(i).name;
                    tmp = findstr(subname2,'.');
                    sub2{i} = subname2(tmp(1)+1:tmp(2)-1);
                end
                %----find subject correspondence
                k = 1;
                equalsub{k} = [];
                for i = 1:length(sub1)
                    ss = strfind(sub2,sub1{i});
                    for j = 1:length(ss)
                        if ~isempty(ss{j})
                            equalsub{k}= [i j];
                            k = k+1;
                            break;
                        end
                    end
                    clear ss
                end
                
                %----
                s = stat_results(biomarker);
                biom = s.biom_name;
                g1 = s.c1(chan_or_reg,:);
                g2 = s.c2(chan_or_reg,:);
                g = [g1 g2];
                z = [zeros(length(g1),1); ones(length(g2),1)];
                
                pval = sprintf('%.4f',s.p(chan_or_reg));
                
                if strcmp(regs_or_chans_name,'Channels')
                    h4 = figure('Visible','on','numbertitle','off','Name',...
                        [biom ' values for channel ' num2str(chan_or_reg) ' for each subjects'],...
                        'Position',[1000   200   350   700]);
                elseif strcmp(regs_or_chans_name,'Regions')
                    regname = regexprep(regs(chan_or_reg).reg.name,'_',' ');
                    h4 = figure('Visible','on','numbertitle','off','Name',[biom ' values for reagion ' regname ' for each subjects'],'Position',[1000   200   350   700]);
                end
                h4=nbt_movegui(h4);
                
                hold on
                plot(1.2,g1,'g')
                plot(1.8,g2,'g')
                %----plot subject correspondence
                if sum(cellfun('isempty', equalsub))==0
                    for nn = 1:length(equalsub)
                        egualsubind = equalsub{nn};
                        hold on
                        plot([1.2 1.8],[g1(egualsubind(1)) g2(egualsubind(2))],'g')
                    end
                end
                %----
                for i = 1:length(g1)
                    text(1.2,g1(i),sub1{i},'fontsize',10,'horizontalalignment','right')
                end
                for i = 1:length(g2)
                    text(1.8,g2(i),sub2{i},'fontsize',10)
                end
                boxplot(g,z);
                hold on
                plot(1,mean(g1),'s','Markerfacecolor','k')
                plot(2,mean(g2),'s','Markerfacecolor','k')
                text(1.02,mean(g1),'Mean','fontsize',10)
                text(2.02,mean(g2),'Mean','fontsize',10)
                xlim([0.8 2.2])
                ylim([min(g(:))-0.1*min(g(:)) max(g(:))+0.1*max(g(:))])
                set(gca,'Xtick', [1 2],'XtickLabel',{[G1name, '(n = ',num2str(length(g1)),')' ];[G2name, '(n = ',num2str(length(g2)),')' ]},'fontsize',10,'fontweight','bold')
                xlabel('')
                ylabel([regexprep(biom,'_',' ')],'fontsize',10,'fontweight','bold')
                if strcmp(regs_or_chans_name,'Channels')
                    title({[regexprep(biom,'_',' ') ' values for '],...
                        [' channel ''' num2str(chan_or_reg) ''' for each subjects (p = ', pval,')']},'fontweight','bold','fontsize',10)
                elseif strcmp(regs_or_chans_name,'Regions')
                    regname = regexprep(regs(chan_or_reg).reg.name,'_',' ');
                    title({[regexprep(biom,'_',' ') ' values for '] ,...
                        ['region ''' regname ''' for each subjects (p = ', pval,')']},'fontweight','bold','fontsize',10)
                end
                
                
            end
        end
        %
    end


% plots
    function plot_test2Groups2(d1,d2,x,stat_results,Group1,Group2)
        pos_cursor_unitfig = get(gca,'currentpoint');
        biomarker = round(pos_cursor_unitfig(1,1));
        G1name = Group1.fileslist.group_name;
        G2name = Group2.fileslist.group_name;
        if  biomarker>0 && biomarker<= size(x,2)
            s = stat_results(biomarker);
            biom = s.biom_name;
            unit = s.unit;
            h = nbt_plot_2conditions_NoChansBiom(Group1,Group2,s,unit,biom);
        end
        
        if ~any(cellfun(@isempty,questions))
            set(get(h, 'XLabel'), 'String','')
            set(h, 'Xtick',1:length(questions))
            set(h, 'Xticklabel',[])
            %                     xlim = get(gca,'xlim');
            set(h,'ylim',[-3 3]);
            for ticklab = 1:length(questions)
                text(ticklab,-3,questions{ticklab},'rotation',-30,'fontsize',10, 'fontweight','bold')
            end
            if length(Group1.fileslist) == length(Group2.fileslist)
                h5 = figure('Visible','on','numbertitle','off','resize','on','Menubar','none',...
                    'Name',['Table with all items and their numbering that have a p-value lower than 0.05' ],...
                    'Position',[100   200  1000   500]);
                h5=nbt_move_gui(h5);
                
                Notsign = find(s.p>=0.05);
                for i = 1:length(s.p)
                    strp{i} = (sprintf('%.4f',s.p(i)));
                end
                
                for i = 1:length(Notsign)
                    strp{Notsign(i)} = 'N.S.';
                end
                i = 1;
                data = {i,questions{i}, s.meanc1(i),s.meanc2(i),s.meanc2(i)-s.meanc1(i),strp{i},size(s.c1,2)};
                for i = 2:length(s.p)
                    data{i,1} = i;
                    data{i,2} = questions{i};
                    data{i,3} = s.meanc1(i);
                    data{i,4} = s.meanc2(i);
                    data{i,5} = s.meanc2(i)-s.meanc1(i);
                    data{i,6} = strp{i};
                    data{i,7} = size(s.c1,2);
                end
                
                cnames = {'Question','Item',[s.statname '(' regexprep(G1name,'_',' ')  ')'],...
                    [s.statname '(' regexprep(G2name,'_',' ') ')'],...
                    [s.statname '(' regexprep(G2name,'_',' ')  ') - ' s.statname '(' regexprep(G1name,'_',' ') ')'],...
                    [s.statfuncname ' p-value'],'n'};
                columnformat = {'numeric', 'char', 'numeric','numeric','numeric','char','numeric'};
                t = uitable('Parent',h5,'ColumnName',cnames,'ColumnFormat', columnformat,...
                    'Data',data,'Position',[20 20 950 470],'RowName',[]);
            end
        end
    end
%-------------------------------------------------
% plots
    function plot_subj_vs_subj2(d1,d2,x,stat_results,Group1,Group2)
        % this plot is valid when using same subject with different
        % conditions--> this implies that groups have same sumber of subject
        if length(Group1.fileslist) == length(Group2.fileslist)
            G1name = Group1.fileslist.group_name;
            G2name = Group2.fileslist.group_name;
            pos_cursor_unitfig = get(gca,'currentpoint');
            chan_or_reg = round(pos_cursor_unitfig(1,2));
            biomarker = round(pos_cursor_unitfig(1,1));
            
            if  biomarker>0 && biomarker<= size(x,2) && chan_or_reg>0 && chan_or_reg<= size(x,1)
                for i = 1:length(Group1.fileslist)
                    subname1 = Group1.fileslist(i).name;
                    tmp = findstr(subname1,'.');
                    sub1{i} = subname1(tmp(1)+1:tmp(2)-1);
                    subname2 = Group2.fileslist(i).name;
                    tmp = findstr(subname2,'.');
                    sub2{i} = subname2(tmp(1)+1:tmp(2)-1);
                end
                s = stat_results(biomarker);
                biom = s.biom_name;
                g(1,:) = s.c1(chan_or_reg,:);
                g(2,:) = s.c2(chan_or_reg,:);
                pval = sprintf('%.4f', s.p(chan_or_reg));
                h4 = figure('Visible','on','numbertitle','off','Name',[biom ' values for item ' num2str(chan_or_reg) ' for each subjects'],'Position',[1000   200   350   700]);
                
                set(h4,'CreateFcn','movegui')
                hgsave(h4,'onscreenfig')
                close(h4)
                h4= hgload('onscreenfig');
                currentFolder = pwd;
                delete([currentFolder '/onscreenfig.fig']);
                
                hold on
                plot([1.2 1.8],g,'g')
                for i = 1:length(g)
                    text(1.2,g(1,i),sub1{i},'fontsize',10,'horizontalalignment','right')
                    text(1.8,g(2,i),sub2{i},'fontsize',10)
                end
                boxplot(g')
                hold on
                plot(1,mean(g(1,:)),'s','Markerfacecolor','k')
                plot(2,mean(g(2,:)),'s','Markerfacecolor','k')
                text(1.02,mean(g(1,:)),'Mean','fontsize',10)
                text(2.02,mean(g(2,:)),'Mean','fontsize',10)
                xlim([0.8 2.2])
                ylim([min(g(:))-0.1*min(g(:)) max(g(:))+0.1*max(g(:))])
                set(gca,'Xtick', [1 2],'XtickLabel',{[regexprep(G1name,'_',' ') , '(n = ',num2str(length(g(1,:))),')' ];[regexprep(G2name,'_',' ') , '(n = ',num2str(length(g(2,:))),')' ]},'fontsize',10,'fontweight','bold')
                xlabel('')
                ylabel([regexprep(biom,'_',' ')],'fontsize',10,'fontweight','bold')
                
                if ~any(cellfun(@isempty,questions))
                    title({[regexprep(biom,'_',' ') ' values for '],[' Question ' num2str(chan_or_reg) '.'''  questions{chan_or_reg} ''''],[' for each subjects (p = ',pval,')']},'fontweight','bold','fontsize',10)
                    %----------------------
                    answ(:,1) = s.c1(chan_or_reg,:);
                    answ(:,2) = s.c2(chan_or_reg,:);
                    
                    h5 = figure('Visible','on','numbertitle','off','Name',...
                        [biom ' for question ' num2str(chan_or_reg) ': Relative Frequencies of Responses'],...
                        'Position',[1000   500   450   300]);
                    
                    set(h5,'CreateFcn','movegui')
                    hgsave(h5,'onscreenfig')
                    close(h5)
                    h4= hgload('onscreenfig');
                    currentFolder = pwd;
                    delete([currentFolder '/onscreenfig.fig']);
                    
                    c_hist = hist(answ,floor(min(min(answ))):ceil(max(max(answ))));
                    c_hist = c_hist/size(answ,1)*100;
                    bar(floor(min(min(answ))):ceil(max(max(answ))),c_hist )
                    set(gca,'xtick',floor(min(min(answ))):ceil(max(max(answ))));
                    set(gca,'xticklabel',floor(min(min(answ)):ceil(max(max(answ)))));
                    set(gca,'ylim',[0 100])
                    xlabel('Scores')
                    ylabel('Frequency [%]')
                    legend([ regexprep(G1name,'_',' ')  ' (n = ' num2str(size(answ,1)) ')' ],[regexprep(G2name,'_',' ')  ' (n = ' num2str(size(answ,1)) ')' ])
                    title({['Relative Frequencies of Responses for Question ', num2str(chan_or_reg) '.' ] ,...
                        [''''  questions{chan_or_reg} '''']},'fontweight', 'bold' )
                    h6 = figure('Visible','on','numbertitle','off','Name',...
                        [biom ' for question ' num2str(chan_or_reg) ' Difference Distribution'],...
                        'Position',[1000   500   450   300]);
                    
                    set(h6,'CreateFcn','movegui')
                    hgsave(h6,'onscreenfig')
                    close(h6)
                    h6= hgload('onscreenfig');
                    currentFolder = pwd;
                    delete([currentFolder '/onscreenfig.fig']);
                    ansdiff = s.c2(chan_or_reg,:)-s.c1(chan_or_reg,:);
                    pdiff = s.p(chan_or_reg);
                    d_hist = hist(ansdiff,floor(min(min(ansdiff))):ceil(max(max(ansdiff))));
                    d_hist = d_hist/size(answ,1)*100;
                    bar(floor(min(min(ansdiff))):ceil(max(max(ansdiff))),d_hist)
                    legend([ regexprep(G2name,'_',' ') ' (n = ' num2str(size(answ,1)) ') - ' regexprep(G1name,'_',' ') ' (n = ' num2str(size(answ,1)) ') , p = ' num2str(sprintf('%.4f',pdiff))])
                    set(gca,'ylim',[0 100])
                    set(gca,'xtick',floor(min(min(ansdiff))):ceil(max(max(ansdiff))));
                    set(gca,'xticklabel',floor(min(min(ansdiff))):ceil(max(max(ansdiff))));
                    
                    xlabel('Score Difference')
                    ylabel('Frequency [%]')
                    title({['Difference Distribution for Question ', num2str(chan_or_reg) '.' ] ,...
                        [''''  questions{chan_or_reg} '''']},'fontweight', 'bold' )
                    %----------------------
                else
                    title({[regexprep(biom,'_',' ') ' values for '],[' item ''' num2str(chan_or_reg) ''' for each subjects (p = ', sprintf('%.4f',pval),')']},'fontweight','bold','fontsize',10)
                end
            end
        else
            G1name = Group1.fileslist.group_name;
            G2name = Group2.fileslist.group_name;
            pos_cursor_unitfig = get(gca,'currentpoint');
            chan_or_reg = round(pos_cursor_unitfig(1,2));
            biomarker = round(pos_cursor_unitfig(1,1));
            
            if  biomarker>0 && biomarker<= size(x,2) && chan_or_reg>0 && chan_or_reg<= size(x,1)
                for i = 1:length(Group1.fileslist)
                    subname1 = Group1.fileslist(i).name;
                    tmp = findstr(subname1,'.');
                    sub1{i} = subname1(tmp(1)+1:tmp(2)-1);
                end
                for i = 1:length(Group2.fileslist)
                    subname2 = Group2.fileslist(i).name;
                    tmp = findstr(subname2,'.');
                    sub2{i} = subname2(tmp(1)+1:tmp(2)-1);
                end
                %----find subject correspondence
                k = 1;
                equalsub{k} = [];
                for i = 1:length(sub1)
                    ss = strfind(sub2,sub1{i});
                    for j = 1:length(ss)
                        if ~isempty(ss{j})
                            equalsub{k}= [i j];
                            k = k+1;
                            break;
                        end
                    end
                    clear ss
                end
                
                %----
                s = stat_results(biomarker);
                biom = s.biom_name;
                g1 = s.c1(chan_or_reg,:);
                g2 = s.c2(chan_or_reg,:);
                g = [g1 g2];
                z = [zeros(length(g1),1); ones(length(g2),1)];
                
                pval = sprintf('%.4f',s.p(chan_or_reg));
                
                h4 = figure('Visible','on','numbertitle','off','Name',[biom ' values for item ' num2str(chan_or_reg) ' for each subjects'],'Position',[1000   200   350   700]);
                
                set(h4,'CreateFcn','movegui')
                hgsave(h4,'onscreenfig')
                close(h4)
                h4= hgload('onscreenfig');
                currentFolder = pwd;
                delete([currentFolder '/onscreenfig.fig']);
                
                hold on
                plot(1.2 ,g1,'g')
                plot(1.8,g2,'g')
                %----plot subject correspondence
                if sum(cellfun('isempty', equalsub))==0
                    for nn = 1:length(equalsub)
                        egualsubind = equalsub{nn};
                        hold on
                        plot([1.2 1.8],[g1(egualsubind(1)) g2(egualsubind(2))],'g')
                    end
                end
                %----
                for i = 1:length(g1)
                    text(1.2,g1(i),sub1{i},'fontsize',10,'horizontalalignment','right')
                end
                for i = 1:length(g2)
                    text(1.8,g2(i),sub2{i},'fontsize',10)
                end
                boxplot(g,z);
                hold on
                plot(1,mean(g1),'s','Markerfacecolor','k')
                plot(2,mean(g2),'s','Markerfacecolor','k')
                text(1.02,mean(g1),'Mean','fontsize',10)
                text(2.02,mean(g2),'Mean','fontsize',10)
                xlim([0.8 2.2])
                ylim([min(g(:))-0.1*min(g(:)) max(g(:))+0.1*max(g(:))])
                set(gca,'Xtick', [1 2],'XtickLabel',{[G1name, '(n = ',num2str(length(g1)),')' ];[G2name, '(n = ',num2str(length(g2)),')' ]},'fontsize',10,'fontweight','bold')
                xlabel('')
                ylabel([regexprep(biom,'_',' ')],'fontsize',10,'fontweight','bold')
                if ~ any(cellfun(@isempty,questions))
                    title({[regexprep(biom,'_',' ') ' values for '],...
                        [' Question ' num2str(chan_or_reg) '.'''  questions{chan_or_reg} ''''],...
                        [' for each subjects (p = ', pval,')']},'fontweight','bold','fontsize',10)
                    answ1 = s.c1(chan_or_reg,:);
                    answ2 = s.c2(chan_or_reg,:);
                    
                    h5 = figure('Visible','on','numbertitle','off','Name',...
                        [biom ' for question ' num2str(chan_or_reg) ': Relative Frequencies of Responses'],...
                        'Position',[1000   500   450   300]);
                    
                    set(h5,'CreateFcn','movegui')
                    hgsave(h5,'onscreenfig')
                    close(h5)
                    h4= hgload('onscreenfig');
                    currentFolder = pwd;
                    delete([currentFolder '/onscreenfig.fig']);
                    c_hist1 = hist(answ1,floor(min(min([answ1 answ2]))):ceil(max(max([answ1 answ2]))));
                    c_hist2 = hist(answ2,floor(min(min([answ1 answ2]))):ceil(max(max([answ1 answ2]))));
                    c_hist1 = c_hist1/size(answ1,2)*100;
                    c_hist2 = c_hist2/size(answ2,2)*100;
                    tothist = [c_hist1; c_hist2];
                    bar(floor(min(min([answ1 answ2]))):ceil(max(max([answ1 answ2]))),tothist');
                    
                    %         set(gca,'xtick',1:6)
                    set(gca,'xtick',floor(min(min([answ1 answ2]))):ceil(max(max([answ1 answ2]))))
                    set(gca,'xticklabel',floor(min(min([answ1 answ2]))):ceil(max(max([answ1 answ2]))))
                    set(gca,'ylim',[0 100])
                    xlabel('Scores')
                    ylabel('Frequency [%]')
                    legend([ regexprep(G1name,'_',' ') ' (n = ' num2str(size(answ1,2)) ')' ],[regexprep(G2name,'_',' ') ' (n = ' num2str(size(answ2,2)) ')' ])
                    title({['Relative Frequencies of Responses for Question ', num2str(chan_or_reg) '.' ] ,...
                        [''''  questions{chan_or_reg} '''']},'fontweight', 'bold' )
                else
                    title({[regexprep(biom,'_',' ') ' values for '],[' item ''' num2str(chan_or_reg) ''' for each subjects (p = ', sprintf('%.4f',pval),')']},'fontweight','bold','fontsize',10)
                end
            end
        end
    end
    function Print_Visualize(d1,d2)
        
        %Initialize a Print Visualize
        group_ind = get(ListGroup,'Value');
        if(length(group_ind) >1)
            group_ind = group_ind(1);
        end
        group_name = get(ListGroup,'String');
        group_name = group_name(group_ind);
        nbt_Print(group_name,group_ind)
    end
end