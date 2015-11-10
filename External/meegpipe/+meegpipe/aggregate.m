function [fName, aggrFiles] = aggregate(fileList, regex, fName, ...
    fNameTrans, rowNames, includeFileName, verbose)
% aggregate - Aggregate features from file-level processing jobs
%
% See: misc.md_help('meegpipe.aggregate')

import mperl.file.find.finddepth_regex_match;
import mperl.file.spec.catdir;
import safefid.safefid;
import datahash.DataHash;
import misc.dlmread;
import mperl.join;

if nargin < 2 || isempty(regex),
    regex = '.+';
end

if nargin < 3 || isempty(fName),
    fName = '';
end

if nargin < 4 || isempty(fNameTrans),
    fNameTrans = '';
end

if nargin < 5 || isempty(rowNames),
    rowNames = true;
end

if nargin < 6 || isempty(includeFileName),
    includeFileName = true;
end

if nargin < 7 || isempty(verbose),
    verbose = true;
end

if isa(fileList{1}, 'physioset.physioset'),
    fileList = get_datafile(fileList{:});
end

%% Find all the files that are to be aggregated
aggrFiles = cell(numel(fileList)*5, 1);
origFiles = cell(numel(fileList)*5, 1);
count = 0;

for i = 1:numel(fileList)
   
    [path, name]  = fileparts(fileList{i});
    root = catdir(path, [name '.meegpipe']);
    thisFiles = finddepth_regex_match(root, regex, false, true, false);
    
    if isempty(thisFiles),
        continue;
    end
    
    aggrFiles(count+1:count+numel(thisFiles)) = thisFiles;
    origFiles(count+1:count+numel(thisFiles)) = ...
        repmat(fileList(i), numel(thisFiles), 1);
    count = count+numel(thisFiles);    
    
end

if count < 1,
    error('No files match the provided regex');
end

aggrFiles(count+1:end) = [];
aggrFiles = sort(aggrFiles);

%% Print the list of aggregated files in the header
if isempty(fName),
    fName = ['aggregate_' DataHash(aggrFiles) '.txt'];
end

fid = safefid(fName, 'w');

for i = 1:count
    fprintf(fid, '# %s\n', aggrFiles{i});
end

%% Do the aggregation
printedHeader = false;
for i = 1:count,
   thisFile = aggrFiles{i};
   if verbose,
       fprintf('(aggregate) Aggregating %s ...', thisFile);
   end
   [data, header, thisRowNames] = ...
       dlmread(thisFile, ',', 0, double(rowNames));
   
   % Parse file name
   if includeFileName,
       metaNames = {'filename'};
   else
       metaNames = {};
   end 
   
   if ~isempty(fNameTrans),
       
       if ischar(fNameTrans),
           % A regex
           meta = regexp(aggrFiles{i}, fNameTrans, 'names');
       elseif isa(fNameTrans, 'function_handle'),
           meta = fNameTrans(aggrFiles{i});
       else
           error('fNameTrans must be a regex or a function_handle'); 
       end
       if ~isempty(meta),
           tmp = fieldnames(meta);
           metaNames = [metaNames;tmp(:)]; %#ok<AGROW>
       end           
       
   end
   
   if includeFileName,
        [~, name, ext] = fileparts(origFiles{i});
        meta.filename = [name ext];
   end
   
   % Print header
   if ~printedHeader,
        hdr = [metaNames;header(:)];
        hdr = join(',', hdr);
        
        fprintf(fid, '%s\n', hdr);
        printedHeader = true;
   end
   
   % Print features
   
   for k = 1:size(data,1)
       
       metaVals = cell(1, numel(metaNames));
      
       for j = 1:numel(metaNames)
           metaVals{j} =meta.(metaNames{j});
       end
       
       fprintf(fid, '%s,', join(',', metaVals));
       
       if ~isempty(thisRowNames),
           fprintf(fid, '%s,', thisRowNames{k});
       end
       
       fprintf(fid, '%s\n', join(',', data(k,:)));
   end
   
   if verbose, fprintf('[done]\n\n'); end    
end



end