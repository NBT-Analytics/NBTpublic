function obj = equalize(obj, varargin)
% EQUALIZE - Equalizes the ranges of various signal modalities
%
%
% newObj = equalize(obj)
%
% Where
%
% OBJ is a physioset.object where the variance ranges of different signal
% modalities might be very different from each other. For instance MEG data
% might be measured in T and EEG data in mV resulting in vastly different
% variance ranges between EEG and MEG data.
%
% NEWOBJ is identical to OBJ but with possibly different signal physical
% dimensions. The new dimensions should be such that the variance ranges of
% different modalities are as close as possible to each other. This may
% result in e.g. MEG data being measured in pT and EEG data in V.
% Additionally, the median (accross channel) variances of different signal
% modalities will be forced to be exactly equal to one by applying suitable
% equalization weights, whose values will be stored in the returned 
% physioset object. Note that this equalization process WILL NOT affect the
% relative amplitudes of data channels within the same modality. 
%
%
% See also: physioset

% TO-DO: IF THERE IS AN ERROR IN THIS FUNCTION YOU MAY END UP WITH WRONG
% INFORMATION IN THE PHYSDIM FIELD OF THE SENSORS OR WITH WRONG SCALING OF
% THE DATA CHANNELS. MAKE THIS FUNCTION EXCEPTION SAFE!

import misc.process_arguments;
import misc.eta;
import io.edfplus.dimension_prefixes;


opt.verbose = true;

[~, opt] = process_arguments(opt, varargin);

[sensorGroups, idx] = sensor_groups(obj.Sensors);
nbGroups            = numel(sensorGroups);
totalNbSensors      = nb_sensors(obj.Sensors);

if nbGroups < 2,
    return;
end

[prefix, power] = dimension_prefixes;
tinit = tic;
sensorCount = 0;

obj.EqWeights           = eye(obj.NbDims);
obj.EqWeightsOrig       = eye(obj.NbDims);
obj.PhysDimPrefixOrig   = cell(obj.NbDims,1);

for i = 1:nbGroups
    nbSensors       = numel(idx{i});
    thisVar         = nan(numel(idx{i}),1);
    for j = 1:numel(idx{i}),
        thisData        = obj.PointSet(idx{i}(j),:);
        thisVar(j)      = var(thisData, [], 2);
    end
    thisRange       = median(thisVar);
    [physDimPrefixOrig, oldPower]   = get_physdim_prefix(sensorGroups{i});
    
    if (thisRange) < eps,
        warning('equalize:ZeroVarianceData', ...
            ['Not equalizing sensor group #%d (%s): ' ...
            'all channels have zero variance'], i, class(sensorGroups{i}));
        continue;
    end
    
    thisPower   = log10(sqrt(thisRange)) + oldPower;
    
    powerIdx    = nan(nbSensors,1);
    thisPrefix  = cell(nbSensors,1);
    powerRes    = nan(nbSensors,1);
    
    for j = 1:nbSensors,
        [~, powerIdx(j)]   = min(abs(round(thisPower(j))-power));
        thisPrefix(j)      = prefix(powerIdx(j));
        powerRes(j)        = power(powerIdx(j))-thisPower(j);
        
    end
    sensorGroups{i} = set_physdim_prefix(sensorGroups{i}, thisPrefix);
    
    thisPower       = power(powerIdx);
    
    for j = 1:nbSensors,        
        obj.PointSet(idx{i}(j),:) = 10^(-thisPower(j) + powerRes(j) + ...
            oldPower(j)).*obj.PointSet(idx{i}(j),:);
        sensorCount = sensorCount + 1;
        if opt.verbose,
            misc.eta(tinit, totalNbSensors, sensorCount);
        end
    end    
    
    obj.EqWeights(idx{i},idx{i}) = diag(10.^(-powerRes));
    obj.EqWeightsOrig(idx{i},idx{i}) = ...
        diag(10.^(-thisPower + powerRes + oldPower));  
    obj.PhysDimPrefixOrig(idx{i}) = physDimPrefixOrig;    
end

obj.Sensors = sensors.mixed(sensorGroups{:});

end