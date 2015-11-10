function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import test.simple.*;

import mperl.file.spec.*;
import meegpipe.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import oge.has_condor;
import misc.get_username;

MEh     = [];

initialize(13);

%% Create a new session
try
    
    name = 'create new session';
    warning('off', 'session:NewSession');
    session.instance;
    warning('on', 'session:NewSession');   
    session.subsession;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end


%% default constructor
try
    
    name = 'constructor';
    node.filter.new; 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% save node output
try
    
    name = 'save node output';    
   
    data = import(physioset.import.matrix, randn(2,500));
    
    myNode = meegpipe.node.filter.new(...
        'Filter', filter.lasip('Gamma', 1, 'Scales', 1:10), 'Save', true);
    
    outputFileName = get_output_filename(myNode, data);
    run(myNode, data);
    
    ok(exist(outputFileName, 'file')>0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% BP filter
try
    
    name = 'BP filter';

    data = import(physioset.import.matrix, randn(2,500));
    
    myFilter = filter.bpfilt('Fp', [0.1 0.3]);
    myNode = node.filter.new('Filter', myFilter); 
    run(myNode, data);
    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';

    data = import(physioset.import.matrix, randn(2,500));
    
    myFilter = filter.lasip('Gamma', 1, 'Scales', 1:10);
    myNode = node.filter.new('Filter', myFilter); 
    run(myNode, data);
    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% use IO report
try
    
    name = 'use IO report';

    data = import(physioset.import.matrix, randn(2,500));
    
    myFilter = filter.lasip('Gamma', 1, 'Scales', 1:10);
    myNode = node.filter.new('Filter', myFilter, 'IOReport', report.plotter.io); 
    run(myNode, data);
    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% process in data chunks
try
    
    name = 'process in data chunks';

    data = import(physioset.import.matrix, randn(2,1200));
    
    chopEvents = physioset.event.std.chop_begin([1 301 601 901], ...
        'Duration', 300, 'Type', 'tfilter');
    
    add_event(data, chopEvents);
    
    import physioset.event.class_selector;
    myNode = node.filter.new(...
        'ChopSelector', class_selector('Class', 'chop_begin'), ...
        'Filter', filter.lasip('Gamma', 1, 'Scales', 1:10));
    run(myNode, data);
    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process multiple files
try
    
    name = 'process multiple datasets';
    
    data = cell(1, 2);
    for i = 1:2,
        data{i} = import(physioset.import.matrix, randn(2,1000));
    end
    myFilter = filter.lasip(...
        'Filter', filter.lasip('Gamma', 1, 'Scales', 1:10), 'OGE', false);
    myNode = node.filter.new('Filter', myFilter); 
    origData = data{end}(1,:);
    run(myNode, data{:});
    ok(max(abs(data{end}(1,:)-origData)) > 1e-3, name);
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% oge
try
    
    name = 'oge';
    
    if has_oge,
        
        data = cell(1, 2);
        for i = 1:2,
            data{i} = import(physioset.import.matrix, randn(2,1000));
        end
        
         myNode = node.filter.new(...
             'Filter',  filter.lasip('Gamma', 1, 'Scales', 1:10), ...
             'OGE',     true, 'Queue', 'short.q');
        dataFiles = run(myNode, data{:});
        
        pause(5); % give time for OGE to do its magic
        MAX_TRIES = 45;
        tries = 0;
        while tries < MAX_TRIES && ~exist(dataFiles{end}, 'file'),
            pause(1);
            tries = tries + 1;
        end
        
        [~, ~] = system(sprintf('qdel -u %s', get_username));
        
        ok(exist(dataFiles{end}, 'file') > 0, name);
        
    else
        ok(NaN, name, 'OGE is not available');
    end
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% condor
try
    
    name = 'condor';
    
    if has_condor,
        
        data = cell(1, 2);
        for i = 1:2,
            data{i} = import(physioset.import.matrix, randn(2,1000));
        end
        
         myNode = node.filter.new(...
             'Filter',          filter.lasip('Gamma', 1, 'Scales', 1:10), ...
             'Parallelize',     true, 'Queue', 'condor', 'Save', true);
        dataFiles = run(myNode, data{:});
        
        pause(5); % give time for Condor to do its magic
        MAX_TRIES = 45;
        tries = 0;
        while tries < MAX_TRIES && ~exist(dataFiles{2}, 'file'),
            pause(3);
            tries = tries + 1;
        end
        
        [~, ~] = system(sprintf('condor_rm %s', get_username));
        [~, ~] = system(sprintf('source ~/.bashrc;condor_rm %s', get_username));
        
        ok(exist(dataFiles{end}, 'file') > 0, name);
        
    else
        ok(NaN, name, 'Condor is not available');
    end
    
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% detrend
try
    
    name = 'detrend';

    myImporter = physioset.import.matrix('Sensors', sensors.eeg.dummy(2));
    data = import(myImporter, randn(2,500));
    
    myNode = node.filter.detrend; 
    run(myNode, data);
    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end



%% emg
try
    
    name = 'pipeline + real data';
    
    fileName = kul_data;
 
    nodeList = {};
    
    myNode = meegpipe.node.physioset_import.new(...
        'Importer', physioset.import.eeglab);
    
    nodeList = [nodeList, {myNode}];
    
    myNode = meegpipe.node.filter.emg;
    
    nodeList = [nodeList, {myNode}];
    
    myPipe = meegpipe.node.pipeline.new(...
        'NodeList', nodeList);
    
    warning('off', 'sensors:MissingPhysDim');
    warning('off', 'sensors:InvalidLabel');
    run(myPipe, fileName);
    warning('on', 'sensors:MissingPhysDim');
    warning('on', 'sensors:InvalidLabel');

    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
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

end


function fileName = kul_data()

import pset.session;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;

fileName = catfile(session.instance.Folder, 'f1_750to810.set');

if exist('f1_750to810.set', 'file') > 0,
    copyfile('f1_750to810.set', fileName);
else
    % Try downloading the file
    url = 'http://kasku.org/projects/eeg/data/kul/f1_750to810.set';
    urlwrite(url, fileName);  
end

end