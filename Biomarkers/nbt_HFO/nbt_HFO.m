
classdef nbt_HFO < nbt_Biomarker
    properties
        results
        fs
        lp
        hp
        Fst1
        Fp1
        Fp2
        Fst2
        Ast1
        Ap
        Ast2
        maxIntervalToJoin
        minNumberOscillatins
        dFactor
        bound_min_peak
        ratio_thr
        min_trough
        limit_fr
        start_fr
        time_thr
        THR
        channel_name
    end
    methods
        function HFOobj = nbt_HFO
            HFOobj.results = [];
            HFOobj.fs = nan;
            HFOobj.hp = nan;
            HFOobj.lp = nan;
            HFOobj.Fst1 = nan;
            HFOobj.Fp1 = nan;
            HFOobj.Fp2 = nan;
            HFOobj.Fst2 = nan;
            HFOobj.Ast1 = nan;
            HFOobj.Ap = nan;
            HFOobj.Ast2 = nan;
            HFOobj.time_thr = nan;
            % merge IoEs
            HFOobj.maxIntervalToJoin = nan; % 10 ms
            % reject events with less than 6 peaks
            HFOobj.minNumberOscillatins = nan;
            HFOobj.dFactor = nan;
            % Stage 2
            HFOobj.bound_min_peak = nan; % Hz, minimum boundary for the lowest ("deepest") point
            HFOobj.ratio_thr = nan; % threshold for ratio
            HFOobj.min_trough = nan; % 20 %
            HFOobj.limit_fr = nan;
            HFOobj.start_fr = nan; % limits for peak frequencies
            HFOobj.THR = nan;
            HFOobj.channel_name = '';
            %make list of biomarkers in this object:
            HFOobj.Biomarkers ={'results'};
        end
    end
    
end

