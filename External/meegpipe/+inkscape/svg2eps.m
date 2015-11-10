function [status, res] = svg2eps(in, out, latex)

import mperl.file.spec.catfile;
import inkscape.inkscape_binary;
import mperl.cwd.abs_path;

in = abs_path(in);

if nargin < 3 || isempty(latex),
    latex = false;
end

if nargin < 2 || isempty(out),
    [path, name] = fileparts(in);
    out = catfile(path, [name '.eps']);
end

if latex,
    latex = '--export-latex ';
else
    latex = '';
end

cmd = sprintf('"%s" %s--export-eps="%s" "%s"', ...
    inkscape_binary, latex, out, in); 

[status, res] = system(cmd);

end