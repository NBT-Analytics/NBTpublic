function files = find_failed_jobs(rootDir, pipelineId)
% FIND_FAILED_JOBS - Identify failed .meegpipe jobs
%
% files = find_failed_jobs(rootDir[, pipelineID])
%
% Where
%
% ROOTDIR is the root directory where the .meegpipe directories can be
% found. If not provided, ROOTDIR will default to the current working
% directory.
%
% PIPELINEID is the ID of the relevant pipeline. If not provide, the
% processing of a file will be considered to have failed if any pipeline
% failed to process the file.
%
% FILES is a cell array with the names of the files that were not
% successfully processed by meegpipe.
%
% See also: meegpipe

import mperl.file.spec.catfile;
import safefid.safefid;

if nargin < 1, 
    rootDir = pwd;
end

DATE_PATTERN = ['\d\d-\w+-\d\d\d\d\s+\d\d:\d\d:\d\d,' ...
    '\d\d-\w+-\d\d\d\d\s+\d\d:\d\d:\d\d'];

if nargin < 2, pipelineId = ''; end

meegpipeDirs = mperl.file.find.finddepth_regex_match(rootDir, '.meegpipe$');
failed = true(numel(meegpipeDirs), 1);
files = cellfun(@(x) regexprep(x, '.meegpipe$', ''), meegpipeDirs, ...
    'UniformOutput', false);
for i = 1:numel(meegpipeDirs)
    subDirs = misc.dir(meegpipeDirs{1});
    if ~isempty(pipelineId),
        isMatch = cellfun(@(x) ~isempty(strfind(x, ['-' pipelineId '_'])), ...
            subDirs);
        subDirs = subDirs(isMatch);
    end
    if isempty(subDirs), continue; end
    
    thisFailed = false;
    for j = 1:numel(subDirs)
        timingFile = catfile(meegpipeDirs{i}, subDirs{j}, 'timing.csv');
        if ~exist(timingFile, 'file'), 
            thisFailed = true;
            break; 
        end
        fid = safefid.fopen(timingFile, 'r');
        line1 = fid.fgetl;
        line2 = fid.fgetl;
        if isempty(line1) || isempty(line2) || ...
                ~strcmp(line1, 'start_time, end_time') || ...
                isempty(regexp(line2, DATE_PATTERN, 'once')),
            thisFailed = true;
            break;
        end
    end
    failed(i) = thisFailed;
end

files = files(failed);

end