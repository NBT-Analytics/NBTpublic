% nbt_definegroup - Open Interface for defining a statistical group,
%                   it generates a new directory struct called SelectedFiles
%                   which contains only the files selected for the statistics
%
% Usage:
%   nbt_definegroup(d)
%
% Inputs:
%   d is the path indicating the location of NBT files
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
%% ChangeLog - see version control log at NBT website for details.
%$ Version 1.1 - 25. Oct 2012: Modified by Piotr Sokol, piotr.a.sokol@gmail.com$
%%
% Copyright (C) 2012  (Neuronal Oscillations and Cognition group,
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


function nbt_definegroup(varargin)
global G
P = varargin;
nargs = length(P);


con = 1;
sub = 1;
pro = 1;
date = 1;
gender = 1;
age = 1;
readconditions = '';
readproject = '';
readsubject = '';
readdate = '';
readgender = {''};
readage = {''};


if nargs<1
    [path]=uigetdir([],'Select folder with NBT Signals');
    d = dir(path);
else
    path=P{1};
    d = dir(path);
end

%--- scan files in the folder
%--- for files copied from a mac
startindex = 0;
for i = 1:length(d)
    if  d(i).isdir || strcmp(d(i).name(1),'.') || strcmp(d(i).name(1:2),'..') || strcmp(d(i).name(1:2),'._')
        startindex = i+1;
    end
end
%---
pro=1;
disp('Please wait: NBT is checking the files in your folder...')
for i = startindex:length(d)
    if isempty(findstr(d(i).name,'analysis')) && ~isempty(findstr(d(i).name,'info')) && ~isempty(findstr(d(i).name(end-3:end),'.mat')) && isempty(findstr(d(i).name,'statistics'))
        index = findstr(d(i).name,'.');
        index2 = findstr(d(i).name,'_');
        % read gender and age
        % load info file
        Loaded = load([path '/' d(i).name]);%Loads info file
        
        Infofields = fieldnames(Loaded);
        Firstfield = Infofields{1};
        clear Loaded Infofields;
        
        SignalInfo = load([path '/' d(i).name],Firstfield);
        SignalInfo = eval(strcat('SignalInfo.',Firstfield));
        
        %% dingus collects data for further selection
        dingus(pro,1)= {strcat(d(i).name(1:index2-1),'_analysis.mat')};%contains filename
        
        
        dingus(pro,2) =  {d(i).name(index(3)+1:index2-1)};
        dingus(pro,3) =  {d(i).name(1:index(1)-1)};
        dingus(pro,4) = {d(i).name(index(1)+1:index(2)-1)};
        dingus(pro,5) = {d(i).name(index(2)+1:index(3)-1)};
        
        if ~isempty(SignalInfo.subject_gender)
            dingus(pro,6) = {SignalInfo.subject_gender};
        else
            dingus(pro,6) = {[]};
        end
        if ~isempty(SignalInfo.subject_age)
            if isa(SignalInfo.subject_age,'char')
                dingus(pro,7) = {str2num(SignalInfo.subject_age)};
            else
                dingus(pro,7) = {SignalInfo.subject_age};
            end
        else
            dingus(pro,7) = {[]};
        end
        pro=pro+1;
    end
end
readconditions = unique(dingus(:,2));
readproject = unique(dingus(:,3));
readsubject = unique(dingus(:,4));
readdate = unique(dingus(:,5));

temp=dingus(:,6);
emptyCells = cellfun(@isempty,temp);
temp(emptyCells) = [];
readgender=unique(temp);

temp=dingus(:,7);
emptyCells = cellfun(@isempty,temp);
temp(emptyCells) = [];
readage=unique(cell2mat((temp)));




%% Questions about this part
if nargs==2;
    selection.con = P{2};
    selection.sub = readsubject;
    selection.date = readdate;
    selection.pro = readproject;
    selection.age = readage;
    selection.gender = readgender;
elseif nargs ==3;
    selection.con = P{2};
    selection.sub = P{3};
    selection.date =  readdate;
    selection.pro = readproject;
    selection.age = readage;
    selection.gender = readgender;
elseif nargs == 4;
    selection.con = P{2};
    selection.sub = P{3};
    selection.date = P{4};
    selection.pro = readproject;
    selection.age = readage;
    selection.gender = readgender;
elseif nargs == 5;
    selection.con = P{2};
    selection.sub = P{3};
    selection.date = P{5};
    selection.pro = readproject;
    selection.age = readage;
    selection.gender = readgender;
elseif nargs == 6;
    selection.con = P{2};
    selection.sub = P{3};
    selection.date = P{5};
    selection.pro = P{6};
    selection.age = readage;
    selection.gender = readgender;
end
%--- interface
if nargs <= 1
    scrsz = get(0,'ScreenSize');
    GroupSelection = figure('Units','pixels', 'name','NBT: Define Group' ,'numbertitle','off','Position',[390.0000  456.7500  1000  320], ...
        'MenuBar','none','NextPlot','new','Resize','off');
    GroupSelection=nbt_movegui(GroupSelection);
    
    g = gcf;
    Col = get(g,'Color');
    Gp1 = uipanel(GroupSelection,'Title','Conditions','FontSize',10,'Units','pixels','Position',[10 100 150 200],'BackgroundColor','w','fontweight','bold');
    listBox1 = uicontrol(Gp1,'Style','listbox','Units','pixels',...
        'Position',[1 1 140 180],...
        'BackgroundColor','white',...
        'Max',10,'Min',1, 'String', readconditions,'Value',[]);
    Gp2 = uipanel(GroupSelection,'Title','Subjects','FontSize',10,'Units','pixels','Position',[170 100 150 200],'BackgroundColor','w','fontweight','bold');
    listBox2 = uicontrol(Gp2,'Style','listbox','Units','pixels',...
        'Position',[1 1 140 180],...
        'BackgroundColor','white',...
        'Max',10,'Min',1, 'String', readsubject,'Value',[]);
    Gp3 = uipanel(GroupSelection,'Title','Date','FontSize',10,'Units','pixels','Position',[330 100 150 200],'BackgroundColor','w','fontweight','bold');
    listBox3 = uicontrol(Gp3,'Style','listbox','Units','pixels',...
        'Position',[1 1 140 180],...
        'BackgroundColor','white',...
        'Max',10,'Min',1, 'String', readdate,'Value',[]);
    Gp4 = uipanel(GroupSelection,'Title','Project','FontSize',10,'Units','pixels','Position',[490 100 150 200],'BackgroundColor','w','fontweight','bold');
    listBox4 = uicontrol(Gp4,'Style','listbox','Units','pixels',...
        'Position',[1 1 140 180],...
        'BackgroundColor','white',...
        'Max',10,'Min',1, 'String', readproject,'Value',[]);
    Gp5 = uipanel(GroupSelection,'Title','Gender','FontSize',10,'Units','pixels','Position',[650 100 150 200],'BackgroundColor','w','fontweight','bold');
    listBox5 = uicontrol(Gp5,'Style','listbox','Units','pixels',...
        'Position',[1 1 140 180],...
        'BackgroundColor','white',...
        'Max',10,'Min',1, 'String', readgender,'Value',[]);
    % sort age
    if ~isempty(readage)
        eta = sort(readage);
        clear readage
        for anni = 1:length(eta)
            readage{anni} = eta(anni);
        end
    end
    
    %
    Gp6 = uipanel(GroupSelection,'Title','Age','FontSize',10,'Units','pixels','Position',[810 100 150 200],'BackgroundColor','w','fontweight','bold');
    listBox6 = uicontrol(Gp6,'Style','listbox','Units','pixels',...
        'Position',[1 1 140 180],...
        'BackgroundColor','white',...
        'Max',10,'Min',1, 'String', readage,'Value',[]);
    %     text_ui6= uicontrol(GroupSelection,'Style','text','Position',[560 270 100 20],'string','   Age   ','fontsize',12);
    
    text_ui7= uicontrol(GroupSelection,'Style','text','Position',[700 70 200 20],'string','Write a name for the Group','fontsize',10);
    text_ui8= uicontrol(GroupSelection,'Style','edit','Position',[700 50 200 20],'string','','fontsize',10);
    
    plotButton = uicontrol(GroupSelection,'Style','pushbutton','Units','pixels','Position',[920 30 40 40], 'String','OK','callback', @groupdefinition);
else
    
    startindex = 0;
    for i = 1:length(d)
        if  d(i).isdir || strcmp(d(i).name(1),'.') || strcmp(d(i).name(1:2),'..') || strcmp(d(i).name(1:2),'._')
            startindex = i+1;
        end
    end
    k = 1;
    for i = startindex:length(d)
        if ~isempty(findstr('analysis',d(i).name))
            analysis_files(k) = d(i);
            k = k +1;
        end
    end
    g =1;
    for i = 1:length(selection.con)
        for j = 1:length(selection.sub)
            for k = 1:length(selection.date)
                for h = 1:length(selection.pro)
                    SelFiles{g} = strcat(selection.pro(h),'.',selection.sub(j),'.',selection.date(k),'.',selection.con(i),'_analysis.mat');
                    g = g+1;
                end
            end
        end
    end
    
    k = 1;
    for i = startindex:length(d)
        % read gender and age
        for j = 1:length(SelFiles)
            if strcmp(d(i).name,cell2mat(SelFiles{j}))
                Loaded = load([path '/' d(i).name(1:end-13) '_info.mat']);
                
                Infofields = fieldnames(Loaded);
                Firstfield = Infofields{1};
                clear Loaded Infofields;
                
                SignalInfo = load([path '/' d(i).name(1:end-13) '_info.mat'],Firstfield);
                
                SignalInfo = eval(strcat('SignalInfo.',Firstfield));
                %-check gender
                for m = 1:length(selection.gender);
                    if ~ischar(SignalInfo.subject_gender)
                        SignalInfo.subject_gender = num2str(SignalInfo.subject_gender);
                    end
                    if ~ischar(SignalInfo.subject_age)
                        SignalInfo.subject_age = num2str(SignalInfo.subject_age);
                    end
                    if isequal(SignalInfo.subject_gender,num2str(selection.gender{m}))
                        for n = 1:length(selection.age)
                            if isequal((SignalInfo.subject_age),num2str(selection.age{n}))
                                %-check age
                                disp('Please wait: NBT is sorting the files...')
                                d(i).path = path;
                                group_name = get(text_ui8,'String');
                                d(i).group_name = group_name;
                                SelectedFiles(k) = d(i); % contains exactly the files to be used for the statistics
                                k = k +1;
                            end
                        end
                    end
                end
            end
        end
    end
    assignin('base','SelectedFiles',SelectedFiles)
    close all
end

% --- callback function - nested function
    function groupdefinition(src,evt)
        set(plotButton,'String', 'Busy...');
        vars1 = get(listBox1,'String');
        var_index1 = get(listBox1,'Value');
        if isempty(var_index1)
            selection.con = vars1;
        else
            if length(vars1) == length(var_index1)
                selection.con = vars1;
            else
                selection.con = vars1(var_index1);
            end
        end
        
        vars2 = get(listBox2,'String');
        var_index2 = get(listBox2,'Value');
        if isempty(var_index2)
            selection.sub = vars2;
        else
            if length(vars2) == length(var_index2)
                selection.sub = vars2;
            else
                selection.sub = vars2(var_index2);
            end
        end
        
        vars3 = get(listBox3,'String');
        var_index3 = get(listBox3,'Value');
        if isempty(var_index3)
            selection.date = vars3;
        else
            if length(vars3) == length(var_index3)
                selection.date = vars3;
            else
                selection.date = vars3(var_index3);
            end
        end
        
        
        vars4 = get(listBox4,'String');
        var_index4 = get(listBox4,'Value');
        if isempty(var_index4)
            selection.pro = vars4;
        else
            if length(vars4) == length(var_index4)
                selection.pro = vars4;
            else
                selection.pro = vars4(var_index4);
            end
        end
        
        vars5 = get(listBox5,'String');
        var_index5 = get(listBox5,'Value');
        if isempty(var_index5)
            selection.gender = vars5;
        else
            if length(vars5) == length(var_index5)
                selection.gender = vars5;
            else
                selection.gender = vars5(var_index5);
            end
        end
        
        vars6 = get(listBox6,'String');
        var_index6 = get(listBox6,'Value');
        if isempty(var_index6)
            selection.age = vars6;
        else
            if length(vars6) == length(var_index6)
                selection.age = vars6;
            else
                selection.age = vars6(var_index6);
            end
        end
        group_name = get(text_ui8,'String');
        if(isempty(group_name))
            set(plotButton,'String', 'OK');
            disp('Please write a group name to continue');
            return
        end
        selection.group_name = group_name;
        %         selection.con = con;
        %         selection.sub = sub;
        %         selection.date = date;
        %         selection.pro = pro;
        
        dingus_index=zeros(size(dingus));
        if ~isempty(selection.con)
            for counter=1:numel(selection.con)
                dingus_index(:,2)=dingus_index(:,2)+strcmp(selection.con(counter),dingus(:,2));
            end
        end
        if ~isempty(selection.pro)
            for counter=1:numel(selection.pro)
                dingus_index(:,3)=dingus_index(:,3)+strcmp(selection.pro(counter),dingus(:,3));
            end
        end
        if ~isempty(selection.sub)
            for counter=1:numel(selection.sub)
                dingus_index(:,4)=dingus_index(:,4)+strcmp(selection.sub(counter),dingus(:,4));
            end
        end
        if ~isempty(selection.date)
            for counter=1:numel(selection.date)
                dingus_index(:,5)=dingus_index(:,5)+strcmp(selection.date(counter),dingus(:,5));
            end
        end
        if ~isempty(selection.gender)
            for counter=1:numel(selection.gender)
                dingus_index(:,6)=dingus_index(:,6)+strcmp(selection.gender(counter),dingus(:,6));
            end
        else
            dingus_index(:,6)=ones(size(dingus_index(:,6)));
        end
        if ~isempty(selection.age)
            for counter=1:numel(selection.age)
                dingus_index(:,7)=dingus_index(:,7)+(cell2mat(dingus(:,7))== str2double(cell2mat(selection.age(counter))));
            end
        else
            dingus_index(:,7)=ones(size(dingus_index(:,7)));
        end
        SelFiles=find(dingus_index(:,2).*dingus_index(:,3).*dingus_index(:,4).*dingus_index(:,5).*dingus_index(:,6).*dingus_index(:,7));
        icounter = 0;
        disp('NBT is sorting the files...')
        %Here we check if the analysis files exists
        for j = 1:length(SelFiles)
            for i = startindex:length(d)
                if strcmp(d(i).name,cell2mat(dingus(SelFiles(j),1)))
                    d(i).path = path;
                    group_name = get(text_ui8,'String');
                    d(i).group_name = group_name;
                    icounter = icounter +1;
                    SelectedFiles(icounter) = d(i);
                    break; %no reason to look more
                else
                    if(i == length(d))
                        %we did not find the analysis file; issue a
                        %warning
                        warning(['The analysis file ' cell2mat(dingus(SelFiles(j),1)) ' was not found']);
                    end
                end
            end
        end
        assignin('base','SelectedFiles',SelectedFiles)
        h = get(0,'CurrentFigure');
        close(h)
    end
end
