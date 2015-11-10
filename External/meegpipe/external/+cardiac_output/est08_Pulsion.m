function [CO, q] = est08_Pulsion(abp, onset, MAP, HR, endSys)
% EST08_Pulsion  CO estimator 8: Pulsion's non-linear compliance model
%
%   Written by James Sun (xinsun@mit.edu) on Nov 19, 2005.


%% minor business
q      = zeros(length(abp),1);
CO     = zeros(length(MAP),1);
abp    = double(abp);   % change to double FP precision
HR     = double(HR);
MAP    = double(MAP);

dP     = diff(abp);
dP     = [dP(1); dP];

% initial conditions
Pm     = MAP(1);
dPmean = mean(dP(endSys(1):onset(2)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% main loop (runs Wesseling's model, updating nonlinear parameters for each iteration)
k=1;
for i=1:length(abp)
    
    %% first parameters
    P  = abp(i);        % ABP sample [mmHg]
    d1 = dP(i);
    if dPmean==0 && i~=0
        q(i)=q(i-1);
    elseif dPmean==0 && i==0
        q(i)=P;
    else
        q(i)  = P + Pm^3/(3*Pm*P - 3*Pm^2 - P^2) * d1/dPmean;
    end

    %% Update MAP, CO, R
    if k+1 > length(onset)
        break
    elseif i >= onset(k+1)

        Pm = MAP(k);
        dPmean = mean(dP(endSys(k):onset(k+1)));
        
        pos_flow = q(onset(k):end);
        ind = find(pos_flow<0);
        if numel(ind)<=2
%            'eeek'
            CO(k)=CO(k-1);
        else
            if ind(1)<4
                ind = ind(2);
            else
                ind = ind(1);
            end
            pos_flow = pos_flow(1:ind);
            SV    = sum(pos_flow);
            CO(k) = SV*HR(k);
        end
        
        k = k+1; % point to next index for R,HR,onset,CO,etc.
    end
end
