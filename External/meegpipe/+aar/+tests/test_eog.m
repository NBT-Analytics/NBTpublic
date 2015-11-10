function [status, MEh] = test_eog()
% TEST_EOG- Tests EOG correction

import mperl.file.spec.*;
import test.simple.*;
import meegpipe.node.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;

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
    status = finalize();
    return;
    
end

%% topo_ratio with real data
try
    
    name = 'topo_ratio with real data';
    data = get_real_data;  
   
    myNode = aar.eog.topo_generic(...
        'GenerateReport',   false);
    
    run(myNode, data);
 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end


%% topo_ratio with real data (eyes closed)
try
    
    name = 'topo_ratio with real data (eyes closed)';
    data = get_real_data_ec;  
    
    lasipFilt = get_config(aar.eog.topo_egi256_hcgsn1, 'Filter');
   
    myNode = aar.eog.topo_egi256_hcgsn1(...
        'GenerateReport',   true, ...
        'Verbose',          false, ...
        'Filter',           lasipFilt);
    
    run(myNode, data);
 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end

%% topo_ratio feature
try
    
    name = 'topo_ratio';
    [data, S, sensIdx] = sample_data;
    
    othersIdx = sort(setdiff(1:size(data,1), sensIdx));
    
    sensLabels = labels(subset(sensors(data), sensIdx));
    othersLabels = labels(subset(sensors(data), othersIdx));
    
    myFeat = spt.feature.topo_ratio(...
        'SensorsNumLeft',   sensLabels, ...
        'SensorsDen',       othersLabels);
    
    myCrit = spt.criterion.threshold(myFeat, 'Max', 30);
    
    snrOrig = signal_to_noise(data, S);
    
    lasipFilt = get_config(bss.eog, 'Filter');

    myNode = bss.eog(...
        'Criterion',        myCrit, ...
        'RetainedVar',      100, ...
        'GenerateReport',   true, ...
        'Filter',           lasipFilt);
    
    run(myNode, data);
    
    snrNew = signal_to_noise(data, S);
    
    ok(snrNew > snrOrig, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end


%% process random data: no EOG components
try
    
    name = 'process random data: no EOG components';
    
    X = rand(4, 5000);
    
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    
    eegSensors = subset(eegSensors, 1:4);
    
    importer = physioset.import.matrix(250, 'Sensors', eegSensors);
    
    data = import(importer, X);
    
    myFeat = spt.feature.psd_ratio.eog;
    myCrit = spt.criterion.threshold(myFeat, ...
        'Max',      25, ...
        'MinCard',  0, ...
        'MaxCard',  Inf);
    
    lasipFilt = get_config(meegpipe.node.bss.eog, 'Filter');
    
    myNode = meegpipe.node.bss.eog(...
        'Criterion',        myCrit, ...
        'GenerateReport',   true, ...
        'Filter',           lasipFilt);
    run(myNode, data);
    
    X = X - repmat(mean(X, 2), 1, size(X,2));
    
    ok(max(abs(data(:)-X(:))) < 1e-2, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process real EEG data
try
    
    name = 'process real EEG data';
    
    data = get_real_data;
    
    myCrit = get_config(meegpipe.node.bss.eog, 'Criterion');
    myCrit.Max = {20 15 2};
    myCrit.MaxCard = Inf;
    
    lasipFilt = filter.lasip.eog('Decimation', 40);
    lasipFilt = set_verbose_level(lasipFilt, 0);
    
    myNode = meegpipe.node.bss.eog(...
        'Criterion',        myCrit, ...
        'GenerateReport',   true, ...
        'Filter',           lasipFilt, ...
        'RegrFilter',       [], ...
        'GenerateReport',   true);
    
    warning('off', 'snapshots:TooManyVertices');
    newData = run(myNode, copy(data));
    warning('on', 'snapshots:TooManyVertices');
    
    center(data);
    ok(max(abs(data(:)-newData(:))) > 100, name);
    
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


function [data, S, sensIdx] = sample_data()

sens = sensors.eeg.from_template('egi256');

sens = subset(sens, 1:8);

S = rand(6, 10000);
S = S - repmat(mean(S,2), 1, size(S,2));

t = 0:size(S,2)-1;
N = 0.5*[cos(2*pi*(1/500)*t).*sin(2*pi*(1/1000)*t); cos(2*pi*(1/750)*t)];
N = N - repmat(mean(N,2), 1, size(N,2));
N = N + 0.1*rand(size(N));

% Sensors where the EOG artifact will be greatest
tmp = randperm(8);
sensIdx = sort(tmp(1:2));

% Mixing matrix
A = rand(8);

% Ensure that the projection of the EOG sources is maximal to the EOG sens
A(sensIdx,1:size(N,1)) = ...
    max(abs(A(:)))*(5+randi(10, numel(sensIdx), size(N,1)));

A = misc.unit_norm(A);
A(:,1:2) = 5*A(:,1:2);

X = [N;S];
X = X - repmat(mean(X,2), 1, size(X,2));
data = A*X;

data = import(physioset.import.matrix('Sensors', sens), data);

S = A(:,size(N,1)+1:end)*S;


end


function snr = signal_to_noise(X, S)

snr = 0;
for i = 1:size(X,1)
    snr = snr + var(S(i,:))/var(X(i,:)-S(i,:));
end
snr = 10*log10(snr/size(X,1));

end


function dataCopy = get_real_data()

import pset.session;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;

FILE_NAME = '20131121T171325_647f7';

if exist([FILE_NAME '.pseth'], 'file') > 0,
    data = pset.load([FILE_NAME '.pseth']);
else
    % Try downloading the file
    url = ['http://kasku.org/data/meegpipe/' FILE_NAME '.zip'];
    unzipDir = catdir(session.instance.Folder, FILE_NAME);
    unzip(url, unzipDir);
    fileName = catfile(unzipDir, [FILE_NAME '.pseth']);
    data = pset.load(fileName);
end
dataCopy = copy(data);

end

function dataCopy = get_real_data_ec()

import pset.session;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;

if exist('20131129T161654_a26da.pseth', 'file') > 0,
    data = pset.load('20131129T161654_a26da.pseth');
else
    % Try downloading the file
    url = 'http://kasku.org/data/meegpipe/20131129T161654_a26da.zip';
    unzipDir = catdir(session.instance.Folder, '20131129T161654_a26da');
    unzip(url, unzipDir);
    fileName = catfile(unzipDir, '20131129T161654_a26da.pseth');
    data = pset.load(fileName);
end
dataCopy = copy(data);


end
