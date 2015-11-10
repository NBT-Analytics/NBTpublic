function [hdr, dat, tal_cell, time] = read(filename, varargin)
% READ Reads an EDF+ file. Allows for non-continuous recordings.
%
%   [HDR] = read(FILENAME) reads file FILENAME and returns a structure HDR
%   containing the file header information.
%
%   [HDR] = read(FILENAME, OPT1, VAL1, ..., OPTN, VALN) where (OPT, VAL)
%   are pairs of property name and corresponding property value.
%
%   [HDR, DAT] = read(FILENAME) reads also the signal values and returns
%   them in matrix DAT.
%
%   [HDR, DAT, TAL_CELL] = read(FILENAME) returns a cell array with the
%   Time Annotated Lists contained in the data file.
%
%   [HDR, DAT, TAL_CELL] = read(FILENAME, 'OnlyAnnotations', true) does not
%   read any signal values so that DAT will be an empty matrix.
%
%   [HDR, DAT, TAL_CELL, TIME] = read(FILENAME) returns also a vector TIME
%   that contains the sampling times corresponding to each column of DAT.
%
%
%   Property/Value pairs and descriptions:
%
%       StartTime: Scalar (defaults to 0)
%           First time instant (in seconds) to read from the file.
%
%       EndTime: Scalar (defaults to the maximum possible value)
%           Last time instant (in seconds) to read from the file.
%
%       StartRec: Scalar (default to 1)
%           First record to read.
%
%       EndRec: Scalar (defaults to the last available record)
%           Last record to read.
%
%       SignalIndices: Scalar array (defaults to all available signals)
%           Indices of the signals to be read from the file.
%
%       SignalType: Cell array (defaults to {}, i.e. any valid type)
%           See edfplus.signal_types for all valid signal types.
%
%       Precision: Char array (defaults to 'double')
%           Precision of the signal values returned by the function.
%           Supported char arrays are 'single', 'double'.
%
%       OnlyAnnotations: Logical value (default: false)
%           If set to true, the function will not read the signal values
%           and output variable DAT will be empty.
%
%       Hdr: Struct (default: [])
%           Header information. If this is provided, read() will not try to
%           read the header information. This is a desirable behaviour when
%           reading a data file in chunks since it avoids reading the
%           header each time the file is accessed.
%
%       Verbose: Logical value (default: true)
%           Determines whether status messages should be displayed during
%           execution.
%
%   Note 1:
%   -------
%   When various signals have different sampling rates, signals having lower
%   sampling rates will be upsampled to match the highest sampling rate
%   accross signals.
%
%   Note 2:
%   -------
%   The options StartRecord and EndRecord are meant to be used by functions
%   that need to read the whole file but that want to load small data chunks
%   at a time.
%
%
%
%
%
% See also: io.edfplus, io

import io.edfplus.globals;
import io.edfplus.signal_types;
import io.edfplus.dimension_prefixes;
import misc.get_tokens;
import misc.deblank;
import misc.strtrim;
import misc.process_varargin;
import misc.isinteger;
import misc.decompress;
import misc.eta;
import mperl.join;
import safefid.safefid;

% Constants
PID_SUBFIELDS = {'code', 'sex', 'birthdate', 'name'};
RID_SUBFIELDS = {'startdate','investigation_id','investigator_id','equipment_id'};
NS_THRESHOLD = 10;  % Between 0 and the number of signals in the file

if nargin < 1, help read_edfplus; end

% Options recognized by this function
THIS_OPTIONS = {'starttime', 'endtime', 'startrec', 'endrec', ...
    'signalindices', 'precision', 'onlyannotations', 'verbose', ...
    'signaltype', 'hdr'};

% Default parameter values
signaltype          = {};
verbose             = true;
endtime             = [];
starttime           = [];
startrec            = [];
endrec              = [];
signalindices       = [];
precision           = globals.get.Precision;
onlyannotations     = false;
hdr                 = [];

% Process varargin
eval(process_varargin(THIS_OPTIONS, varargin));
chan_idx = signalindices; % just a shortcut name

if verbose,
    fprintf('\n');
    start_cputime = cputime;
end

% Output
dat         = [];
tal_cell    = [];
time        = [];

% Check that input parameters are valid
if ~isempty(chan_idx) && (~isnumeric(chan_idx) || ...
        any(chan_idx < 1)),
    error('EDFPLUS:read:invalidInput', ...
        'Channel indices must be an array of natural numbers.');
end
if ~isempty(endtime) && (numel(endtime) > 1 || ...
        endtime < 0 || isnan(endtime)), %#ok<*BDSCI>
    error('EDFPLUS:read:invalidInput', ...
        'End time must be a positive scalar.');
end
if ~isempty(starttime) && (numel(starttime) > 1 || ...
        starttime < 0 || isnan(starttime)),
    error('EDFPLUS:read:invalidInput', ...
        'Beginning time must be a positive scalar.');
end
if ~isempty(endrec) && (numel(endrec) > 1 || ...
        endrec < 1 || isnan(endrec)),
    error('EDFPLUS:read:invalidInput', ...
        'End record must be a natural number.');
end
if ~isempty(startrec) && (numel(startrec) > 1 || ...
        startrec < 1 || isnan(startrec)),
    error('EDFPLUS:read:invalidInput', ...
        'Beginning record must be a natural number.');
end
if isempty(filename) || ~ischar(filename) || ...
        ~exist(filename, 'file'),
    error('EDFPLUS:read:invalidInput', ...
        'The input argument must be a valid file name.');
end

% Check that the data range has been properly specified
if ((~isempty(starttime) || ~isempty(endtime)) && ...
        (~isempty(startrec) || ~isempty(endrec))) || ...
        ((~isempty(startrec) || ~isempty(endrec)) && ...
        (~isempty(starttime) || ~isempty(endtime))),
    error('io:edfplus:read:invalidInput', ...
        'Data range has to be specified in records or time but not in both.');
end


% Uncompress the file if necessary

[status, filename] = decompress(filename, 'Verbose', verbose);
bzipped = ~status;


% #########################################################################
% READ FILE HEADER
% #########################################################################
fid = safefid.fopen(filename, 'r', 'ieee-le');

if isempty(hdr),
    if verbose,
        fprintf('\n(io:edfplus:read) Reading file header...');
    end
    if fid < 0,
        error('io:edfplus:read:InvalidFile', ...
            'I could not open file %s.', filename);
    end
    [path_name, name, ext] = fileparts(filename);
    hdr.file.full_name = filename;
    hdr.file.path = path_name;
    hdr.file.name = name;
    hdr.file.ext = ext;
    
    % Read the header
    H = fread(fid, 256, 'char=>char')';
    
    hdr.version = str2double(H(1:8));       % Version (0): 8 ascii
    
    tmp = get_tokens(deblank(H(9:88)),' '); % Local patient ID: 80 ascii with subfields
    for i = 1:length(tmp)
        if i <= length(PID_SUBFIELDS)
            hdr.pid.(PID_SUBFIELDS{i}) = tmp{i};
        else
            hdr.pid.(['subfield_' num2str(i)]) = tmp{i};
        end
    end
    if verbose,
        if isfield(hdr.pid, 'code'),
            fprintf(...
                '\n(io:edfplus:read) :::: Patient code is ''%s''', ...
                hdr.pid.code);
        end
        if isfield(hdr.pid, 'sex'),
            fprintf(...
                '\n(io:edfplus:read) :::: Patient sex is ''%s''',...
                hdr.pid.sex);
        end
        if isfield(hdr.pid, 'birthdate'),
            fprintf(...
                '\n(io:edfplus:read) :::: Patient birthdate is %s', ...
                hdr.pid.birthdate);
        end
        if isfield(hdr.pid, 'name'),
            fprintf(...
                '\n(io:edfplus:read) :::: Patient name is ''%s''', ...
                strrep(hdr.pid.name,'_',' '));
        end
    end
    
    
    tmp = get_tokens(deblank(H(89:168)),' ');   % Local rec. ID: 80 ascii with subfields
    if ~strcmpi(tmp{1}, 'startdate'),
        if verbose,
            fprintf('\n');
            warning('io:edfplus:read:invalidHeader',...
                'Invalid RID in file-specific header of file %s', ...
                hdr.file.name);
            fprintf('\n');
        end
    else
        tmp(1)=[];
    end
    for i = 1:length(tmp)
        if i <= length(RID_SUBFIELDS)
            hdr.rid.(RID_SUBFIELDS{i}) = tmp{i};
        else
            hdr.rid.(['subfield_' num2str(i)]) = tmp{i};
        end
    end
    if verbose,
        if isfield(hdr.rid, 'investigation_id'),
            fprintf(...
                '\n(io:edfplus:read) :::: Investigation ID is ''%s''', ...
                hdr.rid.investigation_id);
        end
        if isfield(hdr.rid, 'investigator_id'),
            fprintf(...
                '\n(io:edfplus:read) :::: Investigator ID is ''%s''', ...
                hdr.rid.investigator_id);
        end
        if isfield(hdr.rid, 'equipment_id'),
            fprintf(...
                '\n(io:edfplus:read) :::: Equipment ID is ''%s''',...
                hdr.rid.equipment_id);
        end
    end
    
    % Time and date when the recording was started
    start_date = get_tokens(H(168 + (1:8)),'.');
    if start_date{3} < 85,
        hdr.start_date = [start_date{1} '.' start_date{2} '.' '20' ...
            start_date{3}];
    else
        hdr.start_date = [start_date{1} '.' start_date{2} '.' '19' ...
            start_date{3}];
    end
    hdr.start_time = H(168 + (9:16));
    if verbose,
        fprintf(['\n(io:edfplus:read) :::: Recording started on ' ...
            'date %s at time %s'],...
            hdr.start_date, hdr.start_time);
    end
    
    % Start date/time of the recording as a date vector (see help datenum)
    hdr.t0 = [str2num(H(168+[7 8])) ... % start year
        str2num(H(168+[4 5])),...       % start month
        str2num(H(168+[1 2])),...       % start day
        str2num(H(168+[9 10])),...      % start hour
        str2num(H(168+[12 13])),...     % start minute
        str2num(H(168+[15 16]))];       % start second
    
    % Header length in bytes
    hdr.header_size = str2double(H(185:192));
    
    % Is this a continuous or interrupted EDF+ recording?
    edfplus_type = H(193:197);
    if ~ismember(lower(edfplus_type), {'edf+d','edf+c'}),
        if verbose,
            fprintf('\n');
            warning('EDFPLUS:read', ...
                ['Unable to determine whether the file is '  ...
                'continuous or interrupted.']);
            fprintf('\n');
        end
        hdr.edfplus_type = edfplus_type;
    else
        if verbose,
            fprintf('\n(io:edfplus:read) :::: This is an %s file', ...
                upper(edfplus_type));
        end
        hdr.edfplus_type = edfplus_type;
    end
    
    hdr.nrec = str2double(H(237:244));     % # of data records
    hdr.dur = str2double(H(245:252));      % # duration of a data rec in secs
    hdr.ns = str2double(H(253:256));       % # number of sensors
    if verbose,
        fprintf(['\n(io:edfplus:read) :::: File contains %d data ' ...
            'records of %4.3f seconds each'], ...
            hdr.nrec, hdr.dur);
    end
    
    % Label for each signal: signal type + signal specification
    hdr.label = mat2cell(fread(fid,[16,hdr.ns],'char=>char')', ...
        ones(1,hdr.ns),16);
    hdr.label = cellfun(@(x) misc.strtrim(x), hdr.label, ...
        'UniformOutput', false);
    % Check validity of the signal types
    signal_type_idx = nan(size(hdr.label));
    
    [valid_signals, valid_dim] = signal_types;
    hdr.is_annotation = ismember(hdr.label, 'EDF Annotations');
    hdr.is_signal = ~hdr.is_annotation;
    
    hdr.channel_type = repmat({''},hdr.ns,1);
    
    for i = 1:numel(hdr.label)
        
        if hdr.is_annotation(i), continue; end
        
        tmp = get_tokens(hdr.label{i}, ' ');
        
        [is_valid_signal_type, loc] = ismember(tmp(1),valid_signals);
        
        if ~is_valid_signal_type
            
            if verbose,
                fprintf('\n');
                warning('io:edfplus:read:unknownSignalType', ...
                    'Unknown signal type ''%s'' in channel %d', ...
                    tmp{1}, i);
                fprintf('\n');
                
            end
            
            hdr.channel_type{i} = 'Unknown';
            signal_type_idx(i)  = numel(valid_signals);
            
            
        elseif is_valid_signal_type && (isempty(signaltype) || ...
                ismember(tmp(1), signaltype)),
            
            signal_type_idx(i)  = loc;
            
            hdr.channel_type{i} = tmp{1};
            
            
        end
    end
    
    if verbose,
        nbSignals  = numel(find(hdr.is_signal));
        nbAnn      = numel(find(hdr.is_annotation));
        
        fprintf(['\n(io:edfplus:read) :::: File contains %d valid'  ...
            ' EDF+ signals and %d EDF+ annotation channels'], ...
            nbSignals, nbAnn);
        
    end
    
    % Transducer type
    hdr.transducer = mat2cell(fread(fid,[80,hdr.ns],'char=>char')', ...
        ones(1,hdr.ns),80);
    
    % Physical dimensions
    hdr.physdim = mat2cell(fread(fid,[8,hdr.ns],'char=>char')', ...
        ones(1,hdr.ns),8);
    [valid_prefix, power] = dimension_prefixes;
    hdr.physdim_power  = nan(hdr.ns,1);
    hdr.physdim_prefix = repmat(' ', hdr.ns, 1);
    hdr.physdim_basic  = cell(hdr.ns, 1);
    % Check the validity of signal dimensions
    for i = 1:numel(hdr.physdim)
        if ~hdr.is_signal(i), continue; end
        dims = valid_dim{signal_type_idx(i)};
        for ii = 1:length(dims),
            pos = strfind(hdr.physdim{i}, dims{ii});
            if ~isempty(pos), break; end
        end
        if isempty(pos),
            if verbose,
                fprintf('\n');
                warning('io:edfplus:read:unknownDimension', ...
                    'Unknown data dimension ''%s'' in channel %d (%s)', ...
                    strtrim(hdr.physdim{i}), i, strtrim(hdr.label{i}));
                fprintf('\n');
            end
        else
            if pos > 1,
                % Check also the validity fo the prefix
                [is_valid_prefix, loc] = ...
                    ismember(hdr.physdim{i}(1:(pos-1)), valid_prefix);
                if is_valid_prefix,
                    hdr.physdim_power(i) = power(loc);
                    hdr.physdim_prefix(i) = valid_prefix{loc};
                else
                    if verbose,
                        fprintf('\n');
                        warning('io:edfplus:read:unknownDimensionPrefix', ...
                            'Unknown dimension prefix ''%s'' in channel %d', ...
                            hdr.physdim{i}(1:pos), i);
                        fprintf('\n');
                    end
                end
            end
            hdr.physdim_basic{i} = hdr.physdim{i}(pos);
        end
    end
    hdr.physmin = str2num(fread(fid,[8,hdr.ns],'char=>char')');
    hdr.physmax = str2num(fread(fid,[8,hdr.ns],'char=>char')');
    hdr.digmin = str2num(fread(fid,[8,hdr.ns],'char=>char')');
    hdr.digmax = str2num(fread(fid,[8,hdr.ns],'char=>char')');
    
    % Check consistency of min/max limits
    wrong_chans = 1:hdr.ns;
    wrong_chans = wrong_chans(hdr.physmin(hdr.is_signal) > hdr.physmax(hdr.is_signal));
    if ~isempty(wrong_chans),
        if verbose,
            fprintf('\n');
            warning('io:edfplus:read:maxLessThanMin',...
                ['Physical minimum is greater than physical ' ...
                'maximum for %d channel(s)'],...
                length(wrong_chans));
        end
    end
    wrong_chans = 1:hdr.ns;
    wrong_chans = wrong_chans(hdr.digmin(hdr.is_signal) > hdr.digmax(hdr.is_signal));
    if ~isempty(wrong_chans),
        if verbose,
            fprintf('\n');
            warning('io:edfplus:read:maxLessThanMin',...
                ['Digital minimum is greater than physical maximum ' ...
                'for channel(s) [%d]'], wrong_chans);
        end
    end
    
    % Prefiltering settings
    hdr.prefilt = mat2cell(fread(fid,[80,hdr.ns],'char=>char')',ones(1,hdr.ns),80);
    
    % Number of samples in each data record
    hdr.spr = str2num(fread(fid, [8, hdr.ns], 'char=>char')'); %#ok<*ST2NM>
    
    status = fseek(fid, 32*hdr.ns, 0); % skip ns*32 ascii characters (reserved)
    if status,
        
        error('io:edfplus:read:fseekFailed', 'Fseek failed');
    end
    
    % Offset and amplification of the signal
    hdr.cal = nan(hdr.ns,1);
    hdr.off = nan(hdr.ns,1);
    hdr.cal(hdr.is_signal) = (hdr.physmax(hdr.is_signal) - hdr.physmin(hdr.is_signal))./...
        (hdr.digmax(hdr.is_signal) - hdr.digmin(hdr.is_signal));
    hdr.off(hdr.is_signal) = hdr.physmin(hdr.is_signal) - hdr.cal(hdr.is_signal).*hdr.digmin(hdr.is_signal);
    
    % Sampling rate
    hdr.sr = nan(hdr.ns,1);
    hdr.sr(hdr.is_signal) = hdr.spr(hdr.is_signal) ./ hdr.dur;
    
    if verbose,
        fprintf('\n(io:edfplus:read) Done reading file header\n');
    end
    
    % File size in bytes
    status = fseek(fid,0,'eof');
    if status,
        
        error('io:edfplus:read:fseekFailed', 'Fseek failed');
    end
    hdr.file_size = ftell(fid);
    
    % Record size in bytes
    hdr.record_size = sum(hdr.spr)*2;
    
    % Check consistency of the header
    if abs(hdr.record_size*hdr.nrec+hdr.header_size-hdr.file_size)>0,
        header_duration = hdr.dur*hdr.nrec;
        true_duration = hdr.dur*(hdr.file_size-hdr.header_size)/hdr.record_size;
        if header_duration ~= true_duration,
            true_nrec = (hdr.file_size-hdr.header_size)/hdr.record_size;
            
            if true_nrec <  1,
                [~, name, ext] = fileparts(filename);
                error('%s contains no records', [name ext]);
            end
            
            if isinteger(true_nrec),
                if verbose,
                    warning('io:edfplus:read:inconsistentHeader', ...
                        [...
                        'Header says %d records but there are %d records ' ...
                        'in this file: %d records will be used'...
                        ], hdr.nrec, true_nrec, true_nrec);
                    hdr.nrec = true_nrec;
                end
            else
                
                error('io:edfplus:read:inconsistentHeader', ...
                    'Inconsistent header information');
            end
        end
    end    
    
    if verbose, fprintf('\n'); end
    
end

if isempty([starttime, endtime, startrec, endrec]),
    startrec = 1;
    endrec = hdr.nrec;
end

% #########################################################################
% READ ANNOTATIONS
% #########################################################################



% Read annotations if required or if records are not contiguous in time
% Read record onset
[tf, ann_chan_idx] = ismember(hdr.label, 'EDF Annotations');
ann_chan_idx = find(ann_chan_idx);

% Offset in bytes of each Annotation channel
within_rec_offset = zeros(length(ann_chan_idx),1);
for i = 1:length(ann_chan_idx),
    within_rec_offset(i) = sum(hdr.spr(1:(ann_chan_idx(i)-1)))*2;
end

if ~any(tf) || nargout < 3,
    if verbose && strcmpi(hdr.edfplus_type, 'edf+d'),
        fprintf('\n');
        warning('io:edfplus:read:noncontiguousRecords',...
            'Assuming continuous records in an EDF+D file!');
        fprintf('\n');
        
    elseif verbose,
        fprintf('\n');
        warning('io:edfplus:read:invalidFile',...
            'Time annotations could not be found: I will assume continuous records.');
        fprintf('\n');
        
    end
    % We assume continuous records that start at the same time as the file
    rec_onset = 0:hdr.dur:(hdr.dur*hdr.nrec-hdr.dur);
else
    if verbose,
        fprintf('\n(io:edfplus:read) Reading annotations...');
    end
    tal_struct = struct('onset',{[]},...
        'onset_samples',NaN,...
        'duration',{0},...
        'duration_samples', {1},...
        'annotations',{{}});
    tal_cell = cell(length(ann_chan_idx), hdr.nrec);
    
    % Go the beginning of the data records
    status = fseek(fid, hdr.header_size, 'bof');
    if status,       
        error('io:edfplus:read:fseekFailed', 'Fseek failed');
    end
    pos = ftell(fid);
    % Record counter
    rec_count = 1;
    
    % Loop accross data records
    nrec_by100 = max(1,floor(hdr.nrec/100));
    tinit = tic;
    while pos < hdr.file_size
        % Read a single annotation channel
        for chan_itr = 1:length(ann_chan_idx)
            status = fseek(fid, pos + within_rec_offset(chan_itr), 'bof');
            if status,               
                error('io:edfplus:read:fseekFailed', 'Fseek failed');
            end
            data = fread(fid, hdr.spr(ann_chan_idx(chan_itr))*2,'char=>char')';
            % Each TAL is a token
            data_tokens = get_tokens(data,char(0));%deblank
            tal_cell{chan_itr, rec_count} = repmat(tal_struct, 1, length(data_tokens));
            % First TAL stores record onset
            for j = 1:length(data_tokens)
                % Each annotation is a sub-token
                data_subtokens = get_tokens(data_tokens{j},char(20));%deblank(
                tmp = get_tokens(data_subtokens{1}, char(21));
                if length(tmp) > 2,                   
                    error('EDFPLUS:read_edfplus:invalidTAL', ...
                        'Found a TAL with multiple durations.');
                end
                tal_cell{chan_itr, rec_count}(j).onset = str2double(tmp{1});
                if length(tmp) > 1,
                    tal_cell{chan_itr, rec_count}(j).duration = str2double(tmp{2});
                end
                % Other sub-tokens are individual annotations
                if length(data_subtokens) > 1,
                    tal_cell{chan_itr, rec_count}(j).annotations = data_subtokens(2:end);
                end
            end  
        end
        % Move to the next data record
        pos = pos + hdr.record_size;
        rec_count = rec_count + 1;
        if verbose && ~mod(rec_count, nrec_by100),
            misc.eta(tinit, hdr.nrec, rec_count, 'remaintime', true);
        end
    end
    if rec_count < hdr.nrec,      
        error('io:edfplus:read:invalidTAL', ...
            'File size is inconsistent with file header information.');
    end
    if strcmpi(hdr.edfplus_type, 'edf+d'),
        rec_onset = zeros(1,hdr.nrec);
        % Onset times are stored in the first TAL of the first annotations channel
        for i = 1:hdr.nrec
            rec_onset(i) = tal_cell{1, i}(1).onset;
        end
    else
        t0 = tal_cell{1, 1}(1).onset;
        % Initalize the vector of records' onset times
        rec_onset = t0:hdr.dur:(t0+(hdr.dur*(hdr.nrec-1)));
    end
    if verbose,
        fprintf('\n\n(io:edfplus:read) Done reading annotations\n');
    end
    
end


% #########################################################################
% READ SIGNAL VALUES
% #########################################################################
if isempty(chan_idx),
    chan_idx = find(~hdr.is_annotation);
end


if nargout > 1 && ~onlyannotations,
    if verbose,
        fprintf('\n(io:edfplus:read) Reading signal values...    ');
    end
    
    if isempty(chan_idx),
        if verbose,
            fprintf('\n');
            warning('io:edfplus:read:noSignals', ...
                'No valid signal values could be found. Is this an EDF+ file?');
            fprintf('\n');
        end
        time = [];
        dat = [];
        return;
    end
    
    % All channels will be upsampled to the max. sampling rate
    sr  = max(hdr.sr(chan_idx));
    spr = max(hdr.spr(chan_idx));
    ns  = length(chan_idx);
    
    % Check that the record range (if provided) is valid
    if (~isempty(endrec) && endrec > hdr.nrec) || ...
            ~isempty(startrec) && startrec > hdr.nrec,       
        error('io:edfplus:read:invalidRecordRange',...
            'The file contains only %d records.', hdr.nrec);
    end
    
    % Data range to read (in time)
    if isempty(starttime),
        if isempty(startrec),
            starttime = rec_onset(1);
        else
            starttime = rec_onset(startrec);
        end
    end
    if isempty(endtime),
        if isempty(endrec)
            endtime = rec_onset(end)+hdr.dur;
        else
            endtime = rec_onset(endrec)+hdr.dur;
        end
    end
    
    % Check that the time range is valid
    if starttime < rec_onset(1),       
        error('io:edfplus:read:invalidTimeRange', ...
            'Data records start at time t0 = %d seconds.', rec_onset(1));
    end
    if endtime > rec_onset(end)+hdr.dur,        
        error('io:edfplus:read:invalidTimeRange', ...
            'Data records end at time t0 = %d seconds.', rec_onset(end)+hdr.dur);
    end
    
    % Records that contain the begin and end sample
    if isempty(startrec),
        startrec = find(rec_onset >= starttime, 1);
        if isempty(startrec),
            startrec = hdr.nrec;
        end
    end
    if isempty(endrec),
        endrec = find(rec_onset < endtime, 1, 'last');
        if isempty(endrec),
            endrec = hdr.nrec;
        end
    end
    
    % Check that the requested time-range is really in the file
    if (starttime < rec_onset(startrec)) || ...
            (endtime > rec_onset(endrec)+hdr.dur),       
        ME = MException('read', 'Invalid temporal range');
        throw(ME);
    end
    
    % Range of samples to be read
    beg_sample = floor((starttime-rec_onset(startrec))*sr)+1;
    end_sample = min(ceil((endtime-rec_onset(endrec))*sr),spr);
    
    n_rec = endrec - startrec + 1;
    %rec_onset_datarange = rec_onset(startrec:endrec);
    beg_offset = beg_sample-1;
    end_offset = spr-end_sample;
    
    % Initialize the output data matrix
    dat = nan(ns, spr*n_rec-max(0,beg_offset)-max(0,end_offset));
    
    % Offset in samples for all channels
    samples_offset = zeros(hdr.ns,1);
    for i = 1:hdr.ns
        samples_offset(i) = (startrec-1)*sum(hdr.spr)+sum(hdr.spr(1:(i-1)));
    end
    
    % Go the beginning of the data records
    status = fseek(fid, hdr.header_size, 'bof');
    if status,       
        error('io:edfplus:read:fseekFailed', 'fseek failed');
    end
    pos = ftell(fid);
    
    % Record counter
    rec_count = 1;
    fread_format = ['bit16=>' precision];
    
    % Most favorable case is if condition is true
    condition = all(hdr.spr(chan_idx)==spr) &&...
        all(diff(chan_idx)==1);
    
    nrec_by100 = max(1, floor(hdr.nrec/100));
    tinit = tic;
    if condition,
        % Fastest case
        block_size = spr*ns;
        while rec_count <= n_rec
            % Read only the requested channels
            status = fseek(fid, pos + samples_offset(1)*2, 'bof');
            if status,            
                error('io:edfplus:read:fseekFailed', 'fseek failed');
            end
            [ch_data, read_count] = fread(fid, block_size, fread_format);
            if read_count < block_size,          
                error('io:edfplus:read:freadFailed', 'fread failed');
            end
            ch_data = ch_data';
            tmp = reshape(ch_data, spr, ns)';
            
            tmp = tmp - repmat(hdr.digmin(chan_idx), 1, spr);
            % Calibrate the data
            if length(chan_idx) == 1,
                tmp = hdr.cal(chan_idx)*tmp;
            else
                tmp = full(sparse(diag(hdr.cal(chan_idx)))*tmp);
            end
            tmp = tmp + repmat(hdr.physmin(chan_idx), 1, spr);
            ipos = 1:spr;
            if n_rec == 1
                ipos = ipos(1+beg_offset:end-end_offset);
            elseif rec_count < 2
                ipos = ipos(1+beg_offset:end);
            elseif rec_count == n_rec
                ipos = ipos(1:end-end_offset);
            end
            dat(:, (rec_count-1)*spr+ipos) = tmp(:, ipos);
            
            % Move to the next data record
            pos = pos + hdr.record_size;
            rec_count = rec_count + 1;
            if verbose && ~mod(rec_count, nrec_by100),
                eta(tinit, n_rec, rec_count);
            end
        end
        
    elseif ns < NS_THRESHOLD
        % This should be better when reading only few channels
        while rec_count <= n_rec
            for chan_itr = 1:ns
                status = fseek(fid, pos + ...
                    samples_offset(chan_idx(chan_itr))*2, 'bof');
                if status,
                    error('io:edfplus:read:fseekFailed', 'fseek failed');
                end
                [ch_data, read_count] = ...
                    fread(fid, hdr.spr(chan_idx(chan_itr)), fread_format);
                if read_count < hdr.spr(chan_idx(chan_itr)),
                    
                    error('io:edfplus:read:freadFailed', 'fread failed');
                end
                ch_data = ch_data';
                ipos = round(linspace(1, spr, hdr.spr(chan_idx(chan_itr))));
                % Calibrate the data
                % This calibration below has not been properly tested yet!!
                ch_data = ch_data - repmat(hdr.digmin(chan_idx), 1, ...
                    size(ch_data,2));
                ch_data = hdr.cal(chan_idx(chan_itr))*ch_data;
                ch_data = ch_data + ...
                    repmat(hdr.physmin(chan_idx), 1, size(ch_data,2));
                if n_rec == 1
                    ipos = ipos(1+beg_offset:end-end_offset);
                elseif rec_count < 2
                    ipos = ipos(1+beg_offset:end);
                elseif rec_count == n_rec
                    ipos = ipos(1:end-end_offset);
                end
                dat(chan_itr, (rec_count-1)*spr+ipos) = ch_data(1:length(ipos));
            end
            % Move to the next data record
            pos = pos + hdr.record_size;
            rec_count = rec_count + 1;
            if verbose && ~mod(rec_count, nrec_by100),
                eta(tinit, n_rec, rec_count);
            end
        end
    else
        % Otherwise read a whole record and pick only the relevant signals
        record_size_samples = sum(hdr.spr);
        offset_within_rec = cumsum(hdr.spr);
        offset_within_rec = offset_within_rec - offset_within_rec(1);
        this_offset = offset_within_rec(chan_idx);
        while rec_count <= n_rec
            % Read all channels and discard those that are not needed
            [ch_data, read_count] = fread(fid, record_size_samples, fread_format);
            if read_count < record_size_samples,
                
                error('io:edfplus:read:freadFailed', 'fread failed');
            end
            ch_data = ch_data';
            
            for chan_itr = 1:ns
                if hdr.spr(chan_idx(chan_itr)) < spr,
                    ipos = round(linspace(1, spr, hdr.spr(chan_idx(chan_itr))));
                else
                    ipos = 1:spr;
                end
                if n_rec == 1
                    ipos = ipos(1+beg_offset:end-end_offset);
                elseif rec_count < 2
                    ipos = ipos(1+beg_offset:end);
                elseif rec_count == n_rec
                    ipos = ipos(1:end-end_offset);
                end
                
                % Calibration
                % This calibration has not been properly tested!!
                tmp = ch_data(this_offset(chan_itr)+(1:length(ipos)));
                digmin = hdr.digmin(chan_idx);
                tmp = tmp - repmat(digmin(chan_itr), 1, numel(tmp));
                tmp = hdr.cal(chan_idx(chan_itr))*tmp;
                physmin = hdr.physmin(chan_idx);
                tmp = tmp + repmat(physmin(chan_itr), 1, numel(tmp));
                dat(chan_itr, (rec_count-1)*spr+ipos) = tmp;
                
            end
            % Move to the next data record
            pos = pos + hdr.record_size;
            rec_count = rec_count + 1;
            if verbose && ~mod(rec_count, nrec_by10),
                fprintf('.');
            end
        end
    end
    if verbose,
        fprintf('\n(io:edfplus:read) Done reading signal values\n');
    end
    
end

% #########################################################################
% Determine the sample index and the duration in samples of each TAL
% #########################################################################

if ~isempty(tal_cell),
    if verbose,
        fprintf('\n(io:edfplus:read) Computing sample indices for the annotations...\n');
    end
    % This part is messy! -> Fix it
    if isempty(starttime),
        if ~isempty(startrec),
            starttime = rec_onset(startrec);
        else
            starttime = rec_onset(1);
        end
    end
    if isempty(endtime),
        if ~isempty(endrec),
            endtime = rec_onset(endrec);
        else
            endtime = rec_onset(end);
        end
    end
    
    sr = max(hdr.sr(chan_idx));
    spr = max(hdr.spr(chan_idx));
    n_rec = endrec - startrec + 1;
    rec_onset_datarange = rec_onset(startrec:endrec);
    beg_sample = floor((starttime-rec_onset(startrec))*sr)+1;
    end_sample = min(ceil((endtime-rec_onset(endrec))*sr),spr);
    beg_offset = beg_sample-1;
    end_offset = spr-end_sample;
    
    n_cell = numel(tal_cell);
    n_cell_by100 = floor(n_cell/100);
    for i = 1:size(tal_cell,1)
        for ii = startrec:endrec
            for j = 1:length(tal_cell{i,ii}),
                % Determine in which record this time instant falls
                rec_idx = find(tal_cell{i,ii}(j).onset >= ...
                    rec_onset_datarange((ii-startrec+1):n_rec),1,'last')+(ii-startrec);
                
                if isempty(rec_idx) && abs(...
                        rec_onset_datarange(ii-startrec+1) - ...
                        tal_cell{i,ii}(j).onset) < 1e-4,
                    rec_idx = ii-startrec+1;
                end
                
                if tal_cell{i,ii}(j).duration > ...
                        (hdr.dur - (tal_cell{i,ii}(j).onset -...
                        rec_onset_datarange(rec_idx))),
                    rec_idx2 = find((tal_cell{i,ii}(j).onset + ...
                        tal_cell{i,ii}(j).duration) >= ...
                        rec_onset_datarange((ii-startrec+1):n_rec),1,'last');
                else
                    rec_idx2 = rec_idx;
                end
                if (isempty(rec_idx) || isempty(rec_idx2)) && ...
                        (abs(tal_cell{i,ii}(j).onset - rec_onset_datarange(1))<eps && ...
                        (~isempty(rec_index2) || abs(tal_cell{i,ii}(j).duration < eps)))
                    rec_idx = 1;
                    rec_idx2 = 1;
                end
                if ~isempty(rec_idx) && ~isempty(rec_idx2) && ...
                        rec_idx <= n_rec && ...
                        rec_idx2 <= n_rec,
                    % time falls within the data range
                    sample_idx = round(((tal_cell{i,ii}(j).onset - ...
                        rec_onset_datarange(rec_idx))/hdr.dur)*spr)+spr*(rec_idx-1)+1;
                    sample_idx2 = round(((tal_cell{i,ii}(j).onset + ...
                        tal_cell{i,ii}(j).duration - ...
                        rec_onset_datarange(rec_idx2))/hdr.dur)*spr)+spr*(rec_idx2-1)+1;
                    tal_cell{i,ii}(j).onset_samples = ...
                        min(max(1,sample_idx), ...
                        (spr*n_rec-beg_offset-end_offset));  %#ok<*AGROW>
                    if rec_idx2 > rec_idx,
                        tal_cell{i,ii}(j).duration_samples = ...
                            sample_idx2 + (spr-sample_idx + 1) + (rec_idx2 - rec_idx - 1)*spr;
                    else
                        tal_cell{i,ii}(j).duration_samples = sample_idx2 - sample_idx + 1;
                    end
                end
            end
            if verbose && ~mod(i, n_cell_by100),
                fprintf('.');
            end
        end
    end
    if verbose,
        fprintf('\n(io:edfplus:read) Done computing sample indices\n');
    end
    
end

if nargout > 3 && isempty(tal_cell),
    % Time of each sample
    spr = max(hdr.spr(chan_idx));
    time = repmat(rec_onset',1,spr) + repmat(0 : hdr.dur/spr : hdr.dur - hdr.dur/spr, hdr.nrec,1);
    time = time';
    time = time(:);
elseif nargout > 3,
    tmp = nan(size(tal_cell,2),1);
    for i = 1:size(tal_cell,2),
        tmp(i) = tal_cell{chan_itr, i}(1).onset;
    end
    time = repmat(tmp, 1, spr)+repmat(linspace(0,hdr.dur,spr),size(tal_cell,2), 1);
    time = time';
    time = time(:);
    
end

if verbose,
    t = cputime-start_cputime;
    ndigits = ceil(log10(t));
    fprintf(['\n(io:edfplus:read) It took %' num2str(ndigits) '.0f seconds to read the file'], t);
    fprintf('\n');
end

if bzipped,
    delete(filename);
end


end