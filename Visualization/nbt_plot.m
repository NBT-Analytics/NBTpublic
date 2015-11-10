% nbt_plot(Signal,SignalInfo,timescale,frequencyinterval,filterorder,addleg
% end,addcolors,distance)
%
% Will plot each column in the data matrix Signal, with the possibility of
% setting several parameters.
%
% Usage:
%   nbt_plot(Signal,SignalInfo,timescale,frequencyinterval,filterorder,addlegend,addcolors,distance)
%   or
%   nbt_plot(Signal,SignalInfo)
%
% Inputs:
%    Signal = NBT Signal matrix
%    SignalInfo = NBT Info object
%    timescale= 'minutes' or 'seconds', timescale and units for plotting (default = no conversion to time units, units are samples)
%	 frequencyinterval= 1-by-2 vector, containing the frequencies of the butterworth bandpass-filter interval (default = no filtering)
%    filterorder = double, order of butterworth filter (default =4)
%    addlegend=logical (0 or 1), 1 means add legend (default = 0)
%    add_colors=logical (0 or 1), 1 means plot each signal with a different color (default = 0)
%    distance = double, the distance in vertical direction between the signals
%    in the plot (default = 0)
%    
% Outputs:
%
% Example:
%   nbt_plot(Signal,SignalInfo,'seconds',[10 20],5,0,1,25)
%
% References:
% 
% See also: 
% nbt_plot_TF_and_spectrum_one_channel
  
%------------------------------------------------------------------------------------
% Originally created by Rick Jansen (2010), see NBT website for current
% email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) 2010 Rick Jansen  (Neuronal Oscillations and Cognition group, 
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


function[]=nbt_plot(varargin)

%% assigning inputs

P=varargin;
nargs=length(P);
Signal=P{1};
Info=P{2};
nr_channels=size(Signal,2);
channels=1:nr_channels;
interval=1:size(Signal,1);
fs=Info.converted_sample_frequency;

if (nargs<3 || isempty(P{3})); timescale='seconds'; else timescale = P{3}; end;
if (nargs<4 || isempty(P{4})); frequencyinterval = [1 45]; else frequencyinterval = P{4};end
if (nargs<5 || isempty(P{5})); filterorder= 4;else filterorder = P{5}; end;
if (nargs<6 || isempty(P{6})); addlegend=0;else addlegend=P{6}; end;
if (nargs<7 || isempty(P{7})); addcolors='1'; else addcolors=P{7}; end;
if (nargs<8 || isempty(P{8})); distance=6*median(std(Signal)); else distance=P{8}; end;
if (nargs<9 || isempty(P{9})); linepoint='L'; else linepoint=P{9}; end;

set_para([],[])

function plotting
    %axis off
    %% get figure handle
    figHandles = findobj('Type','figure');
    for i=1:length(figHandles)
        if strcmp(get(figHandles(i),'Tag'),'select_channel')
            close(figHandles(i))
        end
    end

    figHandles = findobj('Type','figure');
    done=0;
    for i=1:length(figHandles)
        if strcmp(get(figHandles(i),'Tag'),'nbt_plot')
            figure(figHandles(i))
            done=1;
        end
    end
    if ~done
        figH = figure();
       [ScreenWidth, ScreenHeight] = nbt_getScreenSize();
        set(figH,'units','pixels','Position', [0 0 ScreenWidth ScreenHeight ] )
        set(figH,'Tag','nbt_plot');
    end
    set(gcf,'numbertitle','off');
    set(gcf,'name','NBT: Plot Signals');
    clf
    
    %% apply frequency filter
    Signal=P{1}(interval,channels);
    if ~isempty(frequencyinterval)
        if isempty(filterorder)
            filterorder=4;
        end
        [b,a] = butter(filterorder,[frequencyinterval(1) frequencyinterval(2)]/(fs/2)) ;
        for i=1:length(channels)
            Signal(:,i) = filtfilt(b,a,Signal(:,i));
        end
    end

    %% get time scale axes

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

    %% create distance between signals for plotting
    if ~distance==0
        temp=distance:distance:size(Signal,2)*distance;
        temp=repmat(temp,size(Signal,1),1);
        Signal=Signal+temp;
    end

    %% plotting
    if strcmp(addcolors,'n')
        colors=jet(length(channels));
    end
    if strcmp(addcolors,'7')
        colors=lines(length(channels));
    end
    if strcmp(addcolors,'1')
        colors=repmat([0 0 1],length(channels),1);
    end
    
    for i=1:size(Signal,2)
        hh(i)=uicontextmenu;
        h(i)=plot(index,Signal(:,i),'color',colors(i,:),'buttondownfcn',{@showname},'displayname',['Channel ',num2str(channels(i))],'uicontextmenu',hh(i));
       if strcmp(linepoint,'P')
           hold on
           plot(index,Signal(:,i),'.','color',colors(i,:))
       end
        
        %         if isfield(Info.Interface,'EEG')
        %         text(index(1),Signal(1,i),[num2str(channels(i)) '(' Info.Interface.EEG.chanlocs(i).labels ')'],'fontsize',8)% 'BackgroundColor','w',
        %         end
        if isfield(Info.Interface,'EEG') && ~isempty(Info.Interface.EEG.chanlocs)
            uimenu(hh(i), 'Label', ['Channel ' num2str(channels(i)) '(' Info.Interface.EEG.chanlocs(i).labels ')']);
        else
            uimenu(hh(i), 'Label', ['Channel ' num2str(channels(i))])
        end
        hold on
    end
    
    if isfield(Info.Interface,'EEG') && ~isempty(Info.Interface.EEG.chanlocs)
        for i=1:size(Signal,2)
            label{i}=[num2str(channels(i)) '(' Info.Interface.EEG.chanlocs(i).labels ')'];
        end      
        set(gca,'YTick', temp(1,:), 'YTickLabel',label)

       
    else
        for i=1:size(Signal,2)
            label{i}=[num2str(channels(i))];
        end      
        set(gca,'YTick', temp(1,:), 'YTickLabel',label)
        

    end
    
    hold off
    xlabel(xl)
    set(gca,'position',[0.1300    0.1100    0.7432    0.8150])
    %   set(gca,'yticklabel',{''})
    
    %% set axes
    y=ylim;
    x=xlim;
    axis tight
    y=ylim;
    y(2)=2*median(max(Signal));
    y(1) = 0;
    ylim([y(1)-distance,y(2)+distance])
    yoriginal=ylim;
    xoriginal=xlim;
    %% legend
    if addlegend
        legend(h)
    end
    %%  figure properties
    set(gcf,'toolbar','figure')

    %% sliders and other UI controls

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

    uicontrol('Units', 'normalized', ...
        'callback',{@set_para},'position',[ 0.7900    0.9524    0.2107    0.0476],'string','Edit plot parameters')

    if isfield(Info.Interface,'EEG')
        uicontrol('Units', 'normalized', ...
            'callback',{@select_channel},'position',[ 0.5799    0.9524    0.2107    0.0476],'string','Select channel(s) to plot')
    end
    %% UI support functions

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

    function[]= showname(d1,d2)
        name=(get(gco,'displayname'));
        in=get(gca,'currentpoint');
        t=text(in(1,1),in(1,2),name);
        pause(2)
        set(t,'visible','off')
    end
end

function[]= set_para(d1,d2)
    options.Resize='on';
    options.WindowStyle='modal';
    options.Interpreter='tex';
    timescale1=timescale;
    interval1=interval;
    channels1=channels;
    distance1=distance;
    frequencyinterval1=frequencyinterval;
    filterorder1=filterorder;
    linepoint1=linepoint;
    out=inputdlg([{'timescale (samples, minutes or seconds)'},{'frequency filter interval (empty is no filter)'},{'Butterworth frequency filter order'},  ... 
        {'legend(1 or 0)'},{'colors (1, 7 or n)'},{'distance between signals'},{'channels to be plotted (index or "all")'}, ... 
        {'interval to be plotted (in sample number, or "all")'}, {'plot line (L) or points and line (P)'}], ...
        'Specify plot parameters', ones(1,9),[{num2str(timescale)},{num2str(frequencyinterval)},{num2str(filterorder)}, {num2str(addlegend)},{num2str(addcolors)}, ... 
        {num2str(distance)},{num2str(channels)},{[num2str(interval(1)),' ',num2str(interval(end))]},{linepoint}],options);
    if ~isempty(out)
        timescale =out{1};
        frequencyinterval=str2num(out{2});
        filterorder=str2num(out{3});
        addlegend=str2num(out{4});
        addcolors=num2str(out{5});
        distance=str2num(out{6});
        if strcmp(out{7},'all')
            channels=1:size(P{1},2);
        else
            channels=str2num(out{7});
        end
        temp=str2num(out{8});
        if strcmp(out{8},'all')
            interval=1:size(P{1},1);
        else
            interval=temp(1):temp(2);
        end
        linepoint=out{9};
        nbt_writeCommand(['nbt_plot(Signal,SignalInfo,',char(39),timescale,char(39),',','[',num2str(frequencyinterval),']', ... 
    ',',num2str(filterorder),',',num2str(addlegend),',',char(39),num2str(addcolors),char(39),',',num2str(distance),',',char(39),linepoint,char(39),')'])
        plotting
    end
end

function[] = select_channel(d1,d2)

    %%load locations
    [inty,intx]=nbt_loadintxinty(Info.Interface.EEG.chanlocs);

    %% make figure
    figure()
    axis off
    set(gcf,'Tag','select_channel');
    set(gcf,'numbertitle','off');
    set(gcf,'name','NBT: EEG Topography');
    scrsz = get(0,'ScreenSize');
    set(gcf,'Position',[scrsz(3)/2 scrsz(4)/3 scrsz(3)/2 scrsz(4)/2])
    set(gcf,'toolbar','figure')

    %% plot
    for i=1:length(intx)
        hh(i)=uicontextmenu;
        plot(intx(i),inty(i),'.','markersize',15,'displayname',num2str(i),'uicontextmenu',hh(i));
        uimenu(hh(i), 'Label', ['Plot Channel ',num2str(i)],'callback',@plot_channel);
        hold on
    end
    axis off
    hold off
    title('Right click on a channel to plot or select multiple channels by zooming in and pushing the button','fontweight','bold')
    uicontrol('Units', 'normalized', ...
        'callback',{@get_channels},'string','Plot channels in current axes','position',[0.0370    0.0262    0.3487    0.0476])
end

function get_channels(d1,d2)
    [inty,intx]=nbt_loadintxinty(Info.Interface.EEG.chanlocs);
    ax=axis;
    channels=[];
    for i=1:length(intx)
        if intx(i)<ax(2) && intx(i) > ax(1) && inty(i)<ax(4) && inty(i) > ax(3)
            channels=[channels,i];
        end
    end
    %         figure()
    plotting
end

function plot_channel(d1,d2)
    channelnr=str2num((get(gco,'displayname')));
    channels=channelnr;
    %         figure()
    plotting
end

end
