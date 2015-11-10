function [CO,flow] = est11_mf(abp, onset, MAP, HR, age, gender, endSys)
% EST11_mf  CO estimator 11: Wesseling's non-linear, time-varying 3-element model
%
%   In:  ABP       <kx1>     vector  --- abp waveform
%        ONSET     <(n+1)x1> vector  --- beat-to-beat onset time in samples
%        MAP       <nx1>     vector  --- beat-to-beat mean arterial pressure
%        HR        <nx1>     vector  --- beat-to-beat heart rate
%        AGE       <1x1>     scalar  --- age
%        GENDER    <1x1>     scalar  --- male=1, female=2
%
%   Out: CO        <nx1>     vector  --- estimated beat-by-beat CO
%        FLOW      <kx1>     vector  --- instantaneous flow (125 Hz)
%
%   Written by James Sun (xinsun@mit.edu) on Nov 19, 2005.
%   - v2.0 - 3/29/06 - uses state-space implementation, various bug fixes
%   - v2.1 - 5/10/06 - stroke volume is sum of positive flow only

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% constants
rho = 1.05;            % density of blood: 1.05 [g/cc]
l   = 80;              % aortic effective length [cm]
P1  = 57 - 0.44*age;   % pressure for arc-tangent relationship
switch gender
    case 1
        P0   = 76 - 0.89*age;   % male
        Amax = 5.62;
    case 2
        P0   = 72 - 0.89*age;   % female
        Amax = 4.12;
end

% initial conditions
R  = 100/50; % 2 [mmHg*s/cc]
x  = 0;      % initial condition for state variable

%% minor business
flow   = zeros(length(abp),1);
CO     = zeros(length(MAP),1);
abp    = double(abp);   % change to double FP precision
HR     = double(HR);
MAP    = double(MAP);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% main loop (runs Wesseling's model, updating nonlinear parameters for each iteration)
k=1;
for i=1:length(abp)
    
    %% first parameters
    P  = abp(i);        % ABP sample [mmHg]
    m  = (P-P0)/P1;
    A  = Amax*(0.5+atan(m)/pi); % aortic cross-sectional area [cm^2]
    Cp = Amax/(pi*P1*(1+m^2));  % aortic compliance per unit length [cm^2/mmHg]

    %% circuit parameters
    Z  = sqrt(rho/(1333*A*Cp)); % aortic characteristic impedance  [mmHg*s/cc]
    C  = l*Cp;                  % arterial compliance (windkessel) [cc/mmHg]

    %% state-space setup
    AA = -(1/R+1/Z)/C;
    BB = -1/(Z^2*C);
    CC = 1;
    DD = 1/Z;

    %% run simulation
    [y,x]   = SSsolve(AA,BB,CC,DD,P,[0 0.008],x(end));
    flow(i) = y(end);

    %% Update MAP, CO, R
    if k+1 > length(onset)
        break
    elseif i >= onset(k+1)
        pos_flow = flow(onset(k):endSys(k));
        SV    = sum(pos_flow)/125;
        CO(k) = SV*HR(k)/60;  % preserve CO in units of [cc/s]
        R     = MAP(k)/CO(k); % peripheral resistance [mmHg*s/cc]
        
        k = k+1; % point to next index for R,HR,onset,CO,etc.
    end
end

CO = 60/1000 * CO; % convert final CO into L/min