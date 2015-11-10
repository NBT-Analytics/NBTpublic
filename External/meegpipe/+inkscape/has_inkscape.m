function bool = has_inkscape()
% HAS_INKSCAPE - Tests whether Inkscape is installed in this system
%
% bool = has_inkscape()
%
% Where
%
% BOOL is true if Inkscape is installed in this sytem, and meegpipe is able
% to find it (i.e. the path to the Inkscape binary is in specified in the
% meegpipe configuration file meegpipe.ini).
%
%
% See also: inkscape

cmd = sprintf('"%s" -V', inkscape.inkscape_binary);
[~, res] = system(cmd);

match = regexp(res, 'Inkscape\s+\d+\.\d+', 'once');

if isempty(match),
    bool = false;
else
    bool = true;
end