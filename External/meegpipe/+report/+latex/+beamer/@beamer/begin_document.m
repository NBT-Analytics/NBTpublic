function begin_document(obj)

import mperl.file.spec.*;
import report.latex.beamer.root_path;
import safefid.safefid;

preambleFile = catfile(root_path, 'preamble.tex');
preamble = safefid(preambleFile, 'r');

% Read the preamble file line by line and print it to the latex report
while 1
    tline = fgetl(preamble);
    if ~ischar(tline), break; end
    fprintf(obj.FID, '%s\n', tline);
end

% Theme
if ~isempty(obj.Theme),
    fprintf(obj.FID, '\\usertheme{%s}\n\n', obj.Theme);
end

if ~isempty(obj.ColorTheme),
    cThemeFile = catfile(root_path, ...
        ['beamercolortheme' lower(obj.ColorTheme) '.sty']);
    cTheme     = safefid(cThemeFile, 'r');
    while 1
        tline = fgetl(cTheme);
        if ~ischar(tline), break; end
        fprintf(obj.FID, '%s\n', tline);
    end
end

fprintf(obj.FID, '\\begin{document}\n\n');

end