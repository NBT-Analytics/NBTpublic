function [status, MEh] = test_basic()
% TEST_BASIC - Tests basic node functionality

import mperl.file.spec.*;
import mperl.file.find.finddepth_regex_match;
import meegpipe.node.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import physioset.event.value_selector;

MEh     = [];

initialize(8);

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
    parallel_node_array.new;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'constructor with config options';
    
    myNodeList = {...
        center.new, ...
        copy.new ...
        };
    
    myNode = parallel_node_array.new(...
        'NodeList',     myNodeList, ...
        'Aggregator',   @(varargin) prod(cell2mat(varargin)));
    
    myNodeList = get_config(myNode, 'NodeList');
    myAggr     = get_config(myNode', 'Aggregator');
    ok(...
        numel(myNodeList) == 2 & ...
        isa(myNodeList{1}, 'meegpipe.node.center.center') & ...
        isa(myAggr, 'function_handle') & ...
        myAggr(5,4) == 20, ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% extract three subsets
try
    
    name = 'extract three subsets';
    
    data = import(physioset.import.matrix, rand(2,1000));
    myEv1 = physioset.event.event(1, 'Duration', 100, 'Type', 'first');
    myEv2 = physioset.event.event(101, 'Duration', 100, 'Type', 'second');
    myEv3 = physioset.event.event(201, 'Duration', 100, 'Type', 'third');
    add_event(data, [myEv1, myEv2, myEv3]);
    save(data);
    
    importerNode = physioset_import.new('Importer', physioset.import.physioset);
    
    evTypes = {'first', 'second', 'third'};
    parallelNodes = cell(1, numel(evTypes));
    for i = 1:numel(evTypes)
        myEvSel = physioset.event.class_selector('Type', evTypes{i});
        mySel = pset.selector.event_selector(myEvSel);
        parallelNodes{i} = subset.new(...
            'DataSelector', mySel, ...
            'Save',         true, ...
            'Name',         evTypes{i});
    end

    myNode = parallel_node_array.new(...
        'NodeList',         parallelNodes, ...
        'Aggregator',       []);
    
    myPipe = pipeline.new(...
        'NodeList',         {importerNode, myNode}, ...
        'GenerateReport',   false, ...
        'Save',             false);
    
    dataOut = run(myPipe, get_hdrfile(data));
    data = [];
    for i = 1:numel(evTypes)
        file = finddepth_regex_match(session.instance.Folder, ...
            [evTypes{i} '.pseth']);
        thisData = pset.load(file{1});
        data = [data thisData(:,:)]; %#ok<AGROW>
    end
    
    ok(max(max(abs(dataOut(:,1:size(data,2)) - data(:,:)))) < 1e-3, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% pipeline + GenerateReport = false
try
    
    name = 'pipeline + GenerateReport = false';
    
    
    importerNode = physioset_import.new('Importer', physioset.import.matrix);
    
    myNode1 = operator.new('Operator', @(x) x.^2);
    myNode2 = operator.new('Operator', @(x) x.^3);
    
    myNode = parallel_node_array.new(...
        'NodeList',         {myNode1, myNode2}, ...
        'Aggregator',       @(args) args{1}-args{2});
    
    myPipe = pipeline.new('NodeList', ...
        {importerNode, myNode}, 'GenerateReport', false);
    
    data = rand(5,1000);
    dataOut = run(myPipe, data);
    
    ok(max(abs(data(:).^2-data(:).^3-dataOut(:))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% two operator nodes and sum aggregator
try
    
    name = 'two operator nodes and minus aggregator';
    
    
    data = import(physioset.import.matrix, rand(5,1000));
    
    myNode1 = operator.new('Operator', @(x) x.^2);
    myNode2 = operator.new('Operator', @(x) x.^3);
    
    myNode = parallel_node_array.new(...
        'NodeList',  {myNode1, myNode2}, ...
        'Aggregator', @(args) args{1}-args{2});
    
    dataOut = run(myNode, data);
    
    ok(max(abs(data(:).^2-data(:).^3-dataOut(:))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% three copy nodes and sum aggregator
try
    
    name = 'two copy nodes and sum aggregator';
    
    
    data = import(physioset.import.matrix, rand(5,1000));
    
    myNode = parallel_node_array.new(...
        'NodeList', {copy.new, copy.new, copy.new}, ...
        'Aggregator', @(args) args{1}+args{2}+args{3});
    
    dataOut = run(myNode, data);
    
    ok(max(abs(3*data(:)-dataOut(:))) < 0.01, name);
    
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

