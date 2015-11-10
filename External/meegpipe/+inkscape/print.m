function [status, res] = print(format, filename, h, dpi)

import inkscape.external.plot2svg.plot2svg;
import inkscape.*;
import mperl.file.spec.catfile;

if nargin < 4 || isempty(dpi),
    dpi = 300;
end

if nargin < 3 || isempty(h),
    h = gcf; %#ok<NASGU>
end

tmpFilename = [tempname '.svg'];

evalc('plot2svg(tmpFilename, h);');

[path, fname] = fileparts(filename);

switch lower(format)
    
    case 'pdf',
        filename = catfile(path, [fname '.pdf']);
        [status, res] = svg2pdf(tmpFilename, filename);
        
    case 'eps'
        filename = catfile(path, [fname '.eps']);
        [status, res] = svg2eps(tmpFilename, filename);
        
    case 'pdf-latex',
        filename = catfile(path, [fname '.pdf']);
        [status, res] = svg2pdf(tmpFilename, filename, true);
        
    case 'eps-latex',
        filename = catfile(path, [fname '.eps']);
        [status, res] = svg2eps(tmpFilename, filename, true);
        
    case 'png'
        filename = catfile(path, [fname '.png']);
        [status, res] = svg2png(tmpFilename, filename, dpi);
        
    otherwise
        error('Unsupported graphics format');
        
end

delete(tmpFilename);

end
