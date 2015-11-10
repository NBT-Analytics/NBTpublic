function count = fprintf(fid, obj, varargin)
% FPRINTF - Print physioset information to Remark report
%
% count = fprintf(fid, obj);
% count = fprintf(fid, obj, 'key', value, ...)
%
% Where
%
% FID is a file handle or a safefid.safefid object
%
% OBJ is a physioset object
%
%
% ## Accepted key/value pairs:
%
%       ParseDisp : (boolean).
%           Default: See help physioset.default_method_config
%           If set to true, a summary of the physioset properties will be
%           printed. This will be done by simply parsing the output
%           produced by method disp() of the physioset class.
%
%       SaveBinary: (boolean).
%           Default: See help physioset.default_method_config
%           If set to true, a binary copy of the physioset will be saved
%           and a link to it will be printed to the Remark report
%
% See also: physioset

import misc.process_arguments;
import misc.fid2fname;
import mperl.file.spec.*;
import misc.code2multiline;
import pset.globals;
import meegpipe.get_config;

dataFileExt = get_config('pset', 'data_file_ext');
hdrFileExt  = get_config('pset', 'hdr_file_ext');

origVerbose = goo.globals.get.Verbose;
goo.globals.set('Verbose', false);

opt.ParseDisp   = true;
opt.SaveBinary  = false;

cfg = get_method_config(obj, 'fprintf');
cfg = [cfg(:);varargin(:)];
[~, opt] = process_arguments(opt, cfg);

count = 0;
if opt.ParseDisp,       
    myTable = parse_disp(obj); 
    count = count + fprintf(fid, myTable);
end

if opt.SaveBinary && is_temporary(obj),    
    rPath = fileparts(rel2abs(fid2fname(fid)));
 
    fName = strrep(get_name(obj), '.', '_');
    newDataFile = catfile(rPath, fName);

    if ~exist([newDataFile dataFileExt], 'file'),
        obj = copy(obj, 'DataFile', newDataFile);
    end
    save(obj);
end

if ~is_temporary(obj)  
    dataName    = get_name(obj);

    count = count + ...
        fprintf(fid, '\n%-20s: [%s][%s]\n\n', ...
        'Binary data file', ...
        [dataName dataFileExt], [dataName '-data']);
    
    count = count + ...
        fprintf(fid, '\n%-20s: [%s][%s]\n\n', ...
        'Binary header file', ...
        [dataName hdrFileExt], [dataName '-hdr']);
    
    count = count + ...
        fprintf(fid, '[%s]: %s\n', [dataName '-data'], get_datafile(obj));
    
    count = count + ...
        fprintf(fid, '[%s]: %s\n', [dataName '-hdr'], get_hdrfile(obj));
    
    count = count + ...
        fprintf(fid, '\n\nTo load to MATLAB''s workspace:\n\n');
    
    count = count + fprintf(fid, '[[Code]]:\n');
    
    code = sprintf('data = pset.load(''%s'')', get_hdrfile(obj));
    code = code2multiline(code, [], char(9));
    count = count + fprintf(fid, '%s\n\n', code);   
end

goo.globals.set('Verbose', origVerbose);

end