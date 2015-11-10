function h = set_scale(h, idx, val)
% SET_SCALE - Set plot scale
%
% set_scale(h, idx, value)
%
% Where
%
% H is a plotter.eegplot handle
%
% IDX is an index or an array of indices identifying the plots whose scales
% are to be modified.
%
% VALUE is the new plot scale (a double precision scalar)
%
% See also: get_scale

% Description: Set plot scale
% Documentation: class_plotter_eegplot.txt

import misc.isnatural;

if nargin < 3 || isempty(val),
    return;
end

if nargin < 2 || isempty(idx),
    idx = 1:nb_plots(h);
end

if ~isnumeric(val),
    error('Argument VALUE must be a numeric array');
end

if ~isnatural(idx),
    error('Argument IDX must be an array of natural numbers');
end

if numel(val) == 1 && numel(idx) > 1
    val = repmat(val, 1, numel(idx));
end

if numel(val) ~= numel(idx)
    error('The dimensions of arguments IDX and VALUE must match');
end

origSelection = h.Selection;
h = deselect(h, []);
for i = 1:numel(idx)
    
   if abs(val(idx(i)) - h.ScaleVal(idx(i))) > eps
      select(h, idx(i));
      
      
      for j = 1:numel(h.Line{idx(i)})
          % We have do this in a loop because eegplots may contain lines of
          % different lengths (if there are bad samples marked within the
          % current epoch)
          data      = get_line(h, j, 'YData');
          data      = data - repmat(h.MeanVal(j), 1, size(data,2));
          factor    = h.ScaleVal(idx(i))/val(idx(i));
          newData   = factor*data;
          set(h.Line{idx(i)}(j), 'YData', newData+h.MeanVal(j));
      end
      
      h.ScaleVal(idx(i)) = val(idx(i));
      
   end
   
end

h = select(h, origSelection);

if any(abs(diff(h.ScaleVal)) > eps),
    set_scale_label(h, 'string', '~');
else
    set_scale_label(h, 'string', h.ScaleVal(1));
end




end