function fileName = print_image(rep, name, svg)

import misc.unique_filename;
import mperl.file.spec.catfile;
import plot2svg.plot2svg;
import inkscape.svg2png;

if nargin < 3 || isempty(svg), svg = true; end

fileName = catfile(get_rootpath(rep), [name '.svg']);
fileName = unique_filename(fileName);

[path, name] = fileparts(fileName);

% IMPORTANT: Print to png AFTER printing to svg. For some reason, printing
% to .png during terminal mode emulation screws the figures looks!
if svg,
    evalc('plot2svg(fileName, gcf);');
else
    fileName = [catfile(path, name) '.png'];
end

% For the thumbnails, we always need a .png
if usejava('Desktop'),
    
    print('-dpng', [catfile(path, name) '.png'], '-r600');
    
else
    % MATLAB renderers that are available during terminal emulation suck a
    % lot. We use an indirect route to be able to generate a high quality
    % .png in this case: (1) generate a pdf, (2) convert to .png using
    % inkscape
    
    tmpPdfFile = [catfile(path, name) '.pdf'];
    print('-dpdf', tmpPdfFile);
    svg2png(tmpPdfFile, [], 600); % maybe I should rename this function...
    delete(tmpPdfFile);   
end



end