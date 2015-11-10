function [status, MEh] = test_sleep_scores_generator()
% TEST_SLEEP_SCORES_GENERATOR - Tests event generators


import physioset.event.*;
import physioset.event.std.*;
import test.simple.*;
import datahash.DataHash;
import pset.session;
import meegpipe.node.*;

MEh     = [];

initialize(5);

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
    status = finalize();
    return;
    
end

%% default constructors
try
    
    name = 'default constructor';
    sleep_scores_generator;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% sleep_scores_generator
try
    
    name = 'sleep_scores_generator';
    data = get_real_data;
    
    myPipe = pipeline.new('NodeList', ...
        { ...
        physioset_import.new('Importer', physioset.import.physioset), ...
        ev_gen.sleep_scores ...
        }, 'GenerateReport', false);
    
    data = run(myPipe, data);
    
    ev = get_event(data);
    ok(numel(ev) == 761 & isa(ev, 'physioset.event.std.sleep_score'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% sleep_scores_generator (new version)
try
    
    name = 'sleep_scores_generator (old version)';
    data = get_old_version_scores;
    
    myPipe = pipeline.new('NodeList', ...
        { ...
        physioset_import.new('Importer', physioset.import.physioset), ...
        ev_gen.sleep_scores ...
        }, 'GenerateReport', false);
    
    data = run(myPipe, data);
    
    ev = get_event(data);
    ok(numel(ev) == 949 & isa(ev, 'physioset.event.std.sleep_score'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Cleanup
try
    
    name = 'cleanup'; 
    clear data dataCopy ans myCfg myNode;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end


%% Testing summary
status = finalize();

end

function dataCopy = get_real_data(subj)

import pset.session;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;

if nargin < 1, 
    subj = '0160';
end

fName = ['ssmd_' subj '_eeg_scores_sleep_1_1'];

if exist([fName '.pseth'], 'file') > 0,
    data = [fName '.pseth'];
else
    % Try downloading the file
    url = ['http://kasku.org/data/meegpipe/' fName '.zip'];
    unzipDir = catdir(session.instance.Folder, fName);
    unzip(url, unzipDir);
    data = catfile(unzipDir, [fName '.pseth']);
end

dataCopy = copy(pset.load(data));

save(dataCopy);

dataCopy = get_hdrfile(dataCopy);

[pathCopy, nameCopy] = fileparts(dataCopy);
[path, name] = fileparts(data);

copyfile(catfile(path, [name '.mat']), ...
    catfile(pathCopy, [nameCopy '.mat']));

end

function data = get_old_version_scores()
import mperl.file.spec.catfile;
import pset.session;

fName = 'ssmd_0108_eeg_scores_sleep_2_1.mat';

if ~exist(fName, 'file') > 0,   
    % Try downloading the file
    url = [meegpipe.get_config('test', 'remote') fName];
    fName = catfile(session.instance.Folder, fName);
    urlwrite(url, fName);
end

% Create a dummy physioset of the right duration
data = import(physioset.import.matrix, rand(2, 950*30*1000));
save(data);

[newPath, newName] = fileparts(get_datafile(data));

copyfile(fName, catfile(newPath, [newName '.mat']));

data = get_hdrfile(data);


end
