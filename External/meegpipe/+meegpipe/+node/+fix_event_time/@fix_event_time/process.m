function [data, dataNew] = process(obj, data, varargin)

import physioset.plotter.snapshots.snapshots;
import misc.eta;
import misc.epoch_get;
import misc.epoch_align;

dataNew =[];

verboseLabel = get_verbose_label(obj);
verbose      = is_verbose(obj);

% Configuration options
offset    = get_config(obj, 'Offset');
duration  = get_config(obj, 'Duration');
maxShift  = get_config(obj, 'MaxShift');
evSel     = get_config(obj, 'EventSelector');

% Locations of the TR events
if verbose,
    fprintf([verboseLabel 'Selecting events for processing...']);
end
[trEv, trEvIdx] = select(evSel, get_event(data));
if verbose,
    fprintf('[%d selected]\n\n', numel(trEv));
end

if isempty(trEv),
    warning('fix_event_time:NoEvents', ...
        'I found no relevant events: No timing correction was performed');
end

epochs = epoch_get(data, trEv, 'Offset', offset, 'Duration', duration);

epochs2 = cell(size(epochs,3), 1);
for i = 1:size(epochs,3)
    epochs2{i} = squeeze(epochs(:, :, i));
end

if verbose,
    fprintf([verboseLabel 'Aligning epochs using cross-correlation...']);
end
[~, ~, shiftVal] = epoch_align(epochs2, maxShift);
if verbose,
    fprintf('\n\n');
    clear +misc/eta;
end

if verbose,
    fprintf([verboseLabel 'Fixing event timings...']);
end
trEv = set_sample(trEv, get_sample(trEv)-shiftVal');

delete_event(data, trEvIdx);

add_event(data, trEv);
if verbose,
    fprintf('[done]\n\n');
end

end