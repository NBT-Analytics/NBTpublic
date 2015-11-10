function [data, dataNew] = process(obj, data, varargin)
% PROCESS - Interpolates bad channels
%
% data = process(obj, data)
%
% Where
%
% DATA is a physioset object
%
%
% See also: physioset, bad_channels


import mperl.join;
import report.generic.generic;
import report.object.object;
import meegpipe.node.bad_channels.bad_channels;
import meegpipe.node.globals;
import misc.euclidean_dist;

dataNew = [];

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);
nn              = get_config(obj, 'NN');
clearBadChannel = get_config(obj, 'ClearBadChannels');

% List of bad channels
badIdx  = find(is_bad_channel(data));
goodIdx = find(~is_bad_channel(data));

if isempty(badIdx),
    warning('chan_itern:NoBadChans', ...
        'There are no bad channels: no need to interpolate');
    return;
end

if numel(goodIdx) < nn,
    error('chan_itern:NoGoodChans', ...
        ['%d channels were requested for interpolation but there are ' ...
        'only %d good channels'], numel(goodIdx));
end

sens  = sensors(data); 
xyz   = sens.Cartesian;

if isempty(sens.Cartesian),
    warning('chan_inter:MissingSensorCoordinates', ...
        'Sensor coordinates are missing: skipping interpolation');
    return;
end


W = zeros(size(data,1));
chanGroups = cell(1, numel(badIdx));

for i = 1:numel(badIdx)
   % Find nearest neighbors
   dist = euclidean_dist(xyz(badIdx(i),:), xyz(goodIdx,:));
   [nnDist, nnIdx] = sort(dist, 'ascend');
   weights = 1./nnDist(1:nn);
   weights = weights/sum(weights);
   data(badIdx(i),:) = weights'*data(goodIdx(nnIdx(1:nn)),:);   
   W(badIdx(i), goodIdx(nnIdx(1:nn))) = weights;
   
   if do_reporting(obj),
       nearestChans = goodIdx(nnIdx(1:nn));
       chanGroups{i} = sort([badIdx(i);nearestChans(:)], 'ascend');
   end
   
end

if verbose,
    
    fprintf([verboseLabel ...
        'Interpolated %d channels using %d nearest neighbors\n\n'], ...
        numel(badIdx), nn);
    
end

fid = get_log(obj, 'interpolated_bad_channels.txt');
fprintf(fid, mperl.join('\n', badIdx));

make_interpolation_report(obj, chanGroups, data, badIdx, W(badIdx,:)');

if clearBadChannel,
    clear_bad_channel(data, badIdx);
end

end