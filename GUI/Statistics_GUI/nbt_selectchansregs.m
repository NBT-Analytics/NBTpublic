% nbt_selectchansregs - this function is part of the statistics GUI, it allows
% to select specific channels and/or regions for the statistics
%
% Usage:
%  G = nbt_selectchansregs(G)
%
% Inputs:
%   G is the struct variable containing informations on the selected groups
%      i.e.:  G(1).fileslist contains information on the files of Group 1
%           G(1).biomarkerslist list of selected biomarkers for the
%           statistics
% Outputs:
%  G updated version of the input, enriched with the field chansregs
%    i.e.:  G(1).fileslist contains information on the files of Group 1
%           G(1).biomarkerslist list of selected biomarkers for the
%           statistics
%           G(1).chansregs list of the channels and the regions selected
%
% Example:
%   G = nbt_selectchansregs(G)
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
% --------------

function nbt_selectchansregs
try
    %check if "matching channels" has been selected
    if(get(findobj('tag','ListRegion'),'Value')==3)
        SelectionType = 1;
    else
        SelectionType = 0;
    end
    %find group indicies
    ListGroup = findobj('tag','ListGroup');
    group_ind = get(ListGroup,'Value');
    
catch
    error('NBT Error: You can only have one statistics window open. Please close one, and try again.')
end



global G
try
    path = G(group_ind(1)).fileslist(1).path;
    name = G(group_ind(1)).fileslist(1).name;
    Loaded = load([path '/' name(1:end-13) '_info.mat']);
    Infofields = fieldnames(Loaded);
    Lastfield = Infofields{length(Infofields)};
    clear Loaded Infofields;
    SignalInfo = load([path '/' name(1:end-13) '_info.mat'],Lastfield);
    SignalInfo = eval(strcat('SignalInfo.',Lastfield));
catch
    [name,path] = uigetfile('','Select an Info file with channel information');
    Loaded = load([path  name]);
    Infofields = fieldnames(Loaded);
    Lastfield = Infofields{length(Infofields)};
    clear Loaded Infofields;
    SignalInfo = load([path name],Lastfield);
    SignalInfo = eval(strcat('SignalInfo.',Lastfield));
end

%--- load the infofile to extract the channel locations

scrsz = get(0,'ScreenSize');
Chans_RegsSelection = figure('Units','pixels', 'name','Select Channels and/or Regions' ,'numbertitle','off','Position',[scrsz(3)/4  scrsz(3)/5   550  400], ...
    'MenuBar','none','NextPlot','new','Resize','off');
% fit figure to screen, adapt to screen resolution
Chans_RegsSelection=nbt_movegui(Chans_RegsSelection);
%
g = gcf;
Col = get(g,'Color');

text_ui1= uicontrol(Chans_RegsSelection,'Style','text','Position',[10 360 120 20],'string','Select Channels','fontsize',10,'fontweight','bold','BackgroundColor',Col);
badchans = find(SignalInfo.BadChannels);
if isfield(SignalInfo.Interface,'number_of_channels')
    chans = SignalInfo.Interface.number_of_channels;
else
    chans = SignalInfo.Interface.EEG.nbchan;
end
if isfield(SignalInfo.Interface,'EEG') %% eeg signal;
    for chl = 1:chans
        chanlocs{chl,1} = ['<HTML><FONT color="black">', SignalInfo.Interface.EEG.chanlocs(chl).labels, '</FONT></HTML>'];
    end
    if ~isempty(badchans)
        for i =1:length(badchans)
            chanlocs{badchans(i),1} = ['<HTML><FONT color="red">', SignalInfo.Interface.EEG.chanlocs(badchans(i)).labels, '</FONT></HTML>'];
        end
    end
    u(1)=uicontrol(Chans_RegsSelection,'Units', 'pixels','style','listbox','string', [chanlocs;{''}],'Max',chans,...
        'Min',0, 'Value',[],'position',[20 50 100 300],'callback',@get_channels,'fontsize',10,'BackgroundColor','w');
else
    for chl = 1:chans
        chanlocs{chl,1} = ['<HTML><FONT color="black">', num2str(chl), '</FONT></HTML>'];
    end
    %    if ~isempty(badchans)
    %        for i =1:length(badchans)
    %            chanlocs{badchans(i),1} = ['<HTML><FONT color="red">', num2str(chl), '</FONT></HTML>'];
    %        end
    %    end
    u(1)=uicontrol(Chans_RegsSelection,'Units', 'pixels','style','listbox','string',  [chanlocs;{''}],'Max',chans,...
        'Min',0, 'Value',[],'position',[20 50 100 300],'callback',@get_channels,'fontsize',10,'BackgroundColor','w');
end

u(2) = uicontrol(Chans_RegsSelection,'Units', 'pixels','style','radiobutton','Position',[20 20 15 20],'BackgroundColor',Col);
u(3) = uicontrol(Chans_RegsSelection,'Units', 'pixels','style','text','Position',[35 15 25 20],'String','All','fontsize',10,'fontweight','bold','BackgroundColor',Col);
text_ui2= uicontrol(Chans_RegsSelection,'Units', 'pixels','Style','text','Position',[200 360 100 20],'string','Select Regions','fontsize',10,'fontweight','bold','BackgroundColor',Col);
LoadRegions = uicontrol(Chans_RegsSelection,'Units', 'pixels','Style','pushbutton','String','Load Regions >>','Position',[210 320 120 30],'fontsize',8, ...
    'callback',@loadregions);
AddRegion = uicontrol(Chans_RegsSelection,'Units', 'pixels','Style','pushbutton','String','Add Region >>','Position',[210 280 120 30],'fontsize',8, ...
    'callback',@addregion);
RemoveRegion =  uicontrol(Chans_RegsSelection,'Units', 'pixels','Style','pushbutton','String','Remove Region(s) <<','Position',[210 240 120 30],'fontsize',8, ...
    'callback',@removeregion);
SaveRegions = uicontrol(Chans_RegsSelection,'Units', 'pixels','Style','pushbutton','String','Save Regions','Position',[210 200 120 30],'fontsize',8, ...
    'callback',@saveregions);
ListRegion = uicontrol(Chans_RegsSelection,'Units', 'pixels','style','listbox','Units', 'pixels','Position',[340 170 150 180],'fontsize',10,'Max',1);

SubmitRegion = uicontrol(Chans_RegsSelection,'Units', 'pixels','Style','pushbutton','String','Submit Channels and/or Regions','Position',[280 20 210 30],'fontsize',10,...
    'callback',@submit);
u(5) = uicontrol(Chans_RegsSelection,'Units', 'pixels','style','radiobutton','Position',[340 145 15 20],'BackgroundColor',Col);
u(6) = uicontrol(Chans_RegsSelection,'Units', 'pixels','style','text','Position',[355 140 40 20],'String','None','fontsize',10,'fontweight','bold','BackgroundColor',Col);



% Callback functions
%--- channels
    function get_channels(d1,d2)
        channel_nr=get(u(1),'value');
        if length(channel_nr)> chans
            channel_nr = channel_nr(channel_nr<=chans);
        end
        data.channel_nr = channel_nr;
        try
            data.chanloc = SignalInfo.Interface.EEG.chanlocs;
        catch
            data.chanloc = [1:chans];
        end
        set(SubmitRegion,'UserData', data);
    end

    function saveregions(d1,d2)
        data = get(SubmitRegion, 'UserData');
        reg = data.listregdata;
        [filename, pathname] = uiputfile({'*.mat'},'Save Regions as');
        save([pathname '/' filename], 'reg');
    end

    function removeregion(d1,d2)
        listreg_ind = get(ListRegion,'Value');
        listreg = get(ListRegion,'String');
        listregdata = get(ListRegion,'UserData');
        g3 = 1;
        if length(listreg)>1
            for g = 1:length(listreg)
                for g2 = 1:length(listreg_ind)
                    if g ~=listreg_ind(g2)
                        new_listregdata(g3) = listregdata(g);
                        new_listreg(g3) = listreg(g);
                        g3 = g3+1;
                    end
                    
                end
            end
        else
            new_listreg = {''};
            new_listregdata = [];
        end
        listreg = new_listreg;
        listregdata = new_listregdata;
        set(ListRegion,'UserData',listregdata);
        data = get(SubmitRegion, 'UserData');
        data.listregdata = get(ListRegion,'UserData');
        set(SubmitRegion, 'UserData', data);
        set(ListRegion,'String','');
        set(ListRegion,'Value',length(listreg));
        set(ListRegion,'Max',length(listreg ),'fontsize',10,'String',listreg,'BackgroundColor','w');
        % add stuff
        
    end
    function loadregions(d1,d2)
        stat_path = ffpath('nbt_selectchansregs.m');
        [filename, pathname] = uigetfile({'*.mat'},'Load Regions .mat file', [stat_path '/']);
        if (filename == 0)
            return;
        end
        try
            old = load([pathname '/' filename]);
        catch
            disp('No region file loaded');
        end
        old = old.reg;
        listreg = get(ListRegion,'String');
        listregdata = get(ListRegion,'UserData');
        for k = 1:length(old)
            listreg{end+1} = old(k).reg.name;
        end
        if isempty(listregdata)
            for k = 1:length(old)
                listregdata(k).reg = old(k).reg;
            end
            
        else
            for k = 1:length(old)
                listregdata(end+1).reg = old(k).reg;
            end
        end
        set(ListRegion,'String',listreg);
        set(ListRegion,'UserData',listregdata);
        data = get(SubmitRegion, 'UserData');
        data.listregdata = get(ListRegion,'UserData');
        set(SubmitRegion, 'UserData', data);
    end

%---subregion
    function addregion(d1,d2)
        h = figure('Name', 'Select Channels for the Region','numbertitle','off','Position',[390.0000  400.7500  250  330.000],...
            'MenuBar','none','NextPlot','new','Resize','off');
        stattext = uicontrol(h,'Units', 'pixels','style','text','Position',[120 75 120 20],'String','Set Region Name:','fontweight','bold','fontsize',10,'BackgroundColor',Col);
        edintext =  uicontrol(h,'Units', 'pixels','style','edit','Position',[120 55 120 20],'fontsize',10,'BackgroundColor','w');
        stattext2 = uicontrol(h,'Units', 'pixels','style','text','Position',[5 300 110 20],'String','Select Channels','fontweight','bold','fontsize',10,'BackgroundColor',Col);
        
        if isfield(SignalInfo.Interface,'EEG') %% eeg signal;
            for chl = 1:chans
                chanlocs{chl,1} = ['<HTML><FONT color="black">', SignalInfo.Interface.EEG.chanlocs(chl).labels,'(', num2str(chl),')','</FONT></HTML>'];
            end
            %            if ~isempty(badchans)
            %                for i =1:length(badchans)
            %                    chanlocs{badchans(i),1} = ['<HTML><FONT color="red">', SignalInfo.Interface.EEG.chanlocs(badchans(i)).labels, '</FONT></HTML>'];
            %                end
            %            end
            u2(1)=uicontrol(h,'Units', 'pixels','style','listbox','string', [chanlocs;{''}],'Max',chans,...
                'Min',0, 'Value',[],'position',[10 20 100 270],'fontsize',10);
        else
            for chl = 1:chans
                chanlocs{chl,1} = ['<HTML><FONT color="black">', num2str(chl),'(', num2str(chl),')', '</FONT></HTML>'];
            end
            %            if ~isempty(badchans)
            %                for i =1:length(badchans)
            %                    chanlocs{badchans(i),1} = ['<HTML><FONT color="red">', num2str(chl), '</FONT></HTML>'];
            %                end
            %            end
            u2(1)=uicontrol(h,'Units', 'pixels','style','listbox','string',  [chanlocs;{''}],'Max',chans,...
                'Min',0, 'Value',[],'position',[10 20 100 270],'fontsize',10);
        end
        
        u2(2) = uicontrol(h,'Units', 'pixels','Style','pushbutton','String','OK','Position',[190 20 50 30],'fontsize',10,...
            'callback',@get_channels_reg);
        waitfor(h);
        reg = get(AddRegion,'UserData');
        listreg = get(ListRegion,'String');
        listregdata = get(ListRegion,'UserData');
        listreg{end+1} = reg.name;
        if isempty(listregdata)
            listregdata(1).reg = reg;
        else
            listregdata(end+1).reg = reg;
        end
        set(ListRegion,'String',listreg);
        set(ListRegion,'UserData',listregdata);
        data = get(SubmitRegion, 'UserData');
        data.listregdata = get(ListRegion,'UserData');
        set(SubmitRegion, 'UserData', data);
        
        function get_channels_reg(d1,d2)
            channel_nr=get(u2(1),'value');
            if length(channel_nr)> chans
                channel_nr = channel_nr(channel_nr<=chans);
            end
            reg.channel_nr = channel_nr;
            reg.name = get(edintext,'String');
            set(AddRegion,'UserData', reg);
            h2 = get(0,'CurrentFigure');
            close(h2);
        end
        
    end
%--- submit results

    function submit(d1,d2)
        if (get(u(5),'Value') == get(u(5),'Max'))
            data = get(SubmitRegion, 'UserData');
            data.listregdata = [];
            set(SubmitRegion, 'UserData',data);
        end
        if (get(u(2),'Value') == get(u(2),'Max'))
            data = get(SubmitRegion, 'UserData');
            data.channel_nr = 1:chans;
            data.chanloc = SignalInfo.Interface.EEG.chanlocs;
            set(SubmitRegion, 'UserData',data);
        end
        data = get(SubmitRegion,'UserData');
        G = evalin('base','G');
        if(SelectionType == 0)
            for i = 1:length(G)
                G(i).chansregs = data;
            end
        else %  we have two groups with different channel locations
            G(group_ind(1)).chansregs = data;
            %load SignalInfo for group to
            [name,path] = uigetfile('','Select an Info file with channel information for Group 2');
            Loaded = load([path  name]);
            Infofields = fieldnames(Loaded);
            %first we check if the SignalInfo contain channel locations
            im = 1;
            while isempty(Loaded.(Infofields{im}).Interface.EEG.chanlocs)
                im = im +1;
                if(im > length(Infofields))
                    error('NBT: This file does not contain channel locations')
                end
            end   
            G(group_ind(2)).chansregs.chanloc = Loaded.(Infofields{im}).Interface.EEG.chanlocs;
        end
        assignin('base','G',G);
        disp('Channels and Regions Selection Completed.')
        h = get(0,'CurrentFigure');
        close(h);
    end



% regions for 129(frontal,temporal1,central,temporal2,parietal,occipital)
%     regions{1}=[1     2     3     4     8     9    10    14    15    16    17    18    19    21    22    23    24    25    26    27    32    33   122   123   124   125   126   127   128];
%     regions{2}=[28    34    35    38    39    40    41    43    44    45    46    47    48    49    50    51    56    57];
%     regions{3}=[5     6     7    11    12    13    20    29    30    31    36    37    42    54    55    79    80    87    93   104   105   106   111   112   118];
%     regions{4}=[97    98   100   101   102   103   107   108   109   110   113   114   115   116   117   119   120   121];
%     regions{5}=[52    53    58    59    60    61    62    63    64    65    66    67    68    72    77    78    84    85    86    90    91    92    94    95    96    99];
%     regions{6}=[69    70    71    73    74    75    76    81    82    83    88    89];
end
