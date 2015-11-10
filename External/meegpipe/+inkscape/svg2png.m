function [status, res] = svg2png(in, out, dpi)

import mperl.file.spec.catfile;
import inkscape.inkscape_binary;
import mperl.cwd.abs_path;

in = abs_path(in);

if nargin < 3,
    dpi = [];
end

if nargin < 2 || isempty(out),
    [path, name] = fileparts(in);
    out = catfile(path, [name '.png']);
end

if isempty(dpi),
    cmd = sprintf('"%s" --export-png="%s" "%s"', ...
        inkscape_binary, out, in);
else
    cmd = sprintf('"%s" --export-png="%s" "%s" --export-dpi=%d', ...
        inkscape_binary, out, in, dpi);
end


[status, res] = system(cmd);

if ~exist(out, 'file'),
    warning('svg2png:FailedInkscapeCall', ...
        'Failed to generate image file %s\n\n%s', out, res);
end



end