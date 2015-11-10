function [status, MEh] = test_cca()
% TEST_CCA - Tests filter cca

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

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

%% constructor
try
    
    name = 'constructor';
    
    myFilt = filter.cca;
    
    cond = isa(myFilt, 'filter.cca') & isa(myFilt, 'filter.dfilt');
    
    myCCA = spt.bss.cca(...
        'MaxCorr',  0.8, ...
        'MinCorr',  0.2, ...
        'MaxCard',  5, ...
        'MinCard',  2 ...
        );
    
    myFilt = filter.cca(...
        'CCA',      myCCA, ...
        'Name',     'myCCA');
    
    myCCA = myFilt.CCA;
    
    cond = cond & ...
        isa(myFilt.CCA, 'spt.bss.cca') & ...
        myCCA.MaxCorr == 0.8 & ...
        myCCA.MinCorr == 0.2 & ...
        myCCA.MaxCard == 5 & ...
        myCCA.MinCard == 2 & ...
        strcmp(get_name(myFilt), 'myCCA');
    
    ok(cond, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end

%% Filtering out noise bursts
try
    
    name = 'filtering out noise bursts';
    
    [data, ~, S, snr, bndry] = sample_data_with_bursts();
    idx = bndry(1):bndry(2);
    myCCA = spt.bss.cca('MinCorr', 0.1);
    myFilter = filter.cca('CCA', myCCA);
    myFilter = filter.sliding_window(myFilter, ...
        'WindowLength', numel(idx));
    
    filter(myFilter, data);
    
    snrAfter = 0;
    
    for i = 1:size(data,1)
        snrAfter = snrAfter + var(S(i,idx))/var(data(i,idx)-S(i,idx));
    end
    snrAfter = snrAfter/numel(idx);
    ok(snrAfter > 5*snr, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end


%% Sample filtering
try
    
    name = 'sample filtering';
    
    [data, ~, S, ~, snr] = sample_data();
    
    myCCA = spt.bss.cca('MinCard', 2, 'MaxCard', 2);
    myFilter = filter.cca('CCA', myCCA);
    
    filter(myFilter, data);
    
    snrAfter = 0;
    for i = 1:size(data,1)
        snrAfter = snrAfter + var(S(i,:))/var(data(i,:)-S(i,:));
    end
    snrAfter = snrAfter/size(data,1);    
   
    ok(snrAfter > 20*snr, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end

%% Sample filtering with component filter
try
    
    name = 'sample filtering with component filter';
    
    [data, ~, S, ~, snr] = sample_data();
    
    myCCA = spt.bss.cca('MinCard', 2, 'MaxCard', 2);
    myFilter = filter.cca(...
        'CCA',              myCCA, ...
        'CCFilter',         filter.lpfilt('fc', 0.1));
 
    filter(myFilter, data);
    
    snrAfter = 0;
    for i = 1:size(data,1)
        snrAfter = snrAfter + var(S(i,:))/var(data(i,:)-S(i,:));
    end
    snrAfter = snrAfter/size(data,1);
    ok(snrAfter > 50*snr, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end

%% sliding_window
try
    
    name = 'sliding_window';
    
    [data, ~, S, ~, snr] = sample_data();
    
    myCCA = spt.bss.cca('MinCard', 2, 'MaxCard', 2);
    myFilter = filter.cca('CCA', myCCA);
    myFilter = filter.sliding_window(myFilter, ...
        'WindowLength', 1000);
    
    filter(myFilter, data);
    
    snrAfter = 0;
    for i = 1:size(data,1)
        snrAfter = snrAfter + var(S(i,:))/var(data(i,:)-S(i,:));
    end
    snrAfter = snrAfter/size(data,1);
    ok(snrAfter > 20*snr, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end

%% real data
try
    
    name = 'real data';
    
    data = real_data;
    myCCA = spt.bss.cca('MinCard', 2, 'MaxCard', 2);
    myFilter = filter.cca('CCA', myCCA);
    myFilter = filter.sliding_window(myFilter, ...
        'WindowLength', 1000);
    myFilter = filter.pca('PCFilter', myFilter, ...
        'PCA', spt.pca('MaxCard', 15));
    
    filter(myFilter, data);
    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end

%% Cleanup
try
    
    name = 'cleanup';
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



function [data, S, N, R, snr] = sample_data()

f = 1/100;
snr = 0.25;

S = randn(10, 50000);
N = zeros(size(S));

t = 0:size(S,2)-1;
for i = 1:size(S,1)
    N(i,:) = sqrt(2)*sin(2*pi*f*t+randi(100));
end

N = (1/sqrt(snr))*N;
X = S + N;

R = zeros(2, size(S,2));
R(1,:) = sin(2*pi*f*t);
R(2,:) = cos(2*pi*f*t);

data = import(physioset.import.matrix, X);

end

function [data, S, N, snr, bndry] = sample_data_with_bursts()

f = 1/100;

% boundary of the burst
bndry = [20001 21000];

S = zeros(10, 50000);
S(:, bndry(:,1):bndry(:,2)) = rand(10,2) * randn(2, 1000);

N = zeros(10, 50000);

t = 0:size(S,2)-1;
for i = 1:size(N,1)
    N(i,:) = sqrt(2)*sin(2*pi*f*t+randi(100));
    if i > 1,
        N(i,:) = N(i,:).*N(i-1, :);
    end
end

% Increase the 0.5 factor for better SNR
N = 0.5*N;
X = S + N;

snr = 0;
idx = bndry(1):bndry(2);
for i = 1:size(X,1)
    snr = snr + var(N(i,idx))/var(X(i,idx)-N(i,idx));
end
snr = snr/numel(idx);

data = import(physioset.import.matrix, X);

end


function dataCopy = real_data()

import pset.session;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;

fName = '20131121T171325_647f7.pseth';
if ~exist(fName, 'file') > 0,
    url = 'http://kasku.org/data/meegpipe/20131121T171325_647f7.zip';
    unzip(url, pwd);
end
data = pset.load(fName);
dataCopy = copy(data);

end

