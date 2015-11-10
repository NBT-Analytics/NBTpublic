%% FindOscBursts function - finds oscillation bursts
%
% OscBobject =  nbt_FindOscBursts(OscBobject, Signalobject, threshold, Pxx, WindowSwitch, WindowSize, ShapeSwitch, PeakFitObject, Fs, SubjectID)
%% Input:
% OscBobject: OscBursts object create using OscBursts
% Signalobject : NBTsignal object, or the amplitude-envelope with 'Time' in
% 1st dimension, and ChannelID  2nd dimension.
% Threshold: The threshold level, threshold = 1 is median. threshold = 0.5
% is 0.5 times median.
% Pxx: The cumulative percentile. E.g. Pxx = 0.95 will return the
% 95th-percentile life-time
% WindowSwitch (logical) : 1 if the threshold should be calculated in
% windows along the signal
% WindwoSize : The size of windows if WindowSwitch is 1.
% ShapeSwitch: (experimental)
% PeakFitObject: (experimental)
% Fs : The sampling frequency, should only be given if a NBTSignal object is not
% used
% SubjectID: The Subject ID, should only be given if a NBTSignal object is not
% used
%
%% Output:
% OscBobject: OscBurst biomarker object, or if a NBTsignal object is not
% used a structure with:
%.liftimes - the lifetime of each burst along the signal in each channel in
%timesteps
%.CumulativeLifetime.MarkerValue - The Pxx percentile lifetime in [ms]
%.CumulativeLifetime.Pxx - The Pxx value
%.DateLastUpdate - The date when the analysis was done
%
%% Copyright (c) 2008,  Simon-Shlomo Poil (Center for Neurogenomics and Cognitive Research (CNCR), VU University Amsterdam)
%% ChangeLog - see version control log for details
% 09-Sep-2009: Simon-Shlomo Poil. Branched code into experimental and
% stable branch - added help and support for standalone use.

function OscBobject =  nbt_doOscBursts(Signalobject, InfoObject, threshold, Pxx, WindowSwitch, WindowSize, ShapeSwitch, PeakFitObject, LowMemSwitch , varargin)

%% Plan
% Support non-NBT access
% goal find life-times and waiting times.
% find size ? yes^




OscBobject = nbt_OscBursts(size(Signalobject,2));
Signalobject = nbt_RemoveIntervals(Signalobject,InfoObject);

%% input checks
narginchk(6,11)

%% Support for off-line output
if(isempty(Signalobject))
    if (OscBobject.Pxx ~= Pxx)
        NumChannels = size(OscBobject.CumulativeLifetime,2);
            for ChId = 1:NumChannels
                OscBobject.CumulativeLifetime(ChId) = (1000/OscBobject.Fs).*(nbt_cumulative_sum_percentile(OscBobject.lifetimes{ChId},Pxx));
                OscBobject.CumulativeSize(ChId) = (nbt_cumulative_sum_percentile(OscBobject.sizes{ChId},Pxx));
            end
    end
    return
end

%% Get info from Signal object with fallback
try 
    if(~isempty(threshold))
        OscBobject.threshold = threshold;
    end
    if(~isempty(Pxx))
        OscBobject.Pxx =  Pxx;
    end
    if(~isempty(WindowSwitch))
        OscBobject.WindowSwitch = WindowSwitch;
    end
    if(~isempty(WindowSize))
        OscBobject.WindowSize = WindowSize;
    end
    Fs = InfoObject.converted_sample_frequency;
    OscBobject = nbt_UpdateBiomarkerInfo(OscBobject, InfoObject);
catch
    Fs = varargin{1};
    SubjectID = varargin{2};
end

%transfer default values or current values to variables.
Pxx = OscBobject.Pxx;
WindowSwitch = OscBobject.WindowSwitch;
WindowSize = OscBobject.WindowSize;
threshold = OscBobject.threshold;


%% Find life and waiting-times
% add option to extract individual bursts for further analysis.

for ChannelID=1:size(Signalobject,2)
    %% Life-times
    try
        SignalToTest = Signalobject(:,GetChannelID);
    catch % only one channel in signal
        SignalToTest = Signalobject(:,ChannelID);
    end
    switch WindowSwitch
        case 0
            SignalToTest(SignalToTest < threshold*median(SignalToTest)) = 0;
        case 1
            MedianSignal=nbt_FloatWindowAnalysis(SignalToTest, WindowSize);
            SignalToTest(SignalToTest < threshold*MedianSignal) = 0;
    end
    switch ShapeSwitch
        case 0
            [OscBobject.lifetimes{GetChannelID}, OscBobject.sizes{GetChannelID}] = nbt_TimeAnalysis(SignalToTest);
        case 1
            [OscBobject.lifetimes{GetChannelID}, OscBobject.sizes{GetChannelID}, AvalancheShape]= nbt_TimeAnalysisWithShape(SignalToTest);
            OscBobject.ShapeMarker(GetChannelID) = nbt_cumulative_sum_percentile(nbt_FindCoverTime(AvalancheShape),Pxx);
        otherwise
            error('ShapeSwitch can only be zero or one')
    end

    OscBobject.CumulativeLifetime(GetChannelID) = (1000/Fs).*(nbt_cumulative_sum_percentile(OscBobject.lifetimes{GetChannelID},Pxx));
    OscBobject.CumulativeSize(GetChannelID) = (nbt_cumulative_sum_percentile(OscBobject.sizes{GetChannelID},Pxx));

    try
        if (~isempty(PeakFitObject)) %normalize with peakfrequeny if a PeakFitObject has been given.
            OscBobject.CumulativeLifetime(GetChannelID, SubjectID) = OscBobject.CumulativeLifetime(GetChannelID, SubjectID)/(1000/PeakFitObject.AlphaFreq(GetChannelID));
        end
    catch
    end

    OscBobject.IntraBurstsCorr(GetChannelID) = nbt_FindBurstCorrelations(OscBobject.lifetimes(GetChannelID));
    
    %% Waiting-times
         temp = SignalToTest;
         SignalToTest(temp == 0) = 1;
         SignalToTest(temp ~= 0) = 0;
         OscBobject.waitingtimes{GetChannelID} = nbt_TimeAnalysis(SignalToTest);

    %% if low memory use LowMemSwitch to remove lifetimes, sizes etc.
    try
        if(LowMemSwitch)
            OscBobject.lifetimes{GetChannelID} = [];
            OscBobject.sizes{GetChannelID} = [];
            OscBobject.waitingtimes{GetChannelID} = [];
        end
    catch
    end
end

%% Nested functions part
    function ChID = GetChannelID()
        % function finds the current ChannelID
        try
            if ( Signalobject.ChannelID ~= 0)
                ChID = InfoObject.channelID;
            else
                ChID = ChannelID;
            end
        catch
            ChID = ChannelID;
        end
    end
end



%% Sub Functions
function [dura, BurstSize] = nbt_TimeAnalysis(input)
%% Lifetime Analysis function
%% Prepare
persistent duralength;
ThresholdValue =min(input(input~=0));
a = 0;
m = 2; % define the start point of the analysis
stopflag = 0;
nt = length(input);
if(~isempty(duralength))
    dura = zeros(round(duralength*nt),1); % the duration vector
    BurstSize = zeros(round(duralength*nt),1);
else
    dura = zeros(round(0.3*nt),1);
    BurstSize = zeros(round(0.3*nt),1);
end
%% Find the avalance structure
%try
while stopflag ~= 1
    if (input(m)> 0 && input(m-1)== 0)
        %new avalance
        a = a + 1;
        dura(a) = 1;
        BurstSize(a) = input(m) - ThresholdValue;
        while (input(m+1)~= 0) % calc. until boundary condition
            dura(a) = dura(a) + 1; %update the life/waiting time vector
            BurstSize(a) = BurstSize(a) + input(m+1) - ThresholdValue;
            m = m + 1;
            if m >= nt-1
                break
            end
        end
    end
    if m+1 >= nt
        stopflag = 1;
    end
    m = m + 1;
end
%catch
%    warning('Error in Oscillation burst analysis')
%end

dura = dura(dura ~= 0);
BurstSize = BurstSize(BurstSize ~=0);
duralength = (a/nt) + 0.01;
dura = dura(1:(end-1)); % to avoid end effects
BurstSize = BurstSize(1:(end-1));
end

function [dura, BurstSize, AvalancheShape]=nbt_TimeAnalysisWithShape(input)
%% Lifetime Analysis function
%% Prepare
persistent duralength;
a = 0;
m = 2; % define the start point of the analysis
stopflag = 0;
nt = length(input);
if(~isempty(duralength))
    dura = zeros(round(duralength*nt),1); % the duration vector
    BurstSize = zeros(round(duralength*nt),1);
else
    dura = zeros(round(0.3*nt),1);
    BurstSize = zeros(round(0.3*nt),1);
end% the duration vector % could be improved (based on last vector e.g.)
AvalancheShape = cell(round(0.06*nt),1);
ThresholdLevel =min(input(input~=0));
%% Find the avalance structure
%try
    while stopflag ~= 1
        if (input(m)> 0 && input(m-1)== 0)
            %new avalance
            a = a + 1;
            dura(a) = 1;
            BurstSize(a) = input(m) - ThresholdLevel;
            AvalancheShape{a,1} = input(m)-ThresholdLevel;
            while (input(m+1)~= 0) % calc. until boundary condition
                dura(a) = dura(a) + 1; %update the life/waiting time vector
                BurstSize(a) = BurstSize(a) + input(m+1) - ThresholdLevel;
                m = m + 1;
                AvalancheShape{a,1} = [AvalancheShape{a,1}; input(m)-ThresholdLevel];
                if m >= nt-1
                    break
                end
            end
        end
        if m+1 >= nt
            stopflag = 1;
        end
        m = m + 1;
    end
%catch
 %   warning('Error in Oscillation burst analysis')
%end

dura = dura(dura ~= 0);
dura = dura(1:(end-1)); % to avoid end effects
BurstSize = BurstSize(BurstSize ~=0);
BurstSize = BurstSize(1:(end-1));
end

function [pp] = nbt_cumulative_sum_percentile(H,p_level)
if(max(H)<=1)
    [pdf,bin] = hist(H,0:0.01:max(H));
else
    [pdf,bin] = hist(H,1:max(H));
end
% normalize and find cumulative sum
pdf = pdf./sum(pdf);
pdf_cumsum = cumsum(pdf);

temp_var = find(pdf_cumsum <= p_level) ;

try %new improved method using interpolation added 25. August 2009
    pp = interp1(pdf_cumsum(temp_var(end):(temp_var(end)+1)),bin(temp_var(end):(temp_var(end)+1)),p_level,'spline');
catch % with fall-back to old method
    try
        warning('using old Pxx medthod')
        upp = abs(pdf_cumsum(temp_var(end)+1)-p_level);
        dpp = abs(pdf_cumsum(temp_var(end))-p_level);
        if(upp >= dpp)
            pp = bin(temp_var(end));
        else
            pp = bin(temp_var(end)+1);
        end
    catch
        pp =NaN;
    end
end
end

%% Find CoverTime

function Covertime=nbt_FindCoverTime(input)
Covertime = nan(size(input,1),1);
for i=1:size(input,1)
    Covertime(i) = median(input{i,1}./sum(input{i,1}));
end
end

%% Calc. the MedianSignal using a windowing function
function MedianSignal=nbt_FloatWindowAnalysis(Signal, WindowSize)

Interval = [1 WindowSize];
MedianSignal = nan(size(Signal));

for i=1:floor(length(Signal)/WindowSize)
    MedianSignal(Interval(1):Interval(2)) = median(Signal(Interval(1):Interval(2)));
    Interval = Interval + WindowSize;
end
end

function  output=nbt_FindBurstCorrelations(lifetimes)
try
output = corr(lifetimes{1,1}(1:(end-1)),lifetimes{1,1}(2:end),'type','spearman');
catch
    output = nan;
end
end


