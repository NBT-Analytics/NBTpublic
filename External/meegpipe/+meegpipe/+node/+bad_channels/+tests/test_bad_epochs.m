function [status, MEh] = test_bad_epochs()
% test_bad_epochs - Tests bad_epochs criterion

import mperl.file.spec.*;
import meegpipe.node.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;

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
    status = finalize();
    return;
    
end


%% default constructor
try
    
    name = 'constructor';
    bad_channels.criterion.bad_epochs.new;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% example from docs
try
    
    name = 'example from docs';
    
    myBadEpochsCrit = bad_epochs.criterion.stat.new(...
        'ChannelStat', @(x) max(abs(x)), ...
        'EpochStat',   @(x) max(x), ...
        'Max', 100);
    
    myEvSel = physioset.event.class_selector('Type', 'stm');

    myBadChansCrit = bad_channels.criterion.bad_epochs.new(...
        'BadEpochsCriterion', myBadEpochsCrit, ...
        'Max',                0.5, ...
        'EventSelector',      myEvSel);
    
    myNode = bad_channels.new('Criterion', myBadChansCrit);
    
    [data, idxBad] = sample_data;
    
    run(myNode, data);
    
    badSel = find(is_bad_channel(data));
    
    ok(numel(badSel) == numel(idxBad) && all(badSel == idxBad), name);
    
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
    MEh = [MEh ME];
end

%% Testing summary
status = finalize();

end


function [data, idxBad] = sample_data()

import physioset.event.event;

idxBad = 1;
idxAlmostBad = 5;

X = randn(34, 15000);
X(20,:) = 0;

warning('off', 'sensors:InvalidLabel');
eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
warning('on', 'sensors:InvalidLabel');

eegSensors   = subset(eegSensors, 1:8:256);
dummySensors = sensors.dummy(2);
allSensors   = sensors.mixed(eegSensors, dummySensors);

importer = physioset.import.matrix(100, 'Sensors', allSensors);
data = import(importer, X);

evArray = event(100:500:14000, 'Duration', 200, 'Type', 'stm+');
add_event(data, evArray);

sampl = get_sample(evArray);
nbBad = ceil(0.75*numel(evArray));

data(idxBad, sampl(1:nbBad)+5) = 5000;

nbBad = ceil(0.4*numel(evArray));

data(idxAlmostBad, sampl(1:nbBad)+5) = 5000;


end