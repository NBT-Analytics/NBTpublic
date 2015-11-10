function [status, MEh] = test_bcg_bss_regr()
% TEST_BCG_BSS_REGR - Tests BCG correction using BSS and regression

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
    
    myNode = aar.bcg.bss_regr('Name', 'myname');
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
    
    myNode1 = meegpipe.node.qrs_detect.new;
    myNode2 = aar.bcg.bss_regr(...
        'IOReport',         report.plotter.io, ...
        'Save',             true, ...
        'GenerateReport',   true);
    
    myNode = meegpipe.node.pipeline.new('NodeList', {myNode1, myNode2});
    run(myNode, data);    
    
    ok(prctile(abs(dataO(1,5*1000:1000*30)), 95) > ...
        1.5*prctile(abs(data(1,5*1000:1000*30)), 95), name);
    
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

fileName = 'bcg_sample2.pseth';
if ~exist(fileName, 'file') > 0,
    url = 'http://kasku.org/data/meegpipe/bcg_sample2.zip';
    unzip(url, pwd);
end
data = pset.load(fileName);
dataCopy = copy(data);

end