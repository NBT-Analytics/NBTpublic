function [status, MEh] = complex_pipelines()
% TEST_COMPLEX_PIPELINES - Tests some more complex pipelines

import mperl.file.spec.*;
import meegpipe.node.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import misc.get_username;
import misc.get_hostname;

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

%% process very large file with simple pipeline
try
    
    name = 'process very large file with simple pipeline';

    data = pset.pset.randn(256, 1000*60*60*1);
    data = physioset.physioset(data);
    myPipe = pipeline.new('NodeList', {...
        copy.new, ...
        copy.new ...       
        }, ...
        'Save', true, 'GenerateReport', false, 'Name', 'sample');
    
    run(myPipe, data);
    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% oge ( a one-off test, I leave it here just in case I need it again)
% try
%     
%     name = 'oge';
%     
%     if has_oge,
%         
%         data = cell(1, 2);
%         fName = cell(1, 2);
%         myImporter = physioset.import.matrix('Sensors', sensors.eeg.dummy(2));
%         for i = 1:2,
%             data{i} = import(myImporter, randn(2,1000));
%             data{i} = fieldtrip(data{i});
%             fName{i} = catfile(session.instance.Folder, ['f' num2str(i) '.mat']);
%             ftripData = data{i}; %#ok<NASGU>
%             save(fName{i}, 'ftripData');
%         end
%         
%         myNode1 = physioset_import.new('Importer', physioset.import.fieldtrip);
%         myNode2 = center.new;      
%         myFilter=filter.polyfit('Order', 10, 'Verbose', true);
%         myNode3 =filter.new('Filter', myFilter);        
%         myFilter =  @(sr) filter.hpfilt('fc', 0.5/(sr/2));
%         myNode4 = filter.new('Filter', myFilter);
%         myPipe = pipeline.new('NodeList', {myNode1, myNode2, myNode3, myNode4}, ...
%             'Name', 'test-pipeline-complex_pipelines', ...
%             'TempDir', @() tempdir, 'Save', true, 'OGE', true, ...
%             'Queue', 'short.q@nin174.herseninstituut.knaw.nl');
%         fName{1} = 'svui_0002_eeg_wm-second-ns_04_seldata.mat';
%         dataFiles = run(myPipe, fName{:});
%         
%         pause(5); % give time for OGE to do its magic
%         MAX_TRIES = 100;
%         tries = 0;
%         while tries < MAX_TRIES && ~exist(dataFiles{1}, 'file'),
%             pause(10);
%             tries = tries + 1;
%         end
%         
%         [~, ~] = system(sprintf('qdel -u %s', get_username));
%         
%         ok(exist(dataFiles{1}, 'file') > 0, name);
%         
%     else
%         ok(NaN, name, 'OGE is not available');
%     end
%     
%     
% catch ME
%     
%     ok(ME, name);
%     MEh = [MEh ME];
%     
% end

%% copy+eog+chan_interp
try
    
    name = 'copy+eog+chan_interp';
    data = get_real_data;
    
    set_bad_channel(data, [10 18 21 192]);
    set_bad_sample(data, randi(size(data,2), 1, 1125));
    data = subset(data, 1:192);
    
    save(data);
    dataFile = get_hdrfile(data);
    myPipe = pipeline.new('NodeList', {...
        physioset_import.new('Importer', physioset.import.physioset), ...
        copy.new, ...
        bss.eog('Filter', []), ...
        chan_interp.new ...
        }, ...
        'Save', true, 'GenerateReport', true, 'Name', 'sample');
    
    run(myPipe, dataFile);
    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% copy+resample+filter+reref+bad_channels+bad_epochs
try
    
    name = 'copy+resample+filter+reref+bad_channels+bad_epochs';
    
    centralchannels= pset.selector.sensor_idx(sort([257, 81, 132, 186,9,45, 8, 198, 185, 144, 131, 90, 80, 53, 44, 17]));
    badChanDataSel = not(centralchannels);
    
    badChanCrit1 = bad_channels.criterion.var.new(...
        'Min', @(chanVar) prctile(chanVar, 1), ...
        'Max', @(chanVar) prctile(chanVar, 95), ...
        'MaxCard',  @(dim)ceil(0.2*dim), ...
        'NN',  20 ... % Number of nearest neighbors
        );
    badChanCrit2 = bad_channels.criterion.xcorr.new(...
        'MinCard',  0,  ...
        'MaxCard',  @(dim)ceil(0.05*dim), ...
        'Min',      @(corrVals) prctile(corrVals,5) ...
        );
    
    fh = @(sampl, idx, data) physioset.event.event(sampl, ...
        'Type', '_DummyEpochOnset', 'Duration', 2*data.SamplingRate);
    
    myEvGen = physioset.event.periodic_generator(...
        'Period',   2, ... % in seconds
        'Template', fh  ...
        );
    
    badEpochsCrit = bad_epochs.criterion.stat.new(...
        'ChannelStat', @(epochdata) max(abs(epochdata)), ...
        'EpochStat', @(chanstat) prctile(chanstat,95), ...
        'Min', @(epochStatVal) median(epochStatVal)-3*iqr(epochStatVal), ...
        'Max', @(epochStatVal) median(epochStatVal)+2*iqr(epochStatVal) ...
        );
    
    myEvSel = physioset.event.class_selector('Type', '_DummyEpochOnset');
    
    badEpochsNode  = bad_epochs.new(...
        'Criterion',        badEpochsCrit, ...
        'EventSelector',    myEvSel);
    myPipe = pipeline.new(...
        physioset_import.new('Importer', physioset.import.physioset), ...
        bad_channels.new('Criterion', badChanCrit1, 'DataSelector', badChanDataSel), ...
        bad_channels.new('Criterion', badChanCrit2, 'DataSelector', badChanDataSel), ...
        ev_gen.new('EventGenerator', myEvGen), ...
        badEpochsNode, ...
        filter.new('Filter', @(sr) filter.bpfilt('fp', [0.25 40]/(sr/2))), ...
        copy.new, ...       
        resample.new('OutputRate', 125), ...
        'Save', true, 'GenerateReport', true);
    
    myImporter = physioset.import.matrix(...
        'Sensors', sensors.eeg.from_template('egi256'));
    myData = import(myImporter, rand(257, 20000));
    save(myData);
    myData = get_hdrfile(myData);
    
    run(myPipe, myData);
    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    % just in case
    [~, ~] = system(sprintf('qdel -u %s', get_username));
    
    pause(5); % Some time for the jobs to be killed
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


function data = get_real_data()

import pset.session;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;

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
data = copy(data);

end