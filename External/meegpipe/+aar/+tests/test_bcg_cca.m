function [status, MEh] = test_bcg_cca()
% TEST_BCG_CCA - Tests BCG correction using CCA

import mperl.file.spec.*;
import meegpipe.node.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import physioset.event.value_selector;

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


%% default constructor
try
    
    name = 'constructor';
    aar.bcg.cca;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'constructor with config options';
    
    myNode = aar.bcg.cca('Name', 'myname');
    ok(...
        strcmp(get_name(myNode), 'myname'), ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% real data
try
    
    name = 'real data';    
    
    data = real_data;
    
    dataO = data(1,:);    
    
    myNode = aar.bcg.cca;
    run(myNode, data);    
    
    ok(prctile(abs(dataO), 90) > 1.5*prctile(abs(data(1,:)), 90), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    clear data dataCopy;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();

end


function dataCopy = real_data()

import pset.session;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;

if exist('bcg_sample.pseth', 'file') > 0,
    data = pset.load('bcg_sample.pseth');
else
    % Try downloading the file
    url = 'http://kasku.org/data/meegpipe/bcg_sample.zip';
    unzipDir = catdir(session.instance.Folder, 'bcg_sample');
    unzip(url, unzipDir);
    fileName = catfile(unzipDir, 'bcg_sample.pseth');
    data = pset.load(fileName);
end
dataCopy = copy(data);

end