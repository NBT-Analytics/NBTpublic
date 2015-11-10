function [status, MEh] = test_reref()
% test_reref - Test method reref

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import meegpipe.node.*;

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

%% Re-reference to average reference
try
    
    name = 're-reference to average reference';
   
    data = sample_data(1);
    data = data{1};
    
    X = data(:,:) - repmat(mean(data(:,:)), size(data,1), 1);
    
    W = get_config(reref.avg, 'RerefMatrix');
    
    reref(data, W);
    
    ok(max(max(abs(data(:,:) - X(:,:)))) < 0.001, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Undo average rerefence
try
    
    name = 'undo average rerefence';
   
    data = sample_data(1);
    data = data{1};
    
    % We simulate that the last channel is a ref
    data(end,:) = 0;
    
    X = data(:,:);
    
    W = get_config(reref.avg, 'RerefMatrix');
    
    reref(data, W);
    
    undo_reref(data, size(data,1));
    
    ok(max(max(abs(data(:,:) - X(:,:)))) < 0.001, name);
    
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


function data = sample_data(nbFiles)

if nargin < 1 || isempty(nbFiles),
    nbFiles = 2;
end

data = cell(1, nbFiles);

mySensors = subset(sensors.eeg.from_template('egi256'), 1:5);
myImporter = physioset.import.matrix('Sensors', mySensors);

for i = 1:nbFiles
 
   data{i} =  import(myImporter, rand(5, 1000));
   evArray = physioset.event.event(1:100:1000, 'Type', num2str(i));
   add_event(data{i}, evArray);
   
end


end