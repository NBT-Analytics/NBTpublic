function [coord, color, id] = read(file)
% mango_roi_read - Read point ROI coordinates from a Mango .nii file

me = 'mango:roi_read';

[~, ~, ext] = fileparts(file);
if isempty(ext),
    if exist([file '.nii'], 'file'),
        file = [file '.nii'];
    elseif exist([file '.nii.gz'], 'file'),
        file = [file '.nii.gz'];
    end
end
[~, name, ext] = fileparts(file);
if strcmpi(ext, '.gz'),
    gunzip(file, tempdir);
    file = [tempdir name];
end

try
    fid = fopen(file, 'r', 'ieee-le');
    
    fseek(fid, 0, 'bof');
    
    if fread(fid, 1, 'int32') ~= 348,
        ME = MException(me, 'File %s is not a valid .nii file');
        throw(ME);
    end
    
    fseek(fid, 108, 'bof');
    voxOffset = fread(fid, 1, 'float32');
    
    if voxOffset < 348,
        ME = MException(me, 'File %s is not a valid .nii file', file);
        throw(ME);
    end
    
    if voxOffset < 352,
        coord = [];
        warning(me, 'There are no point ROIs in file %s', file);
        return;
    end
    
    fseek(fid, 348, 'bof');
    extension = fread(fid, 4);
    
    if extension(1) == 0,
        coord = [];
        warning(me, 'There are no point ROIs in file %s', file);
        return;
    end
    
    fread(fid, 1, 'int32'); % esize
    fread(fid, 1, 'int32'); % ecode
    
    % Now comes the Mango-specific format
    sectionSize = fread(fid, 1, 'int32');
    nPoints = floor(sectionSize/10);
    if nPoints*10 ~= sectionSize,
        ME = MException(me, 'Unexpected section size');
        throw(ME);
    end
    coord = nan(nPoints, 3);
    color = nan(nPoints, 1);
    id = nan(nPoints, 1);
    for i = 1:nPoints
        id(i)       = fread(fid, 1, 'int16', 0, 'b');
        tmp         = fread(fid, 2, 'int8', 0, 'b');
        color(i)    = tmp(end);
        coord(i,1)  = fread(fid, 1, 'int16', 0, 'b');
        coord(i,2)  = fread(fid, 1, 'int16', 0, 'b');
        coord(i,3)  = fread(fid, 1, 'int16', 0, 'b');
    end
    fclose(fid);
    
catch ME
    fclose(fid);
    rethrow(ME);    
end

if strcmpi(ext, '.gz'),
    delete(file);
end

end