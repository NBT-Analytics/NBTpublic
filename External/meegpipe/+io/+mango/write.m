function write(file, coords, varargin)
% mango_roi_write - Write point coordinates to a Mango .nii file

me = 'mango:roi_write';

import misc.process_arguments;

[~, ~, ext] = fileparts(file);
if isempty(ext),
    if exist([file '.nii'], 'file'),
        file = [file '.nii'];
    elseif exist([file '.nii.gz'], 'file'),
        file = [file '.nii.gz'];
    end
end
[path, name, ext] = fileparts(file);
origFile = file;
if strcmpi(ext, '.gz'),
    gunzip(file, tempdir);
    origFile = [path name];
    file = [tempdir name];
end


keySet = {'-overwrite', '-color'};
needsValue = false;

overwrite = true;
color = zeros(size(coords,1), 1);

eval(process_arguments(keySet, varargin, needsValue));

if ~overwrite,
    error('Not implemented yet!');
end

fileTmp = tempname;

% Read the NIFTI header using the NIFTI toolbox
% FIX THIS!! YOU HAVE TO CONVERT FROM XYZ TO CRS!
% nii = load_nii_hdr(file);
% Mdc = [-1 0 0;0 0 1;0 -1 0];
% P0 = nii.dime.dim(2:4)'; 
% D = diag(nii.dime.pixdim(2:4));
% V = [eye(3)*D P0];
% coords2 = pinv(V)*coords';

%vox2ras = 

fidTmp = fopen(fileTmp, 'w', 'ieee-le');
try
    fid    = fopen(file, 'r', 'ieee-le');
    try
        fseek(fid, 0, 'bof');
        fseek(fidTmp, 0, 'bof');
        data = fread(fid, 108);
        fwrite(fidTmp, data);
        
        voxOffset = fread(fid, 1, 'float32');
        if voxOffset < 348,
            ME = MException(me, 'File %s is not a valid .nii file', file);
            throw(ME);
        end
        header = fread(fid, 348-ftell(fid));%108
        fseek(fid, voxOffset, 'bof');
        img = fread(fid);
        fclose(fid);
    catch ME
        fclose(fid);
        rethrow(ME);
    end
    
    % Write rest of the header to the output file
    sectionSize = size(coords, 1)*10;
    k = ceil((sectionSize + 24)/16);
    esize = 16*k;
    voxOffset = 16*ceil((348 + 4 + esize)/16);%+4+4
    
    fwrite(fidTmp, voxOffset, 'float32');
    fwrite(fidTmp, header);
    %fseek(fidTmp, -4, 'cof');
    
    % Write the extension tag
    fwrite(fidTmp, [1 0 0 0]);
    
    % Write the ecode and esize tags
    fwrite(fidTmp, esize, 'int32');
    fwrite(fidTmp, 0, 'int32');     % ecode
    
    % Mango specific format for the extension
    fwrite(fidTmp, sectionSize, 'int32');
    for i = 1:size(coords,1)
        fwrite(fidTmp, -9998, 'int16', 0, 'b'); %id
        fwrite(fidTmp, color(i), 'int16', 0, 'b');
        fwrite(fidTmp, coords(i, 1), 'int16', 0, 'b');
        fwrite(fidTmp, coords(i, 2), 'int16', 0, 'b');
        fwrite(fidTmp, coords(i, 3), 'int16', 0, 'b');
    end
    % The other three sections are empty
    fwrite(fidTmp, [0 0], 'int32');
    
    % Write zeroes until voxOffset
    fwrite(fidTmp, zeros(1, voxOffset-ftell(fidTmp)), 'uint8');
    
    % Now write the image data
    fwrite(fidTmp, img);
    fclose(fidTmp);
catch ME
    fclose(fidTmp);
    rethrow(ME);
end
delete(file);
movefile(fileTmp, origFile);
if strcmpi(ext, '.gz'),
    delete([origFile '.gz']);
    gzip(origFile);
    delete(origFile);
end



end