function [status, MEh] = test_ftrip()
% test_ftrip - Test conversion to fieldtrip format

import test.simple.*;
import mperl.file.spec.*;
import physioset.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

MEh     = [];

initialize(7);

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

%% convert a single dataset to fieldtrip
try
    
    name = 'convert a single dataset to fieldtrip';
    
    [~, data] = sample_data(1);
    
    ftripData = fieldtrip(data{:});
    
    ok( ...
        isstruct(ftripData) & ...
        isfield(ftripData, 'trial') & ...
        iscell(ftripData.trial) & ...
        numel(ftripData.trial) == 1 & ...
        all(size(ftripData.trial{1}) == size(data{1})), ...
        ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% bad data policy: donothing
try
    
    name = 'bad data policy: donothing';
    
    [~, data] = sample_data_with_bad_data;
    
    ftripData = fieldtrip(data, 'BadDataPolicy', 'donothing');
    
    ok( ...
        isstruct(ftripData) & ...
        isfield(ftripData, 'trial') & ...
        iscell(ftripData.trial) & ...
        numel(ftripData.trial) == 1 & ...
        all(size(ftripData.trial{1}) == size(data)), ...
        ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% bad data policy: reject
try
    
    name = 'bad data policy: reject';
    
    [~, data, badSamplIdx, badChanIdx] = sample_data_with_bad_data;
    
    warning('off', 'deal_with_bad_data:Obsolete');
    ftripData = fieldtrip(data, 'BadDataPolicy', 'reject');
    warning('on', 'deal_with_bad_data:Obsolete');
    
    nChan = size(data,1) - numel(badChanIdx);
    nSampl = size(data, 2) - numel(badSamplIdx);
    goodChanIdx = setdiff(1:size(data, 1), badChanIdx);
    goodSamplIdx = setdiff(1:size(data,2), badSamplIdx);
    
    ok( ...
        isstruct(ftripData) && ...
        isfield(ftripData, 'trial') && ...
        iscell(ftripData.trial) && ...
        numel(ftripData.trial) == 1 && ...
        all(size(ftripData.trial{1}) ~= size(data)) && ...
        all(size(ftripData.trial{1}) == [nChan, nSampl]) && ...
        all(abs(data(goodChanIdx(1),goodSamplIdx) - ftripData.trial{1}(1,:)) < 1e-7) && ...
        numel(ftripData.cfg.event) == (numel(get_event(data)) - 2) && ...
        numel(get_event(data)) == 11, ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% bad data policy: flatten
try
    
    name = 'bad data policy: flatten';
    
    [~, data, badSamplIdx, badChanIdx] = sample_data_with_bad_data;
    
    ftripData = fieldtrip(data, 'BadDataPolicy', 'flatten');
    
    ok( ...
        isstruct(ftripData) && ...
        isfield(ftripData, 'trial') && ...
        iscell(ftripData.trial) && ...
        numel(ftripData.trial) == 1 && ...
        all(size(ftripData.trial{1}) == size(data)) && ...
        all(abs(ftripData.trial{1}(badChanIdx(1), badSamplIdx)) < eps) && ...
        numel(ftripData.cfg.event) == numel(get_event(data)), ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% convert multiple datasets to fieldtrip
try
    
    name = 'merging multiple datasets into a fieldtrip structure';
    
    [~, data] = sample_data(3);
    
    ftripData = fieldtrip(data{:});
    
    ok( ...
        iscell(ftripData) & numel(ftripData) == 3, ...
        ...
        name);
    
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


function [file, data] = sample_data(nbFiles)

if nargin < 1 || isempty(nbFiles),
    nbFiles = 2;
end

file = cell(1, nbFiles);
data = cell(1, nbFiles);

mySens = sensors.eeg.from_template('egi256');
mySens = subset(mySens, 1:5);
myImporter = physioset.import.matrix('Sensors', mySens);

for i = 1:nbFiles
    
    data{i} =  import(myImporter, rand(5, 1000));
    evArray = physioset.event.event(1:100:1000, 'Type', num2str(i));
    add_event(data{i}, evArray);
    file{i} = get_datafile(data{i});
    
    save(data{i});
    
end


end


function [file, data, badSampleIdx, badChannelIdx] = sample_data_with_bad_data()

mySens = sensors.eeg.dummy(5);
myImporter = physioset.import.matrix('Sensors', mySens);

data = import(myImporter, rand(5, 1000));

evArray = physioset.event.event(1:100:1000, 'Type', 'myev');
add_event(data, evArray);

badSampleIdx = 1:100;
badChannelIdx = 2:3;

set_bad_sample(data, badSampleIdx);
set_bad_channel(data, badChannelIdx);

save(data);
file = get_datafile(data);


end

