function [status, MEh] = test_train()
% TEST_TRAIN - Tests training a node with manually labeled data

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import spt.bss.jade;
import mperl.config.inifiles.inifile;
import meegpipe.node.*;

MEh     = [];

initialize(3);

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

%% A simple training dataset
try
    
    name = 'simple training dataset';
    if exist('20131121T171325_647f7.pseth', 'file') > 0,
        data = pset.load('20131121T171325_647f7.pseth');
    else
        % Try downloading the file
        url = 'http://kasku.org/data/meegpipe/20131121T171325_647f7.zip';
        unzipDir = catdir(session.instance.Folder, '20131121T171325_647f7');
        unzip(url, unzipDir);
        fileName = catfile(unzipDir, '20131121T171325_647f7.pseth');
        data = pset.load(fileName);
    end
    data1 = copy(data);
    X = data1(:,:) + 25*randn(size(data1));
    data1(:,:) = X;
    save(data1);
   
    data2 = copy(data);
    data2 = data2 + 25*randn(size(data2));
    save(data2);
    
    nodeList = {};
    myNode = meegpipe.node.physioset_import.new(...
        'Importer', physioset.import.physioset);
    nodeList = [nodeList {myNode}];
    
    myNode = meegpipe.node.bss.ecg(...
        'GenerateReport', false);
    nodeList = [nodeList {myNode}];
    
    myPipe = meegpipe.node.pipeline.new(...
        'NodeList',         nodeList, ...
        'GenerateReport',   false);
    
    file1 = get_hdrfile(data1);
    file2 = get_hdrfile(data2);
    clear data1 data2;
    run(myPipe, file1, file2);
    
    % Generate two new datasets
    data3 = copy(data);
    data3 = data3 + 25*randn(size(data3));
    save(data3);
    data4 = copy(data);
    data4 = data4 + 25*randn(size(data4));
    save(data4);
    
    % Let's train the pipeline using the sample datasets above
    nodeList = {};
    myNode = meegpipe.node.physioset_import.new(...
        'Importer', physioset.import.physioset);
    nodeList = [nodeList {myNode}];
    
     myNode = meegpipe.node.bss.ecg(...
        'GenerateReport', false);
    nodeList = [nodeList {myNode}];
    
    myPipe = meegpipe.node.pipeline.new(...
        'NodeList', nodeList, ...
        'GenerateReport', false);
    myPipe = train(myPipe, {file1, file2});    
   
    files = {...      
        get_hdrfile(data3), ...
        get_hdrfile(data4)};
    clear data2 data3;
    run(myPipe, files{:});
    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
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