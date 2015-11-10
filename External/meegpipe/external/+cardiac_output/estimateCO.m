function [co, to, told, fea] = estimateCO(fname,estID,filt_order)
% ESTIMATECO  Cardiac output estimator.
%   [CO, TO, TOLD, FEA] = ESTIMATECO(FNAME, ESTID, FILT_ORDER) is the 
%   main function for estimating cardiac output.  
%
%   In:   FNAME      <1xn>  --- file where ABP and features are located
%         ESTID      <1x1>  --- the CO estimator to use
%         FILT_ORDER <1x1>  --- order of running avg LPF to use on output 
%                                      (enter 0 or 1 for no LPF)
%
%   Out:  CO         <kx1>  --- estimated CO (uncalibrated)
%         TO         <kx1>  --- time [minutes] (not evenly sampled!)
%         TOLD       <mx1>  --- time [minutes], not sqi filtered
%         FEA        <kx11> --- feature matrix
% 
%   Usage:
%   This function is only a wrapper.  Actual CO estimation computation is 
%   done in the following required functions:
%   ESTID 1: est01_MAP      - Mean pressure
%         2: est02_WK       - Windkessel 1st order LTI RC circuit model
%         3: est03_SA       - Systolic area distributed model
%         4: est04_SAwarner - Warner systolic area with time correction
%         5: est05_Lilj     - Liljestrand PP/(Psys+Pdias) estimator
%         6: est06_Herd     - Herd estimator
%         7: est07_SAwessCI - Wesseling systolic area with impedance correction
%         8: est08_Pulsion  - Pulsion non-linear compliance model
%         9: est09_LidCO    - LidCO root-mean-square model
%        10: est10_RCdecay  - RC exponential decay fit
%        11: est11_mf       - Wesseling non-linear, time-varying 3-element model
%
%   Written by James Sun (xinsun@mit.edu) on Nov 19, 2005.
%   - v2.0 - 1/18/06 - added output for detecting percentage of good beats
%   - v3.0 - 1/20/06 - added "feature" output, CO no longer normalized

% load features from fname
load(fname,'F','onset','sqi','t0','m2t');
load agegender

co = [];
to = [];
told=[];
fea = [];
for seg=1:size(t0,1)  % loop through each ABP waveform segment
%seg
    onset1 = onset{seg};

    % skip segment if too little data
    if length(onset1)<50 || length(onset1)<(3*filt_order)
        continue
    end

    % read features
    F1      = F{seg};
    Psys    = F1(:,2);
    Pdias   = F1(:,4);
    PP      = F1(:,5);
    MAP     = F1(:,6);
    Period  = F1(:,7);
    HR      = 60*125./Period; 
    tSArr   = F1(:,9);
    SArr    = F1(:,10);
    tSAcosm = F1(:,11);
    SAcosm  = F1(:,12);

    % select systolic area estimate
    SA      = SArr;
    tSA     = tSArr;

    % special items for estID 8,9,11
    if estID==11
        caseid = m2t.caseid;
        ind = find(agegender(:,1)==caseid);
        % quit if no age, gender info found
        if isempty(ind)
            continue
        end
        age = agegender(ind,3);
        gender = agegender(ind,4);
    end
    
    if estID==8 || estID==9 || estID==11
        str = sprintf('load %s abp%d',fname,seg); eval(str);
        str = sprintf('abp=abp%d; clear abp%d',seg,seg); eval(str);
    end

    
    % estimate CO!
    switch estID
        case  1,   x = est01_MAP(MAP);
        case  2,   x = est02_WK(PP,HR);
        case  3,   x = est03_SA(SA,HR);
        case  4,   x = est04_SAwarner(SA,HR,onset1,tSA);
        case  5,   x = est05_Lilj(PP,HR,Psys,Pdias);
        case  6,   x = est06_Herd(MAP,Pdias,HR);
        case  7,   x = est07_SAwessCI(MAP,SA,HR);
        case  8,   x = est08_Pulsion(abp, onset1, MAP, HR, tSA);
        case  9,   x = est09_LidCO(abp,onset1,HR);
        case 10,   x = est10_RCdecay(Period,Psys,Pdias,MAP);
        case 11,   x = est11_mf(abp,onset1,MAP,HR,age,gender);
        case 12,   x = est12_coalees(PP,HR,onset1,tSA,Psys,Pdias);
        case 13,   x = est13_trivial(PP,HR,MAP);
        otherwise, x = nan;
    end
    
    % synchronize time of of all segments
    offset = (t0(seg,1)-t0(1,1))*24*60;
    t      = onset1(1:end-1)/(125*60)+offset; %[min]

    % remove all datapoints with bad SQI
    sqi1   = sqi{seg}(:,1);
    ind    = find(sqi1);
    t_old  = t;
    x(ind) = [];
    t(ind) = [];

    % apply zero-phase moving avg LPF
    if filt_order<2, x_filt = x;
    else             x_filt = filtfilt(ones(filt_order,1)/filt_order,1,x);
    end

    % features
    ff = F{seg};
    ff(ind,:) = [];
    
    % append segment data to pool
    co = [co; x_filt];
    to = [to; t];
    told = [told; t_old];
    fea = [fea; ff];
end

% normalize estimated CO to 1st point
%co = co/co(1);