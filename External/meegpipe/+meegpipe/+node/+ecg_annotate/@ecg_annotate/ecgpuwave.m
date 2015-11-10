function [info, hrvInfo, evArray] = ecgpuwave(obj, data)
% ecgpuwave - QRS detection and ECG delineation as in [1]
%
% ````matlab
% info = ecgpuwave(obj, data)
% ````
%
% Where
%
%
%   `info` is a struct with the following fields:
%
%   time    : (cell) An Mx1 cell array of strings with the sampling times
%             of M annotations
%
%   sample  : (int32) An Mx1 cell array with the sample position of each
%             annotation
%
%   ann     : (cell) An Mx1 cell array of strings with annotation codes.
%             See [2] for information regarding these codes.
%
%   subtyp  : (int32) An Mx1 numeric array with sub-type information.
%
%   num     : (int32) An Mx1 numeric array with the num property associated
%              to each annotation
%
%
% References:
%
% [1] Laguna P, Jané R, Caminal P. Automatic Detection of Wave Boundaries
%     in Multilead ECG Signals: Validation with the CSE Database. Computers
%     and Biomedical Research 27(1):45-60, 1994.
%
% [2] http://www.physionet.org/physiobank/annotations.shtml
%
% [3] http://www.physionet.org/physiotools/
%
% [4] http://www.physionet.org/physiotools/wfdb-windows-quick-start.shtml
%
%
% See also: ecg_annotate


import mperl.file.spec.*;
import io.conversion.edf2mit;
import io.edf.write;
import goo.globals;
import datahash.DataHash;
import pset.session;
import fmrib.my_fmrib_qrsdetect;
import meegpipe.node.ecg_annotate.ecg_annotate;
import wfdb.mat2wfdb;

verbose = is_verbose(obj);

sr = data.SamplingRate;

% Guess the physical dimensions
transpose(data);
medVal = median(median(data));
transpose(data);
if medVal > 100,
    physdim = 'uV';
elseif medVal > 0.5,
    physdim = 'mV';
else
    physdim = 'V';
end

verboseLabel = globals.get.VerboseLabel;
if isempty(verboseLabel),
    verboseLabel = '(ecgpuwave) ';
end

% Create a temporary directory under the home dir. This is VERY
% important because it seems that the HRV toolkit creates temporary
% files with fixed names. Thus we need to isolate completely each run
% of get_hrv
recName = DataHash(tempname);
recName = recName(1:14);

session.subsession(recName);
wfdbFileName     = catfile(session.instance.Folder, recName);

% Write input data to WFDB format
if verbose,
    fprintf([verboseLabel 'Writing ECG data to WFDB format...   ']);
end
mat2wfdb(data(:,:)', wfdbFileName, sr, false, 16, {physdim});
if verbose, fprintf('[done]\n\n'); end

peaks = [];
rpeakSelector = get_config(obj, 'RPeakEventSelector');
if ~isempty(rpeakSelector),
    qrsEv = select(rpeakSelector, get_event(data));
    if ~isempty(qrsEv), peaks = get_sample(qrsEv); end
end

if isempty(peaks),
    error('ecg_annotate:MissingQRSEvents', ...
        ['Could not find QRS events. Did you forget ' ...
        'to add a qrs_detect node to the pipeline?']);
end

%% ecgpuwave
if verbose,
    fprintf([verboseLabel 'Running ecgpuwave ...\n\n']);
end
ecgpuwave.limits(...
    session.instance.Folder, ...
    session.instance.Folder, ...
    recName, ...
    peaks, ...
    0, ...
    1);

%% Compute the HRV features for each experimental condition
if verbose,
    fprintf([verboseLabel 'Computing HRV features using the HRV toolkit...']);
end
sel = get_config(obj, 'EventSelector');

% Write annotations in WFDB format
currDir = pwd;
cd(session.instance.Folder);
cmd = sprintf('wrann -r %s -a ecgpuwave <%s', ...
    recName, [recName '.ecgpuwave.txt']);
[~, ~] = system(cmd);
cd(currDir);

if isempty(sel),
    hrvFile = catfile(session.instance.Folder, [recName '.hrv']);
    
    % Extract HRV features
    cmd = sprintf('get_hrv -M %s ecgpuwave > %s.hrv', ...
        recName, recName);
    
    if misc.iscygwin,
        cygbin = val(meegpipe.get_config, 'cygwin', 'bindir');
        cygrun = catfile(cygbin, 'bash');
        cmd = sprintf('%s %s', cygrun, cmd);
    end
    
    currDir = pwd;
    cd(session.instance.Folder);
    [~, ~] = system(cmd);
    cd(currDir);
    
    hrvInfo = io.wfdb.hrv.read(hrvFile);
    evArray = {};
else
    evArray = cell(1, numel(sel));
    hrvInfo = cell(1, numel(sel));
    ev = get_event(data);
    for i = 1:numel(sel)
        
        hrvFile = catfile(session.instance.Folder, [recName '_' num2str(i) '.hrv']);
        
        thisEv = select(sel{i}, ev);
        
        if isempty(thisEv), continue; end
        
        % Create recName_i with the RR intervals
        for j = 1:numel(thisEv)
            
            first = get_sample(thisEv(j)) + get_offset(thisEv(j));
            last = get_sample(thisEv(j)) + get_duration(thisEv(j)) - 1;
            
            if (last - first) < data.SamplingRate*2,
                error('Events have too short duration');
            end
            
            % Create RR time series
            cmd = sprintf(...
                ['ann2rr -r %s -a ecgpuwave -i s -f s%d ' ...
                '-t s%d >> %s_%d.rr'], recName, first, last, recName, i);
            currDir = pwd;
            cd(session.instance.Folder);
            [~, ~] = system(cmd);
            cd(currDir);
            
        end
        
        % Get HRV statistics for this group/condition
        cmd = sprintf('get_hrv -M -R %s_%d.rr >%s_%d.hrv', ...
            recName, i, recName, i);
        
        if misc.iscygwin,
            cygbin = val(meegpipe.get_config, 'cygwin', 'bindir');
            cygrun = catfile(cygbin, 'bash');
            cmd = sprintf('%s %s', cygrun, cmd);
        end
        
        currDir = pwd;
        cd(session.instance.Folder);
        [~, ~] = system(cmd);
        cd(currDir);
        
        evArray{i} = thisEv; 
        hrvInfo{i} = io.wfdb.hrv.read(hrvFile);
        
    end
    
end

if verbose, fprintf('[done]\n\n'); end


% Extract annotations info
annFileName = catfile(session.instance.Folder, [recName, '.ecgpuwave.txt']);
info = io.wfdb.annotations.read(annFileName);

try
    rmdir(session.instance.Folder, 's');
catch ME
    % do nothing, just ignore
end
session.clear_subsession();

end