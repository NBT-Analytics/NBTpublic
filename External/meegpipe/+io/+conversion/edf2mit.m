function fname = edf2mit(filename, varargin)
% EDF2MIT - Conversion from EDF to MIT data format
%
% edf2mit(filename)
%
% edf2mit(filename, 'key', value)
%
%
% Where
%
% FILENAME is the name of the EDF file to be converted
%
%
% ## Accepted key/value pairs:
%
% 'ByteOrder'   : (char) Byte ordering of the input file. The alternatives
%                 are 'little-endian' or 'big-endian'. Default: 'big-endian'
%
% 'Record'      : (char) Create the specified record (see [2] for a
%                 definition of record). By default the patient ID field
%                 from the input EDF file will be used as record name.
%
% 'Signals'     : (numeric) A numeric array with the indices of the signals
%                 that should be copied to the generated MIT file. This
%                 option may be used to to re-order or duplicate signals.
%                 Signals are numbered consecutively beginning with zero. 
%                 If left empty, all signals will be copied. Default: []
%
% 'Verbose'     : (logical) If set to true, print debugging info. Default:
%                  false
%
%
% ## Notes:
%
%   * This function calls the WFDB function edf2mit. You can check whether
%     edf2mit is available in your system by typing in MATLAB
%     system('edf2mit -h'). 
%
%   * If edf2mit is not available you will need to install the
%     Physiotoolkit from [4]. 
%
%   * If you installed the Physiotoolkit in Windows using Cygwin (see [5])
%     then you must start MATLAB from a Cygwin console window in order to 
%     system calls to be directed to Cygwin. 
%
%
% ## References:
%
% [1] http://www.physionet.org/physiotools/wag/edf2mi-1.htm
%
% [2] http://www.physionet.org/physiotools/wag/intro.htm#record
%
% [3] http://www.edfplus.info
%
% [4] http://www.physionet.org/physiotools/
%
% [5] http://www.physionet.org/physiotools/wfdb-windows-quick-start.shtml
%
% See also: io.conversion, io.edf


import misc.process_arguments;
import misc.decompress;

opt.ByteOrder   = 'big-endian';
opt.Record      = [];
opt.Signals     = [];
opt.Verbose     = false;

[~, opt] = process_arguments(opt, varargin);

% Decompress file if necessary
[status, filename] = decompress(filename);
isZipped = ~status;


[path, name, ext] = fileparts(filename);


cmd = sprintf('cd %s && edf2mit -i %s', path, [name ext]);

if ~isempty(opt.Record),
    cmd = [cmd sprintf(' -r %s', opt.Record)];
end

if ~isempty(opt.Signals),
    cmd = [cmd sprintf(' -s %s', num2str(opt.Signals))];
end

if opt.Verbose,
    cmd = [cmd ' -v '];
end

if strcmpi(opt.ByteOrder, 'little-endian'),
    cmd = [cmd '-b'];
elseif ~strcmpi(opt.ByteOrder, 'big-endian'),
    ME = MException('io:conversion:edf2mit:InvalidByteOrder', ...
        'ByteOrder alternatives are ''Big-endian'' and ''Little-endian''');
    throw(ME);
end

[status, output] = system(cmd);

if status,
   ME = MException('io:conversion:edf2mit:InvalidByteOrder' ...
       ,'Something went wrong when system-calling edf2mit: %s', output);
   throw(ME);
end

if opt.Verbose,
    disp(output);
end

if isZipped,
    delete(filename);
end

end