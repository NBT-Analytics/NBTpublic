function [Signal,SignalInfo, SignalPath] = NBT(varargin)
% eeglab - Conversion to NBT info object
%
% See: <a href="matlab:misc.md_help('+physioset/@physioset/eeglab.md')">misc.md_help(''+physioset/@physioset/eeglab.md'')</a>
%
%
% See also: fieldtrip

import misc.check_dependency;
import physioset.event.event;
import physioset.event.std.trial_begin;
import physioset.event.std.epoch_begin;
import physioset.deal_with_bad_data;
import misc.process_arguments;

check_dependency('eeglab');

count = 0;
while count < numel(varargin) && ...
        isa(varargin{count+1}, 'physioset.physioset'),
   count = count + 1; 
end

obj = varargin(1:count);

varargin = varargin(count+1:end);

opt.BadDataPolicy = 'reject';
opt.MemoryMapped = false;
[~, opt] = process_arguments(opt, varargin);

if numel(obj) > 1,
   % Merging multiple physiosets into a single ftrip structure
   EEG = cell(size(obj));
   for i = 1:numel(obj)
      EEG{i} = eeglab(obj{i}, varargin{:});      
   end
   return;
end

obj = obj{1};

% Do something about the bad channels/samples
[didSelection, evIdx] = deal_with_bad_data(obj, opt.BadDataPolicy);

% Reconstruct trials, if necessary. This complicates things...
evArray = get_event(obj);
    
if isempty(evArray),
    
    if opt.MemoryMapped,
        data = obj.PointSet;    
    else
        data = obj.PointSet(:,:);
    end
    
else    
   
    isTrialEv = evArray == trial_begin;
    trialEvs  = evArray(isTrialEv);
    
    if opt.MemoryMapped,
        data = obj.PointSet;
    elseif isempty(trialEvs),                
        data = obj.PointSet(:,:);     
    else      
        [data, evArray] = epoch_get(obj, trialEvs);       
    end
    
end

savedStr = get_meta(obj, 'eeglab');
if ~isempty(savedStr),
    tmp = savedStr;
else
    tmp        = eeg_emptyset;
    tmp.datfile= '';
    tmp.nbchan = size(obj,1);
    tmp.srate  = obj.SamplingRate;
    tmp.xmin   = 0;
    
    dataFile        = get_datafile(obj);
    [~, f_name]     = fileparts(dataFile);
    tmp.setname     = sprintf('%s file', f_name);
    tmp.comments    = [ 'Original file: ' dataFile ];
    tmp.pnts        = size(data, 2);
    tmp.trials      = size(data, 3);
    
    % Sensor information
    sArray = sensors(obj);
    if ~isempty(sArray),
        tmp.chanlocs = eeglab(sArray);
    end

    if ~isempty(evArray),
        tmp.event = eeglab(evArray);
    end
    
end

tmp.data   = data;

evalc('tmp = eeg_checkset(tmp, ''eventconsistency'')');
evalc('tmp = eeg_checkset(tmp, ''makeur'')');   % Make EEG.urevent field
evalc('tmp = eeg_checkset(tmp)');

EEG = tmp;  

% Undo temporary selections
if didSelection,
    restore_selection(obj);
    if ~isempty(evIdx),
        % Careful, evIdx = [] means "delete all events"
        delete_event(obj, evIdx);
    end
end

[Signal,SignalInfo, SignalPath] = nbt_EEGlab2NBTsignal(EEG,1);

end






