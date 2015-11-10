function [data, dataNew] = process(obj, data, varargin)

import fmrib.my_fmrib_pas;
import meegpipe.node.qrs_detect.qrs_detect;
import physioset.plotter.snapshots.snapshots;
import misc.eta;
import misc.epoch_get;

dataNew = [];

verboseLabel = get_verbose_label(obj);
verbose      = is_verbose(obj);

% Locations of the QRS events
evSel     = get_config(obj, 'EventSelector');
qrsEvents = select(evSel, get_event(data));

if isempty(qrsEvents),
    warning('obs:NoQRSEvents', ...
        'I found no QRS events: OBS correction will not be performed');
    return;
end

peaks     = get_sample(qrsEvents); 

if numel(peaks) < 1,
    error('pset:node:obs:obs:process:NoQRSEvents', ...
        'There are no QRS events in this dataset');
end

if verbose,
    
    fprintf([verboseLabel 'Running fmrib''s OBS algorithm... ']);
    tinit = tic;
    by100 = floor(size(data,1)/100);
    clear +misc/eta;
    
end


method = get_config(obj, 'Method'); %#ok<NASGU>
npc    = get_config(obj, 'NPC'); %#ok<NASGU>

% Make this a configuration option later!
bcgDur = get_config(obj, 'ERPDuration');
bcgDur = round(data.SamplingRate*bcgDur);
bcgOff = get_config(obj, 'ERPOffset');
bcgOff = round(data.SamplingRate*bcgOff);
bcgERP = zeros(size(data,1), bcgDur);
bcgERPVar = zeros(size(data,1), bcgDur);

for i = 1:size(data, 1)        
    
    evalc(['cleanData = my_fmrib_pas(data(i,:), data.SamplingRate, ' ...
        'peaks, method, npc)']);
    
    bcgData   = data(i,:) - cleanData;
    data(i,:) = cleanData;
    
    bcgData   = bcgData - mean(bcgData);
    bcgTrials = epoch_get(bcgData, qrsEvents, ...
        'Offset', bcgOff, 'Duration', bcgDur);
    
    bcgTrials   = squeeze(bcgTrials);
    bcgERP(i,:) = mean(bcgTrials, 2);
    bcgERPVar(i,:) = var(bcgTrials, [], 2);
    
    if verbose && ~mod(i, by100)
        eta(tinit, size(data,1), i, 'remaintime', false);
    end
    
end

if verbose, fprintf('\n\n'); end


% Store the BCG ERP in the node. Some later nodes (e.g. a bss_regr node
% having a spt.criterion.topo_template criterion) may use such BCG ERP to
% identify BCG-related ICA components
obj.ERPMean_ = bcgERP;
obj.ERPVar_  = bcgERPVar;

if do_reporting(obj),
    
    if verbose
        fprintf([verboseLabel 'Generating report...']);
    end

    rep = get_report(obj);
    print_title(rep, 'OBS report', get_level(rep)+1);
    
    % nothing yet
    
    if verbose,
       fprintf('[done]\n\n'); 
    end

end



end