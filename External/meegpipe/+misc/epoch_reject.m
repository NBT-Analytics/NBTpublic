function [y, ev_out] = epoch_reject(x, ev, varargin)
% EPOCH_REJECT - Rejects noisy epochs
%
% Usage:
%   >> Y = epoch_reject(X, EV)

import misc.epoch_get;
import misc.epoch_set;
import misc.epoch_set;
import misc.ispset;
import misc.merge_overlap;
import misc.process_varargin;
import misc.globals;

THIS_OPTIONS = {'mergewindow', 'writable','beginning','end'};
mergewindow = globals.evaluate.MergeWindow;
if ispset(x),
    writable = x.Writable;
else
    writable = false;
end

[cmd_str, remove_flag] = process_varargin(THIS_OPTIONS, varargin);
eval(cmd_str);
varargin(remove_flag) = [];

if ispset(x),
    y = copy(x, 'Writable', true, varargin{:});
else
    y = x;
end

sample = cell2mat(get(ev, 'Sample'));
duration = cell2mat(get(ev, 'Duration'));

if sample(1) < duration(1),    
    duration(1) = duration(1) + sample(1)-1;
    sample(1) = 1;
end

if (size(y,2)-sample(end)+duration(end)-1) < duration(end),
    duration(end) = size(y,2)-sample(end)+1;
end

for i = 1:length(ev)
    left_out = (sample(i) - mergewindow < 0 );
    right_out = (sample(i) + duration(i)+ mergewindow > size(y,2));
    if left_out,
        e_data = epoch_get(y, sample(i),...
            'Duration', duration(i)+mergewindow);
        w2 = e_data(:,end-mergewindow+1:end);
        if mergewindow>0,
            e_data = merge_overlap(e_data(:,1:end-mergewindow), w2, mergewindow);
        end
        y = epoch_set(y, sample(i), e_data(:,end-mergewindow+1:end), ...
            'Offset', duration(i), ...
            'Indices',1:mergewindow);
    elseif right_out,
        e_data = epoch_get(y, sample(i),...
            'Duration', duration(i)+mergewindow, ...
            'Offset', -mergewindow);
        w1 = e_data(:,1:mergewindow);
        if mergewindow>0,
            e_data = merge_overlap(w1,e_data(:,mergewindow+1:end), mergewindow);
        end
        y = epoch_set(y, sample(i), e_data(:,1:mergewindow), ...
            'Offset', -mergewindow, ...
            'Indices',1:mergewindow);
    else
        
        e_data = epoch_get(y, sample(i),...
            'Duration', duration(i)+2*mergewindow, ...
            'Offset', -mergewindow);
        
        w1 = e_data(:,1:mergewindow);
        w2 = e_data(:,end-mergewindow+1:end);
        if mergewindow>0,
            e_data = merge_overlap(w1,e_data(:,mergewindow+1:end-mergewindow), mergewindow);
            e_data = merge_overlap(e_data, w2, mergewindow);
        end
        y = epoch_set(y, sample(i), e_data(:,1:mergewindow), ...
            'Offset', -mergewindow, ...
            'Indices',1:mergewindow);
        y = epoch_set(y, sample(i), e_data(:,end-mergewindow+1:end), ...
            'Offset', duration(i), ...
            'Indices',1:mergewindow);
    end
    
    y = epoch_set(y, sample(i), zeros(size(e_data)));
    
end

ev_out = set(ev, 'Type', 'rejected');

if ispset(y),
    y.Writable = writable;
end



end