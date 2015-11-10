function h = overlay(h, varargin)

import plotter.fvtool2.*;

% Options to be processed here
count = 1;
while count <= nargin && (iscell(varargin{count}) || ...
        ~isempty(regexpi(class(varargin{count}), '^dfilt\.')))
    count = count + 1;
end

fvtoolArgs = varargin(1:count-1);
varargin   = varargin(count:end);

if iscell(fvtoolArgs{1}) || ...
        ~isempty(regexpi(class(fvtoolArgs{1}), '^dfilt.\w+')),
    
    fvtoolArgs = fvtool2.process_filt_array(fvtoolArgs{:});
    
end

thisFvtoolHandle = fvtool(fvtoolArgs{:}, varargin{:});
h.FvtoolHandle = [h.FvtoolHandle; thisFvtoolHandle];


h.Selection = 1:numel(h.FvtoolHandle);



end