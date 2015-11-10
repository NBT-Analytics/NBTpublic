function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import misc.get_username;


MEh     = [];

initialize(9);

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
    myNode = ev_gen.new; %#ok<NASGU>
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% multiple plotters
try
    
    name = 'multiple plotters';
    
    evGen = physioset.event.periodic_generator('Period', 1);
    myNode = ev_gen.new('EventGenerator', evGen, 'Plotter', ...
        {physioset.plotter.snapshots.snapshots('WinLength', 4), ...
        physioset.plotter.snapshots.snapshots('WinLength', 2)});
    
    X = 3+randn(2, 1000);
    data = import(physioset.import.matrix, X);
    run(myNode, data);
    
    ok(numel(get_event(data)) == 4, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';
    
    evGen = physioset.event.periodic_generator('Period', 1);
    myNode = ev_gen.new('EventGenerator', evGen);
    
    X = 3+randn(10, 1000);
    data = import(physioset.import.matrix, X);
    run(myNode, data);
    
    ok(numel(get_event(data)) == 4, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% events with meta properties
try
    
    name = 'events with meta properties';
    
    myTemplate = @(sampl, idx, data) set_meta(physioset.event.event(sampl, ...
        'Type', 'mytype'), 'metaprop', rand);
    evGen = physioset.event.periodic_generator('Period', 10, ...
        'Template', myTemplate);
    myNode = ev_gen.new('EventGenerator', evGen);
    
    X = 3+randn(10, 1000);
    data = import(physioset.import.matrix('SamplingRate', 1), X);
    run(myNode, data);
    
    logFile = catfile(get_full_dir(myNode, data), ...
        [get_name(data) '_events.txt']);
    
    condition = exist(logFile, 'file');
    
    if condition,
       
        [tableVals, hdr, rownames] = misc.dlmread(logFile, ',', 0, 1);
        condition =  ...
            numel(hdr) ==  9 & ...
            numel(rownames) == 100 & ...
            all(ismember(rownames, 'mytype')) & ...
            all(tableVals(:,end) > -eps & tableVals(:,end) < 1+eps) & ...
            all(tableVals(:,1)' == 1:10:1000);        
    end
    
    ok(condition & numel(get_event(data)) == 100, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% save node output
try
    
    name = 'save node output';
    
    evGen = physioset.event.periodic_generator('Period', 1);
    myNode = ev_gen.new('EventGenerator', evGen, 'Save', true);
    
    X = 3+randn(10, 1000);
    data = import(physioset.import.matrix, X);
    outputFileName = get_output_filename(myNode, data);
    run(myNode, data);
    
    ok(exist(outputFileName, 'file')>0 & ...
        numel(get_event(data)) == 4, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process multiple files
try
    
    name = 'process multiple datasets';
    
    data = cell(1, 3);
    for i = 1:3,
        data{i} = import(physioset.import.matrix, 2+randn(10, 1000));
    end
    evGen = physioset.event.periodic_generator('Period', 1);
    myNode = ev_gen.new('EventGenerator', evGen, 'OGE', false);
    run(myNode, data{:});
    
    ok(numel(get_event(data{3})) == 4 & ...
        numel(get_event(data{1})) == 4, name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% oge
try
    
    name = 'oge';
    
    if has_oge,
        
        data = cell(1, 3);
        for i = 1:3,
            data{i} = import(physioset.import.matrix, 2+randn(10, 1000));
        end        
       
        myNode = ev_gen.new('OGE', true, 'Queue', 'short.q', ...
            'Save', true);
        dataFiles = run(myNode, data{:});
        
        pause(5); % give time for OGE to do its magic
        MAX_TRIES = 45;
        tries = 0;
        while tries < MAX_TRIES && ~exist(dataFiles{3}, 'file'),
            pause(1);
            tries = tries + 1;
        end
        
        [~, ~] = system(sprintf('qdel -u %s', get_username));
        
        ok(exist(dataFiles{3}, 'file') > 0, name);
        
    else
        ok(NaN, name, 'OGE is not available');
    end
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Cleanup
try
    
    name = 'cleanup';
    % just in case
    [~, ~] = system(sprintf('qdel -u %s', get_username));
    clear data dataCopy ans myCfg myNode;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();