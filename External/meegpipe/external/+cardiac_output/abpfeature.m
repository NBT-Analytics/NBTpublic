function r = abpfeature(abp,OnsetTimes)
% ABPFEATURE  ABP waveform feature extractor.
%   r = ABPFEATURE(ABP,ONSETTIMES) extracts features from ABP waveform such
%   as systolic pressure, mean pressure, etc.
%
%   In:   ABP (125Hz sampled), times of onset (in samples)
%   Out:  Beat-to-beat ABP features
%           Col 1:  Time of systole   [samples]
%               2:  Systolic BP       [mmHg]
%               3:  Time of diastole  [samples]
%               4:  Diastolic BP      [mmHg]
%               5:  Pulse pressure    [mmHg]
%               6:  Mean pressure     [mmHg]
%               7:  Beat Period       [samples]
%               8:  mean_dyneg
%               9:  End of systole time  0.3*sqrt(RR)  method
%              10:  Area under systole   0.3*sqrt(RR)  method
%              11:  End of systole time  1st min-slope method
%              12:  Area under systole   1st min-slope method
% 
%   Usage:
%   - OnsetTimes must be obtained using wabp.m
%
%   Written by James Sun (xinsun@mit.edu) on Nov 19, 2005.


% if length(OnsetTimes)<30 % don't process anything if too little onsets
%     r = [];
%     return
% end

%% P_sys, P_dias
Window    = 40;
OT        = OnsetTimes(1:end-1);
BeatQty   = length(OT);

[MinDomain,MaxDomain] = init(zeros(BeatQty,Window));
for i=1:Window
    MinDomain(:,i) = OT-i+1;
    MaxDomain(:,i) = OT+i-1;
end
MinDomain(MinDomain<1) = 1;  % Error protection
MaxDomain(MaxDomain<1) = 1;

[P_dias Dindex]  = min(abp(MinDomain),[],2);
[P_sys  Sindex]  = max(abp(MaxDomain),[],2);

DiasTime         = MinDomain(sub2ind(size(MinDomain),(1:BeatQty)',Dindex));
SysTime          = MaxDomain(sub2ind(size(MaxDomain),(1:BeatQty)',Sindex));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pulse Pressure [mmHg]
PP         = P_sys - P_dias;

% Beat Period [samples]
BeatPeriod = diff(OnsetTimes);

% Mean,StdDev, Median Deriv- (noise detector)
dyneg          = diff(abp);
dyneg(dyneg>0) = 0;

[MAP,stddev,mean_dyneg] = init(zeros(BeatQty,1));
for i=1:BeatQty
    interval       = abp(OnsetTimes(i):OnsetTimes(i+1));
    MAP(i)         = mean(interval);
    stddev(i)      = std(interval);

    dyneg_interval = dyneg(OnsetTimes(i):OnsetTimes(i+1));
    dyneg_interval(dyneg_interval==0) = [];
    if min(size(dyneg_interval))==0
        dyneg_interval = 0;
    end
    mean_dyneg(i)  = mean(dyneg_interval);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Systolic Area calculation using 0.3*sqrt(RR)
RR                  = BeatPeriod/125;  % RR time in seconds
sys_duration        = 0.3*sqrt(RR);
EndOfSys1           = round(OT + sys_duration*125);
SysArea1            = localfun_area(abp,OT,EndOfSys1,P_dias);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Systolic Area calculation using 'first minimum slope' method
SlopeWindow         = 35;
ST                  = EndOfSys1; % start 12 samples after P_sys

if ST(end) > (length(abp)-35)   % error protection
    ST(end) = length(abp)-35;
end

SlopeDomain = zeros(BeatQty,SlopeWindow);
for i=1:SlopeWindow
    SlopeDomain(:,i) = ST+i-1;
end
% y[n] = x[n]-x[n-1]
Slope              = diff(abp(SlopeDomain),1,2);
Slope(Slope>0)     = 0; % Get rid of positive slopes

[MinSlope index]   = min(abs(Slope),[],2);
EndOfSys2          = SlopeDomain(sub2ind(size(SlopeDomain),(1:BeatQty)',index));
SysArea2           = localfun_area(abp,OT,EndOfSys2,P_dias);

% OUTPUT:
r = [SysTime'
     P_sys'
     DiasTime'
     P_dias'
     PP'
     MAP'
     BeatPeriod'
     mean_dyneg'
     EndOfSys1'
     SysArea1'
     EndOfSys2' 
     SysArea2']';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper function:

function SysArea = localfun_area(abp,onset,EndSys,P_dias)
%% Input:  abp,
%%         onset, P_dias, end of systole, beat duration in unit of samples, same length
%% Output: systolic area, warner correction factor

BeatQty = length(onset);
SysArea = init(zeros(BeatQty,1));
for i=1:BeatQty
    SysArea(i) = sum(abp(onset(i):EndSys(i))); % faster than trapz below
    %b(i) = trapz(abp(onset(i):EndSys(i)));
end

SysPeriod  = EndSys     - onset;

% Time scale and subtract the diastolic area under each systolic interval
SysArea = (SysArea - P_dias.*SysPeriod)/125; % Area [mmHg*sec]
end

% for initializing a variable
function varargout = init(z)
for i=1:nargout
    varargout(i) = {z};
end
end