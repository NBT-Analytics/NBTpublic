function [status, MEh] = test_merge()
% test_merge - Test method merge

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

MEh     = [];

initialize(4);

%% Create a new session
try
    
    name = 'create new session';
    warning('off', 'session:NewSession');
    session.instance;
    warning('on', 'session:NewSession');
    hashStr = DataHash(randn(1,100));
    session.subsession(hashStr(1:5));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Merge multiple physiosets
try
    
    name = 'merge multiple physiosets';
   
    [~, data] = sample_data(3);
    
    mergedData = merge(data{:});
    
    ok(size(mergedData, 2) == 3000 && ...
        numel(get_event(mergedData)) == 33, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Merge a single physioset
try
    
    name = 'merge a single physioset';
   
    [~, data] = sample_data(1);
    
    mergedData = merge(data{:});
    
    ok(...
        size(mergedData, 2) == size(data{1},2) & ...
        max(max(abs(data{1}(:,:)-mergedData(:,:)))) < 0.1 & ...
        numel(get_event(data{1})) == numel(get_event(mergedData))-1, ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    clear data ans;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Testing summary
status = finalize();

end


function [file, data] = sample_data(nbFiles)

if nargin < 1 || isempty(nbFiles),
    nbFiles = 2;
end

file = cell(1, nbFiles);
data = cell(1, nbFiles);

for i = 1:nbFiles
 
   data{i} =  import(physioset.import.matrix, rand(5, 1000));
   evArray = physioset.event.event(1:100:1000, 'Type', num2str(i));
   add_event(data{i}, evArray);
   file{i} = get_datafile(data{i});
   
   save(data{i});
   
end


end