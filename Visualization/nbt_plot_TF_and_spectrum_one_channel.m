function []=nbt_plot_TF_and_spectrum_one_channel(varargin)

% nbt_plot_TF_and_spectrum_one_channel(Signal,Info,channel_nr,frequency_interval,nFFT,pdf_plot)
%
% This function plots a time frequency representation and power spectrum of
% signal in channel channel_nr in the Signal object, in the frequency interval frequency_interval;
%
% Usage:
%
% nbt_plot_TF_and_spectrum_one_channel(Signal,Info,channel_nr,frequency_int
% erval,nFFT,pdf_plot)
% or
% nbt_plot_TF_and_spectrum_one_channel(Signal,Info)
%
% Inputs:
%-  Signal is a NBT Signal matrix
% - Info is corresponding Info object
%-  channel_nr is the number of the channle you want to use
% - frequency_interval is the frequency interval that is used too depict the
%       time-frequency representation and the power spectrum.
% - nFFT is number of fast fourier transforms, higher this number and the frequency resolution goes up,
%         but the time resolution goes down
% - pdf_plot. If = 1, then a pdf plot will be generated in the current directory, and opened.
%
% See also:
% nbt_plot

%------------------------------------------------------------------------------------
% Originally created by Rick Jansen (2010), see NBT website for current email address
%------------------------------------------------------------------------------------

% Copyright (C) 2010  Neuronal Oscillations and Cognition group,
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

F_step =1;
P=varargin;
nargs=length(P);
Signal=P{1};
Info=P{2};

if (nargs<3 | isempty(P{3})) channel_nr=1; else channel_nr = P{3}; end;
if (nargs<4 | isempty(P{4})) frequency_interval = [1 45]; else frequency_interval = P{4}; end;
if (nargs<5 | isempty(P{5})) color = []; else color = P{5}; end;
if (nargs<6 | isempty(P{6})) nFFT = min(size(Signal,1)/5,2^10); else nFFT = P{6}; end;
if (nargs<7 | isempty(P{7})) pdf_plot = 0; else pdf_plot= P{7}; end;
if (nargs<8 | isempty(P{8})) save_directory =cd; else save_directory = P{8}; end;
if (nargs<9 | isempty(P{9})) tf_type='m' ; else tf_type = P{9}; end;

disp(' ')
disp('Command window code:')
disp('nbt_plot_TF_and_spectrum_one_channel(Signal,SignalInfo)')
disp(' ')

type='p';% p=power, a = amplitude


%--- remove artifact intervals:

if isfield(Info.Interface,'noisey_intervals')
    intervals=Info.Interface.noisey_intervals;
    good=1:size(Signal,1);
    for i=1:size(intervals,1)
        good =setdiff(good, intervals(i,1):intervals(i,2));
    end
    Signal=Signal(good,:);
end

interval=1:size(Signal,1);
set_para([],[]) % ask for parameters and make plot

function plotting
     %--- get figure handle

        done=0;
        figHandles = findobj('Type','figure');
        for i=1:length(figHandles)
            if strcmp(get(figHandles(i),'Tag'),'TF')
                figure(figHandles(i))
                done=1;
            end
        end
        if ~done
            figure()
            set(gcf,'Tag','TF');
        end
        set(gcf,'numbertitle','off');
        set(gcf,'name','NBT: Single Channel Time-Frequency and Spectrum Plots');
        clf
        
    %--- TF plot
    subplot(2,1,1)
    if strcmp(tf_type,'m')
        mtcsg(Signal(interval,channel_nr),nFFT,Info.converted_sample_frequency,[],[],[],[],[],frequency_interval,type);
    else
       
        fs=Info.converted_sample_frequency;
        [W,p,s] = nbt_wavelet33(Signal(interval,channel_nr),1/fs,1,F_step,frequency_interval(1)*1.033,frequency_interval(2)*1.033);
        if strcmp(type,'a')
            W=sqrt(W);
        end
        W=int16(abs(W));
        t = 1/fs:1/fs:length(Signal(interval,channel_nr))/fs;
        f = frequency_interval(1):F_step:frequency_interval(2);
        imagesc(t,f,flipud(W));
        axis xy
        ylabel('Frequency (Hz)')
        xlabel('Time (seconds)')
    end
    title(['Time-frequency representation of channel ',num2str(channel_nr),' from experiment ' Info.file_name],'interpreter','none','fontweight','bold')
    colorbar
    x=xlim;
    y=ylim;
    if strcmp(type,'a')
        text(x(2),y(1)-(y(2)-y(1))/10,'Amplitude (\muV), arbitrary units')
    else
        text(x(2),y(1)-(y(2)-y(1))/10,'power (\muV^2), arbitrary units')
    end
    if(isempty(color))
        color=caxis;
        caxis([color(1) color(2)]);
        color = caxis;
    else
        caxis([color(1) color(2)])
    end

    %--- Fourier spectrum
    subplot(2,3,4)
    [p,f]=pwelch(Signal(interval,channel_nr),hamming(nFFT),0,nFFT,Info.converted_sample_frequency);
    ind=find(f>frequency_interval(1)&f<frequency_interval(2));
    if strcmp(type,'a')
        p=sqrt(p);
    end
    plot(f(ind),p(ind))
    xlabel('Frequency (Hz)')
    set(gca,'xlim',[frequency_interval(1),frequency_interval(2)])
    if strcmp(type,'a')
        title('Amplitude spectrum','fontweight','bold')
        ylabel('Amplitude (\muV)')
    else
        title('Power spectrum','fontweight','bold')
        ylabel('Power (\muV^2)')
    end

    %--- EEG channel locations
    if isfield(Info.Interface,'EEG')
        %load locations
        [inty,intx]=nbt_loadintxinty(Info.Interface.EEG.chanlocs);

        % plot
        subplot(2,3,6)
        for i=1:length(intx)
            hh(i)=uicontextmenu;
            pp(i)=plot(intx(i),inty(i),'.','markersize',15,'displayname',num2str(i),'uicontextmenu',hh(i));
            uimenu(hh(i), 'Label', ['Plot Channel ',num2str(i)],'callback',@plot_eeg_channel);
            hold on
        end
        set(pp(channel_nr), 'color','red')
        axis off
        hold off
        tt=title('Right click to select a channel','fontweight','bold','vertical', 't');
    end

    %--- button & uicontrols

    if isfield(Info.Interface,'EEG') %% eeg signal;
        for chl = 1:size(Signal,2)
            chanlocs{chl,1} = Info.Interface.EEG.chanlocs(chl).labels;
        end
        u(1)=uicontrol('Units', 'normalized', ...
            'style','listbox','string',chanlocs, 'position',[0.4 0 0.3 0.05], 'callback',@plot_channel,'position',[0.4339    0.1136    0.0804    0.2745],'value',channel_nr);
    else
        u(1)=uicontrol('Units', 'normalized', ...
            'style','listbox','string',num2str((1:size(Signal,2))'),'position',[0.4 0 0.3 0.05], 'callback',@plot_channel,'position',[0.4339    0.1136    0.0804    0.2745],'value',channel_nr);
    end

    u(2)=uicontrol('style','text','string','Select channel','Units','normalized','fontweight','bold','position',[0.3762    0.42    0.1892    0.0350],'fontsize',10);% ,'backgroundcolor',get(gcf,'color')

    u(3)=uicontrol('Units', 'normalized', ...
        'callback',{@set_para},'position',[0.7864    0.0000    0.2107    0.0476],'string','Edit plot parameters');

    u(4)= uicontrol('Units', 'normalized', ...
        'Style','slider', ...
        'callback',{@set_c_axis},...
        'min',color(1),'max',color(2),...
        'value',color(2)-1,...
        'position',[ 0.7795    0.4999    0.0991    0.0367]);

    %--- pdf
    if pdf_plot==1
        set(u,'visible','off')
        if isfield(Info.Interface,'EEG')
            set(tt,'visible','off')
            %set(pp,'visible','off')
        end
        print(gcf,'-dpdf',[save_directory,'/',Info.file_name,' TF_and_spectrum_channel ',num2str(channel_nr),' between ',num2str(frequency_interval(1)),' and ',num2str(frequency_interval(2)),' Hz.pdf'])
        if(ispc)
            winopen([save_directory ,'/',Info.file_name,' TF_and_spectrum_channel ',num2str(channel_nr),' between ',num2str(frequency_interval(1)),' and ',num2str(frequency_interval(2)),' Hz.pdf'])
        end
        %          set(pp,'visible','on')
        set(u,'visible','on')
        if isfield(Info.Interface,'EEG')
            set(tt,'visible','on')
            %set(pp,'visible','on')
        end
    end

    % support functions (nested functions)  %%

    function plot_channel(d1,d2)
        channel_nr=get(u(1), 'value');
        plotting
    end

    function set_c_axis(d1,d2)
        subplot(2,1,1)
        caxis([color(1) get(u(4),'value')])
        color = caxis;
    end

    function plot_eeg_channel(d1,d2)
        channel_nr=str2num((get(gco,'displayname')));
        plotting
    end

end

function[]= set_para(d1,d2)
    options.Resize='on';
    options.WindowStyle='modal';
    options.Interpreter='tex';
    out=inputdlg([{'frequency interval'},{'color interval (empty for automatic)'},{'nFFT'}, {'Frequency step'}, {'print PDF (0 or 1)'},{'wavelet (w) or multitaper (m)'},{'Interval to be plotted (in sample numbers)'},{'plot power (p) or amplitude (a)'},{'channel number'}], ...
        'Specify plot parameters', ones(1,9),[{num2str(frequency_interval)},{num2str(color)},{num2str(nFFT)}, {num2str(F_step)} , {num2str(pdf_plot)},{tf_type},{num2str([interval(1) interval(end)])},{type},{num2str(channel_nr)}],options);

    if ~isempty(out)
        frequency_interval=str2num(out{1});
        color = str2num(out{2});
        nFFT= str2num(out{3});
        F_step = str2num(out{4});
        pdf_plot=str2num(out{5});
        tf_type=out{6};
        temp=str2num(out{7});
        interval=temp(1):temp(2);
        type=out{8};
        channel_nr=str2num(out{9});
        plotting
    end
end
end
