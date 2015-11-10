function data = scalp_potentials(obj, varargin)

import misc.process_arguments;

opt.time = [];
[~, opt] = process_arguments(opt, varargin);

if isempty(opt.time),
    opt.time = 1;
    for i = 1:obj.NbSources
        opt.time = max(opt.time, numel(obj.Source(i).pnt));
    end
end

data = nan(obj.NbSensors, numel(opt.time));
for i = 1:numel(opt.time)
   data(:, i) = sum(source_leadfield(obj, 1:obj.NbSources, 'opt.time', opt.time, ...
       varargin{:}),2); 
   
   if ~isempty(obj.MeasNoise),
      data(:,i) = data(:,i) + obj.MeasNoise(:,i); 
   end
   
end


end