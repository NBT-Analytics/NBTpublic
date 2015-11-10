function bool = do_reporting(obj)

import meegpipe.node.globals;

parentNode = get_parent(obj);

% First ensure that all the dependencies are there. If not, then don't
% attempt to do any reporting
if ~inkscape.has_inkscape, 
    bool = false;
    if isempty(parentNode),
       % Display a warning only at the top level of the pipeline hierarchy
       warning('do_reporting:MissingInkscape', ...
           ['Inkscape is not installed or could not be found: ' ...
           'No reports will be generated']);
    end
    return;
end

bool = obj.GenerateReport && globals.get.GenerateReport;

if ~isempty(parentNode),
    bool = bool & do_reporting(parentNode);
end

end