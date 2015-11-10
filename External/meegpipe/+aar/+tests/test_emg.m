function [status, MEh] = test_emg()
% TEST_EMG- Tests EMG correction

import mperl.file.spec.*;
import test.simple.*;
import meegpipe.node.*;
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
    status = finalize();
    return;
    
end

%% Constructor
try
    
    name = 'constructors';
    aar.emg.new;
    aar.emg.emg;
    aar.emg.cca_sliding_window;
    
    myNode = aar.emg.cca_sliding_window(...
        'WindowLength', 2, 'CorrectionTh', 50);
  
    filtObj = get_config(myNode, 'Filter');
    
    ok(filtObj.WindowLength(1) == 2 & ...
        filtObj.Filter.PCFilter.CCA.MinCorr == 0.5, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end

%% Filtering out EMG bursts
try
    
    name = 'filtering out EMG bursts';
    
    [data, ~, S, snr, bndry] = sample_data_with_bursts();
    idx = bndry(1):bndry(2);
    myNode = aar.emg.cca_sliding_window(...
        'GenerateReport', false, 'Save', false);
    
    run(myNode, data);
    
    snrAfter = 0;
    
    for i = 1:size(data,1)
        snrAfter = snrAfter + var(S(i,idx))/var(data(i,idx)-S(i,idx));
    end
    snrAfter = snrAfter/numel(idx);
    ok(snrAfter > 20*snr, name);
    
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

data = import(physioset.import.matrix('Sensors', sensors.eeg.dummy(10)), X);

end

