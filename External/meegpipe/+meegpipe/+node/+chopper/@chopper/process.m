function [data, dataNew] = process(obj, data, varargin)


import meegpipe.node.chopper.chopper;

dataNew = [];

alg = get_config(obj, 'Algorithm');

[bndry, idx] = chop(alg, data);

if do_reporting(obj),
    
    rep = get_report(obj);
    print_title(rep, 'Chopping report', get_level(rep)+1);
    chopper.generate_index_report(get_report(obj), data, log(idx), bndry);

end

sample = find(bndry);

if numel(sample) < 3,
    % Only one chop, so no chopping in fact
    return;
end

event = get_config(obj, 'Event');

evArray = repmat(event, 1, numel(sample)-1);

evArray = set_sample(evArray, sample(1:end-1));

% Last chop must be until the end of the available data
evArray(end) = set_duration(evArray(end), size(data,2) - sample(end-1) + 1);

add_event(data, evArray);


end