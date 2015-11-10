function count = fprintf(fid, obj, varargin)
import misc.any2str;
import safefid.safefid;
import mperl.file.spec.catfile;
import misc.unique_filename;
import mperl.join;
import misc.fid2fname;
% Just in case the children classes do not implement fprintf.
% This dummy implementation will prevent the HTML report
% generation from breaking.
MAX_STR_LEN = 40;

sensLabels = labels(obj);
origSensLabels = orig_labels(obj);

% Print all sensor labels to a file
if isa(fid, 'safefid.safefid'),
    rPath = fileparts(fid.FileName);
elseif fid > 1,
    rPath = fileparts(fid2fname(fid));
else
    rPath = pwd;
end
labelsFile = catfile(rPath, 'sensor_labels.txt');
labelsFile = unique_filename(labelsFile);
labelsFid = safefid.fopen(labelsFile, 'w');
fprintf(labelsFid, '%s', join(char(10), sensLabels));

[~, labelsFileName] = fileparts(labelsFile);

count = fprintf(fid, ...
    '%d %s sensors with labels [%s][%s]\n\n', ...
    nb_sensors(obj), class(obj), any2str(sensLabels, MAX_STR_LEN), ...
    labelsFileName);

fprintf(fid, '[%s]: ./%s.txt\n\n', labelsFileName, labelsFileName);

if numel(sensLabels) ~= numel(origSensLabels) || ...
        ~all(ismember(sensLabels, origSensLabels)),
     
    labelsFile = catfile(rPath, 'orig_sensor_labels.txt');
    labelsFile = unique_filename(labelsFile);
    labelsFid = safefid.fopen(labelsFile, 'w');
    fprintf(labelsFid, '%s', join(char(10), origSensLabels));
    
    [~, labelsFileName] = fileparts(labelsFile);
    
    count = count + fprintf(fid, ...
        'Raw sensor labels before importing were: [%s][%s]\n\n', ...
        any2str(origSensLabels, MAX_STR_LEN), labelsFileName);
    
    fprintf(fid, '[%s]: ./%s.txt\n\n', labelsFileName, labelsFileName);
    
end

sensCoords = cartesian_coords(obj);

if size(sensCoords, 1) == nb_sensors(obj) && ~all(isnan(sensCoords(:))),
   
    % Print sensor coordinates to a file
    coordsFile = catfile(rPath, 'sensor_coordinates.csv');
    coordsFile = unique_filename(coordsFile);
    coordsFid = safefid.fopen(coordsFile, 'w');
    
    fprintf(coordsFid, '#X,Y,Z\n');
    for i = 1:size(sensCoords,1),
        fprintf(coordsFid, '%.3f,%.3f,%.3f\n', sensCoords(i,:));
    end
    
    [~, coordsFileName] = fileparts(coordsFile);
    
    count = count + fprintf(fid, ...
        'See the sensor cartesian coordinates: [%s.csv][%s]\n\n', ...
        coordsFileName, coordsFileName);
    
    fprintf(fid, '[%s]: ./%s.csv\n\n', coordsFileName, coordsFileName);
 
else
   fprintf(fid, 'Sensor coordinates are missing\n\n'); 
end

end