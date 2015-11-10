% [SignalInfo]=nbt_get_artifacts(Signal,SignalInfo,Save_dir)
%  This script will plot each signal in the matrix data, with the
%  possibility of frequency-filtering the data and setting time units, colors and
%  distance between signals. In the plot you can interactively select noisy
%  intervals and channels. The information about the location of these
%  artifacts will be stored in the SignalInfo file.
%
% Usage:
% nbt_get_artifacts(Signal,SignalInfo,Save_dir)
%
% Inputs:
%
% Signal = NBT Signal matrix
% SignalInfo = NBT Info object
% Save_dir = a full path to the folder you want to save the SignalInfo file, at
% which the results from the artifact rejction will be stored
%
% Warning: This function is an NBT analysis function that can be applied in a batch processing way
%        with nbt_NBTcompute by typing:
%
%        nbt_NBTcompute(@nbt_get_artifacts,SignalName,LoadDirectory)
%
%        Inputs:
%        SignalName= string with the name of the signal you want to use, if you do not have more signals in your signal file choose 'Signal'.
%        LoadDirectory: = string with the name of the directory where your NBT files are.
%
%        For example:
%
%        nbt_NBTcompute(@nbt_get_artifacts,'Signal','B:/NBT files')
%
%        In this case the SignalInfo files are allready there and the new information will be appended and saved in them.

%------------------------------------------------------------------------------------
% Originally created by Rick Jansen (2010), see NBT website for current email address
%------------------------------------------------------------------------------------

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

function[SignalInfo]=nbt_get_artifacts(Signal,SignalInfo,Save_dir)

% assigning inputs and other parameters
disp(' ')
disp('Command window code:')
disp(['nbt_get_artifacts(Signal,SignalInfo,',char(39),Save_dir,char(39),')'])
disp(' ')

original_Signal=Signal;
timescale='seconds';
frequencyinterval = [1 45];
filterorder= 4;
addlegend=0;
addcolors='1';
distance= 50;
nr_channels=size(Signal,2);
fs=SignalInfo.converted_sample_frequency;
I_file = [Save_dir,'/',SignalInfo.file_name,'_info.mat'];
channels=1:nr_channels;
interval=1:size(Signal,1);
if ~isfield(SignalInfo.Interface,'noisey_intervals');
    SignalInfo.Interface.noisey_intervals=[];
end
if~isempty(SignalInfo.BadChannels)
    tmp = zeros(size(Signal(1,:)));
    tmp(find(SignalInfo.BadChannels)) = 1;
    SignalInfo.BadChannels = tmp;
    disp(['previously identified bad channels: ',num2str(find(SignalInfo.BadChannels')')])
else
    SignalInfo.BadChannels =zeros(size(Signal(1,:)));
    disp('No previously identified bad channels')
end
disp(' ')
disp('Plotting signal...')
plotting
% set_para([],[])  %  set parameters and make plot

function plotting

    %--- get figure handle

    figHandles = findobj('Type','figure');
    done=0;
    for i=1:length(figHandles)
        if strcmp(get(figHandles(i),'Tag'),'nbt_arti')
            figure(figHandles(i))
            done=1;
        end
    end
    if ~done
        figure()
        set(gcf,'Tag','nbt_arti');
    end
    set(gcf,'numbertitle','off');
    set(gcf,'name','NBT: Get Artifacts');
    clf

    %--- apply frequency filter
    Signal=original_Signal(interval,channels);

    if isempty(filterorder)
        filterorder=4;
    end
    [b,a] = butter(filterorder,[frequencyinterval(1) frequencyinterval(2)]/(fs/2)) ;
    for i=1:length(channels)
        Signal(:,i) = filtfilt(b,a,Signal(:,i));
    end

    %--- get time scale axes
    if~strcmp(timescale,'samples')
        if strcmp(timescale,'minutes')
            step=1/(fs*60);
            eind=size(Signal,1)*step +interval(1)/(fs*60);
            index=interval(1)/(fs*60)+step:step:eind;
            xl=('time (minutes)');
        end
        if strcmp(timescale,'seconds')
            step=1/fs;
            eind=size(Signal,1)*step +interval(1)/fs;
            index=interval(1)/fs+step:step:eind;
            xl=('time (seconds)');
        end
    else
        index=interval(1):interval(end);
        xl=('sample number');
    end

    %--- create distance between signals for plotting
    if ~distance==0
        temp=distance:distance:size(Signal,2)*distance;
        temp=repmat(temp,size(Signal,1),1);
        Signal=Signal+temp;
    end

    %--- plotting
    if strcmp(addcolors,'n')
        colors=jet(length(channels));
    end
    if strcmp(addcolors,'7')
        colors=lines(length(channels));
    end
    if strcmp(addcolors,'1')
        colors=repmat([0 0 1],length(channels),1);
    end
    for ii=1:length(channels)
        hh(channels(ii))=uicontextmenu;
        h(channels(ii))=plot(index,Signal(:,ii),'color',colors(ii,:),'displayname',['Channel ',num2str(channels(ii))],'uicontextmenu',hh(channels(ii)));
        uimenu(hh(channels(ii)), 'Label', ['Channel ',num2str(channels(ii))]);
        uimenu(hh(channels(ii)), 'Label','Set as noisy channel','callback',{@set_bad_channel,channels(ii)});
        uimenu(hh(channels(ii)), 'Label','Unset as noisy channel','callback',{@unset_bad_channel,channels(ii)});
        uimenu(hh(channels(ii)), 'Label','Remove channel from plot','callback',{@remove_channel,channels(ii)});
        hold on
    end
    hold off
    xlabel(xl)

    
    set(gca,'ytick',[0:5*distance:size(Signal,2)*distance]);
    set(gca,'yticklabel',[0:5:size(Signal,2)]);
    ylabel('Channel Number')
    %--- set axes
    %y=ylim;
    y(1) = distance; y(2) = size(Signal,2)*distance;
    x=xlim;
    axis tight
    %y=ylim;
    ylim([y(1)-distance,y(2)+distance])
    yoriginal=ylim;
    xoriginal=xlim;

    %--- legend
    if addlegend
        legend(h)
    end

    %--- plot existing noisy channels black
    tmpBadChannels = find(SignalInfo.BadChannels);
    for j = 1:length(tmpBadChannels)
        findbadchannel = find(channels == tmpBadChannels(j));
        if ~isempty(findbadchannel)
            set(h(tmpBadChannels(j)),'color','k')
        end
    end
    %         for i=1:length(tmpBadChannels)
    %             set(h(tmpBadChannels(i)),'color','k')
    %         end
    clear tmpBadChannels

    %--- plot existing noisy intervals
    noisey_intervals=SignalInfo.Interface.noisey_intervals;
    ax=axis;
    if strcmp(timescale,'minutes')
        intervalplot=noisey_intervals/(fs*60);
    end
    if strcmp(timescale,'seconds')
        intervalplot=noisey_intervals/(fs);
    end
    if strcmp(timescale,'samples')
        intervalplot=noisey_intervals;
    end
    for i=1:size(intervalplot,1)
        hold on
        hhtemp=uicontextmenu;
        handlefill=fill([intervalplot(i,1) intervalplot(i,2) intervalplot(i,2) intervalplot(i,1)], ...
            [  yoriginal(1) yoriginal(1) yoriginal(2)  yoriginal(2)],'k','facealpha',0.5,'uicontextmenu',hhtemp);
        uimenu(hhtemp, 'Label','Unselect noisy interval','callback',{@unselectinterval,noisey_intervals(i,1),handlefill});
        hold off
    end

    %--- figure properties
    set(gcf,'toolbar','figure','closerequest',@finishplot)

    %--- sliders
    slidervalue_h=xoriginal(1);
    slidervalue_v=yoriginal(1);

    uicontrol('Units', 'normalized', ...
        'Style','slider', ...
        'callback',{@move_plot_h},...
        'min',xoriginal(1),'max',xoriginal(2),...
        'value',xoriginal(1)+(xoriginal(2)-xoriginal(1))/100,...
        'position',[0 0 0.2 0.05])

    uicontrol('Units', 'normalized', ...
        'Style','slider', ...
        'callback',{@move_plot_v},...
        'min',yoriginal(1),'max',yoriginal(2),...
        'value',yoriginal(1)+(yoriginal(2)-yoriginal(1))/100,...
        'position',[0 0.1 0.05 0.2])

    %---  buttons
    button2=uicontrol('Units', 'normalized', ...
        'callback',{@select_interval} ,...
        'string','click here to select noisy interval ',...
        'position',[ 0.6518    0.9524    0.3446    0.0500],'Visible','on');
    button2=uicontrol('Units', 'normalized', ...
        'callback',{@finish} ,...
        'string','click here to finish ',...
        'position',[ 0    0.9524    0.3446    0.0500],'Visible','on');

    uicontrol('Units', 'normalized', ...
        'callback',{@set_para},'position',[0.7864    0.0000    0.2107    0.0476],'string','Edit plot parameters')

    %---  support callback functions

    function[]=finish(d1,d2)
        nbt_SaveSignal([], SignalInfo, Save_dir)
        finished=1;
        close(gcf)
    end
    function[]=finishplot(d1,d2)
        finished=1;
        delete(gcf)
    end

    function[]=unselectinterval(d1,d2,x,h)
        in=find(noisey_intervals(:,1)~=x);
        noisey_intervals=noisey_intervals(in,:);
        SignalInfo.Interface.noisey_intervals=noisey_intervals;
        set(h,'visible','off')
        
    end

    function []= select_interval(hObject,d2)
        set(button2,'Visible','off')
        title('Right or double click to select interval','fontsize',8,'fontweight','bold','color','k','verticalalignment','baseline')
        hold on
        yli=ylim;
        [xa,y]=nbt_getline;
        l1= line([xa xa],[yli(1) yli(2)]);
        [xb,y1]=nbt_getline;
        l2=line([xb xb],[yli(1) yli(2)]);
        title([''])
        hold off
        set(l1,'visible','off') % set lines from interval to invisible
        set(l2,'visible','off')
        x = min(xa,xb);
        x1 = max(xa,xb);
        if strcmp(timescale,'minutes')
            
            minInt = round(x*60*fs);
            maxInt = round(x1*60*fs);
            noisey_intervals=[noisey_intervals;[round(x*60*fs) round(x1*60*fs)]];
        end
        if strcmp(timescale,'seconds')
            minInt = round(x*fs);
            maxInt = round(x1*fs);
        end
        if strcmp(timescale,'samples')
            minInt = round(x);
            maxInt = round(x1);
        end
        
        minInt = max(minInt,1);
        maxInt = min(maxInt,length(Signal));
        noisey_intervals=[noisey_intervals;[minInt maxInt]];
        SignalInfo.Interface.noisey_intervals=noisey_intervals;
        ax=axis;
        hold on
        hhtemp=uicontextmenu;
        handlefill=fill([x x1 x1 x],[  yoriginal(1) yoriginal(1) yoriginal(2)  yoriginal(2)],'k','facealpha',0.5,'uicontextmenu',hhtemp);
        uimenu(hhtemp, 'Label','Unset noisey interval','callback',{@unselectinterval,x,handlefill});
        hold off
        axis(ax);
        
        set(button2,'Visible','on')
    end

    function []= move_plot_h(hObject,d2)
        x=xlim;
        temp=get(hObject,'Value');
        add=0;
        if temp>=slidervalue_h
            if x(2)~=xoriginal(2)+add
                if x(2)+(x(2)-x(1))>xoriginal(2)
                    xlim([xoriginal(2)-(x(2)-x(1)) xoriginal(2)+add])
                else
                    xlim([x(2) x(2)+(x(2)-x(1))]);
                end
            end
        else
            if x(1)~=xoriginal(1)-add
                if x(1)-(x(2)-x(1))<xoriginal(1)
                    xlim([xoriginal(1)-add xoriginal(1)+(x(2)-x(1))])
                else
                    xlim([x(1)-(x(2)-x(1)) x(1)]);
                end
            end
        end

        x=xlim;
        value=x(1);
        if x(1)<= xoriginal(1)
            value=xoriginal(1);
        end
        if x(2)>= xoriginal(2)
            value=xoriginal(2);
        end
        if value == xoriginal(1)
            value=xoriginal(1)+(xoriginal(2)-xoriginal(1))/100;
        end
        if value == xoriginal(2)
            value=xoriginal(2)-(xoriginal(2)-xoriginal(1))/100;
        end
        slidervalue_h=value;
        set(hObject,'Value',value);
    end

    function []= move_plot_v(hObject,d2)
        y=ylim;
        temp=get(hObject,'Value');
        add=0;
        if temp>=slidervalue_v
            if y(2)~=yoriginal(2)+add
                if y(2)+(y(2)-y(1))>yoriginal(2)
                    ylim([yoriginal(2)-(y(2)-y(1)) yoriginal(2)+add])
                else
                    ylim([y(2) y(2)+(y(2)-y(1))]);
                end
            end
        else
            if y(1)~=yoriginal(1)-add
                if y(1)-(y(2)-y(1))<yoriginal(1)
                    ylim([yoriginal(1)-add yoriginal(1)+(y(2)-y(1))])
                else
                    ylim([y(1)-(y(2)-y(1)) y(1)]);
                end
            end
        end

        y=ylim;
        value=y(1);
        if y(1)<= yoriginal(1)
            value=yoriginal(1);
        end
        if y(2)>= yoriginal(2)
            value=yoriginal(2);
        end
        if value == yoriginal(1)
            value=yoriginal(1)+(yoriginal(2)-yoriginal(1))/100;
        end
        if value == yoriginal(2)
            value=yoriginal(2)-(yoriginal(2)-yoriginal(1))/100;
        end
        slidervalue_v=value;
        set(hObject,'Value',value);
    end

    function[]=set_bad_channel(d1,d2,ii)
        SignalInfo.BadChannels(ii) = 1;
        set(h(ii),'color','k')
        
    end

    function[]=unset_bad_channel(d1,d2,ii)
        SignalInfo.BadChannels(ii) = 0;
        set(h(ii),'color',colors(ii,:))
        
    end

    function []= remove_channel(d1,d2,ii)
        set(h(ii),'visible','off')
    end
end
function[]= set_para(d1,d2)
    options.Resize='on';
    options.WindowStyle='modal';
    options.Interpreter='tex';
    timescale1=timescale;
    distance1=distance;
    filterorder1=filterorder;
    interval1=interval;
    channels1=channels;
    frequencyinterval1=frequencyinterval;
    out=inputdlg([{'timescale (samples, minutes or seconds)'},{'frequency interval'},{'filterorder'}, {'legend(1 or 0)'},{'colors (1, 7 or n)'},{'distance between signals'},{'channels to be plotted (index or "all")'},{'interval to be plotted (in sample number, or "all")'}], ...
        'Specify plot parameters', ones(1,8),[{num2str(timescale)},{num2str(frequencyinterval)},{num2str(filterorder)}, {num2str(addlegend)},{num2str(addcolors)},{num2str(distance)},{num2str(channels)},{[num2str(interval(1)),' ',num2str(interval(end))]}],options);
    if ~isempty(out)
        timescale =out{1};
        frequencyinterval=str2num(out{2});
        filterorder=str2num(out{3});
        addlegend=str2num(out{4});
        addcolors=num2str(out{5});
        distance=str2double(out{6});
        if strcmp(out{7},'all')
            channels=1:size(original_Signal,2);
        else
            channels=str2num(out{7});
        end
        temp=str2num(out{8});
        if strcmp(out{8},'all')
            interval=1:size(original_Signal,1);
        else
            interval=temp(1):temp(2);
        end
        plotting
    end
end

finished=0;
while finished==0
    pause(1)
end



end










