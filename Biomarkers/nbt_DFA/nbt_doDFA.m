% [DFAobject,DFA_exp] = nbt_Scaling_DFA(DFAobject, Signal, InfoObject,
% FitInterval, CalcInterval, DFA_Overlap, DFA_Plot, ChannelToPlot, res_logbin);
% Detrended Fluctuation Analysis - Part of the NBT - toolbox
%% Input parameters
% DFAobject         : A DFAobject
% Signal            : The signal
% InfoObject        : The InfoObject that belongs to your signal.
% FitInterval(1)	: smallest time scale (window size) to include in power-law fit (in units of seconds!)
% FitInterval(2)	: largest time scale (window size) to include in power-law fit (in units of seconds!).
% CalcInterval(1) 	: minimum time-window size computed (in units of seconds!).
% CalcInterval(2) 	: maximum time-window size computed (in units of seconds!).
% DFA_Overlap		: amount of DFA_Overlap between windows (to obtain higher SNR for the fluctuation estimates).
% DFA_Plot		    : should either be an axeshandle or an integer > 0. If
% no plot should be produce use DFA_plot = 0;
% ChannelToPlot     : The channel you want to plot
% res_logbin        : number of bins pr decade (use 10)
%% output parameters
% DFAobject     : Return the DFAobject with updated information.
% DFA_exp		: The DFA power-law exponent.
%
% Example:
%
% References:
% % Method references...
%
% Peng et al., Mosaic organization of DNA nucleotides, Phys. rev. E (49), 1685-1688 (1994).
% or for a better description: Peng et al., Quantification of scaling exponents and crossover phenomena
% in nonstationary heartbeat time series, Chaos (5), 82-87 (1995).
%
%
% See also:
%   NBT_DFA,

%------------------------------------------------------------------------------------
% Originally created by Klaus Linkenkaer-Hansen (2001), see NBT website (http://www.nbtwiki.net) for current email address
% Improved code - Simon-Shlomo Poil (2008)
% Imported to NBT format. - Simon-Shlomo Poil (2009)
%------------------------------------------------------------------------------------
% 
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) 2001  Klaus Linkenkaer-Hansen  (Neuronal Oscillations and Cognition group, 
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
% -


function [DFAobject,DFA_exp] = nbt_doDFA(Signal, InfoObject, FitInterval, CalcInterval, DFA_Overlap, DFA_Plot, ChannelToPlot, res_logbin);


DFAobject = nbt_DFA(size(Signal,2));
Signal = nbt_RemoveIntervals(Signal,InfoObject);

%% Get or set default parameters...
if (isempty(res_logbin))
    res_logbin = DFAobject.res_logbin;	% number of bins pr decade, i.e., the spacing of the logarithmic scale.
else
    DFAobject.res_logbin = res_logbin;
end

% force fixed values for FitInterval and CalcInterval
% FitInterval=[1 20];
% CalcInterval=[0.1 110];

% get parameters from Signalobject
Fs = InfoObject.converted_sample_frequency;
DFAobject.Condition = InfoObject.condition;
% set parameters in DFAobject
DFAobject.FitInterval = FitInterval;
DFAobject.CalcInterval = CalcInterval;
DFAobject.Overlap = DFA_Overlap;

%Set information from InfoObject
DFAobject.ReseacherID = InfoObject.researcherID;
DFAobject.ProjectID = InfoObject.projectID;
DFAobject.SubjectID = InfoObject.subjectID;
DFAobject.Condition = InfoObject.condition;



%******************************************************************************************************************
%% Begin analysis
% Find DFA_x


% Defining window sizes to be log-linearly increasing.
d1 = floor(log10(CalcInterval(1)*Fs));
d2 = ceil(log10(CalcInterval(2)*Fs));
DFA_x_t = round(logspace(d1,d2,(d2-d1)*res_logbin));	% creates vector from 10^d1 to 10^d2 with N log-equidistant points.
DFA_x = DFA_x_t((CalcInterval(1)*Fs <= DFA_x_t & DFA_x_t <= CalcInterval(2)*Fs));	% Only include log-bins in the time range of interest!
DFAobject.DFA_x = DFA_x;


%% Do check of FitInterval
if ((DFA_x(1)/Fs)>FitInterval(1) || (DFA_x(end)/Fs)<FitInterval(2))
    disp([ DFA_x(1) DFA_x(end)]/Fs)
    error('Scaling_DFA:WrongCalcInterval','The CalcInterval is smaller than the FitInterval')
end

%% The DFA algorithm...
ChannelID = 1;

for ChannelID = 1:(size(Signal,2)) % loop over channels
    disp(ChannelID);
    if (isempty(DFAobject.DFA_y{GetChannelID,1}))
        DFA_y = nan(size(DFA_x,2),1);
        %% Do check of CalcInterval
%         if (CalcInterval(2) > 0.1*length(Signal(:,GetChannelID))/Fs)
%             display('The upper limit of CalcInterval is larger than the recommended 10% of the signal lenght')
%         end
        
        y = Signal(:,GetChannelID)./mean(Signal(:,GetChannelID));
        %y = Signalobject(GetChannelID)-mean(Signalobject(GetChannelID),1);		% First we convert the time series to a series of fluctuations y(i) around the mean.
        y = y-mean(y);
        y = cumsum(y);         		% Integrate the above fluctuation time series ('y').
        for i = 1:size(DFA_x,2);				% 'DFA_x(i)' is the window size, which increases uniformly on a log10 scale!
            D = zeros(floor(size(y,1)/(DFA_x(i)*(1-DFA_Overlap))),1);		% initialize vector for temporarily storing the root-mean-square of each detrended window.
            tt = 0;
            for nn = 1:round(DFA_x(i)*(1-DFA_Overlap)):size(y,1)-DFA_x(i);	% we are going to detrend all windows in steps of 'n*(1-DFA_Overlap)'.
                tt=tt+1;
                D(tt) = (mean(fastdetrend(y(nn:nn+DFA_x(i))).^2,1))^(1/2);		% the square of the fluctuation around the local trend (of the window).
            end
            DFA_y(i) = mean(D(1:tt),1);						% the root-mean-square fluctuation of the integrated and detrended time series
        end  					  	       			% -- the F(n) in eq. (1) in Peng et al. 1995.
        DFAobject.DFA_y{GetChannelID,1} = DFA_y;
    end
end


%% Fitting power-law
for ChannelID = 1:(size(Signal,2)) % loop over channels
    DFA_y = DFAobject.DFA_y{GetChannelID,1};
    DFA_SmallTime_LogSample = min(find(DFA_x>=CalcInterval(1)*Fs));		%
    DFA_LargeTime_LogSample = max(find(DFA_x<=CalcInterval(2)*Fs));
    DFA_SmallTimeFit_LogSample = min(find(DFA_x>=FitInterval(1)*Fs));
    DFA_LargeTimeFit_LogSample = max(find(DFA_x<=FitInterval(2)*Fs));
    X = [ones(1,DFA_LargeTimeFit_LogSample-DFA_SmallTimeFit_LogSample+1)' log10(DFA_x(DFA_SmallTimeFit_LogSample:DFA_LargeTimeFit_LogSample))'];
    Y = log10(DFA_y(DFA_SmallTimeFit_LogSample:DFA_LargeTimeFit_LogSample));
    DFA_exp = X\Y; %least-square fit
    DFA_exp = DFA_exp(2);
    DFAobject.MarkerValues(GetChannelID,1) = DFA_exp;
end

DFAobject = nbt_UpdateBiomarkerInfo(DFAobject, InfoObject);


%% Plotting
if (DFA_Plot ~=0)
    if ~ishandle(DFA_Plot)		%see if any figure handle is set
        figure(DFA_Plot)
        DFA_Plot = axes;
    end
    ChannelID = ChannelToPlot;
    DFA_y = DFAobject.DFA_y{GetChannelID,1};
    disp('Plotting Channel')
    disp(GetChannelID)
    try
        axes(DFA_Plot)
    catch
        figure(DFA_Plot)
        axes(gca)
    end
    hold on
    plot(log10(DFA_x(DFA_SmallTimeFit_LogSample:DFA_LargeTimeFit_LogSample)/Fs),log10(DFA_y(DFA_SmallTimeFit_LogSample:DFA_LargeTimeFit_LogSample)),'ro')
    delete(findobj(DFA_Plot,'Type','Line','-not','Marker','o')) % delete any redundant lines
    LineHandle=lsline;
    try % delete any fits to the black points if they exist
        BlackHandle=findobj(DFA_Plot,'Color','k');
        for i=1:length(BlackHandle)
            delete(LineHandle(LineHandle == BlackHandle(i)))
        end
    catch
    end
    plot(log10(DFA_x(DFA_SmallTime_LogSample:DFA_LargeTime_LogSample)/Fs),log10(DFA_y(DFA_SmallTime_LogSample:DFA_LargeTime_LogSample)),'k.')
    grid on
%     zoom on
    axis([log10(min(DFA_x/Fs))-0.1 log10(max(DFA_x/Fs))+0.1 log10(min(DFA_y(3:end)))-0.1 log10(max(DFA_y))+0.1])
    xlabel('log_{10}(time), [Seconds]','Fontsize',12)
    ylabel('log_{10} F(time)','Fontsize',12)
    title(['DFA-exp=', num2str(DFAobject.MarkerValues(GetChannelID,1))],'Fontsize',12)
end

%% Nested functions part
    function ChID = GetChannelID
        % function finds the current ChannelID
        if ( InfoObject.channelID ~= 0)
            ChID = InfoObject.channelID;
        else
            ChID = ChannelID;
        end
    end
end

%% Supporting functions
function signal = fastdetrend(signal)
% A simple and fast detrend, see also the supporting function fastdetrend
% in the supporting functions folder
persistent a
persistent N
if (isempty(a) || size(signal,1) ~= N)
    N = size(signal,1);
    a = [zeros(N,1) ones(N,1)];
    a(1:N) = (1:N)'/N;
end
signal = signal - a*(a\signal);
end


