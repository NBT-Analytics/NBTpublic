function count = fprintf(fid, obj, varargin)

import misc.unique_filename;
import mperl.file.spec.catfile;
import inkscape.svg2png;
import misc.fid2fname;
import plot2svg.plot2svg;

count = fprintf@sensors.abstract_sensors(fid, obj, varargin);

% Print also the locations in a 2D plot
if has_coords(obj)
    h = plot(obj, 'Labels', true, 'Project2D', true, 'Visible', false);
else    
    return;
end

% Remove the nose and ear markers because they are not really needed and
% prevent the figure to be stored in .svg format
hP = findobj(h, 'Type', 'patch');
hL = findobj(h, 'Type', 'line');
delete(hP);
delete(hL);

if isa(fid, 'safefid.safefid'),
    rPath = fileparts(fid.FileName);
elseif fid > 1,
    rPath = fileparts(fid2fname(fid));
else
    rPath = pwd;
end

fileName = catfile(rPath, 'sensor_layout.svg');
fileName = unique_filename(fileName);

evalc('plot2svg(fileName, gcf);');
svg2png(fileName);
close;

gallery = report.gallery.new;

gallery = add_figure(gallery, fileName, 'EEG sensors layout');

count = count + fprintf(fid, gallery);

end