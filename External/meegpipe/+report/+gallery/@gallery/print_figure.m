function myGallery = print_figure(myGallery, hFig, rep, name, caption) %#ok<INUSL>
% PRINT_FIGURE - Add figure to gallery and print to image file

import inkscape.svg2png;
import plot2svg.plot2svg;
import misc.unique_filename;
import mperl.file.spec.catfile;

% Print to .svg and .png format
fileName = catfile(get_rootpath(rep), [name '.svg']);
fileName = unique_filename(fileName);

% IMPORTANT: Print to png AFTER printing to svg. For some reason, printing
% to .png during terminal mode emulation screws the figures looks!
evalc('plot2svg(fileName, hFig);');
myGallery = add_figure(myGallery, fileName, caption);

svg2png(fileName);

close;



end