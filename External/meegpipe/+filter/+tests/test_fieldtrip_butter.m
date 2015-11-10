function [status, MEh] = test_fieldtrip_butter()
% TEST_FIELDTRIP_BUTTER - Tests filter fieldtrip_butter

import mperl.file.spec.*;
import test.simple.*;

MEh     = [];

initialize(5);

%% Constructors
try
    
    name = 'constructors';
    filter.fieldtrip_butter;
    filter.fieldtrip_butter('Fp', [0 .5]);
    filter.fieldtrip_butter([0 .5]);
    filter.fieldtrip_butter([.2 .3]);
    filter.fieldtrip_butter([.3 1]);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Low pass filtering
try
    
    name = 'low pass filtering';
    
    fs = 250;
    X = filter(filter.lpfilt('fc', 1/(fs/2)), randn(3,10000));
    N = 0.1*filter(filter.hpfilt('fc', 2/(fs/2)), randn(3, 10000));   
    snr0 = 0;
    for i = 1:size(X, 1)
        snr0 = snr0 + var(X(i,:))/var(N(i,:));
    end
    
    % A low pass filter should improve the SNR
    myFilt = filter.fieldtrip_butter([0 1.5/(fs/2)]);
    Y = filtfilt(myFilt, X+N);
    
    snr1 = 0;
    for i = 1:size(X, 1)
        snr1 = snr1 + var(X(i,:))/var(Y(i,:) - X(i,:));
    end
    ok(snr1 > 10*snr0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% High pass filtering
try
    
    name = 'high pass filtering';
    
    fs = 250;
    X = filter(filter.hpfilt('fc', 2/(fs/2)), randn(3,10000));
    N = 20*filter(filter.lpfilt('fc', 1/(fs/2)), randn(3, 10000));   
    snr0 = 0;
    for i = 1:size(X, 1)
        snr0 = snr0 + var(X(i,:))/var(N(i,:));
    end
    
    % A high pass filter should improve the SNR
    myFilt = filter.fieldtrip_butter([1.5/(fs/2) 1]);
    Y = filtfilt(myFilt, X+N);
    
    snr1 = 0;
    for i = 1:size(X, 1)
        snr1 = snr1 + var(X(i,:))/var(Y(i,:) - X(i,:));
    end
    ok(snr1 > 10*snr0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% band pass filtering
try
    
    name = 'band pass filtering';
    
    fs = 250;
    X = filter(filter.bpfilt('fc', [10 30]/(fs/2)), randn(3,10000));
    N1 = 10*filter(filter.lpfilt('fc', 5/(fs/2)), randn(3, 10000));   
    N2 = 10*filter(filter.hpfilt('fc', 35/(fs/2)), randn(3, 10000)); 
    N = N1 + N2;
    snr0 = 0;
    for i = 1:size(X, 1)
        snr0 = snr0 + var(X(i,:))/var(N(i,:));
    end
    
    % A band pass filter should improve the SNR
    myFilt = filter.fieldtrip_butter([8 32]/(fs/2));
    Y = filtfilt(myFilt, X+N);
    
    snr1 = 0;
    for i = 1:size(X, 1)
        snr1 = snr1 + var(X(i,:))/var(Y(i,:) - X(i,:));
    end
    ok(snr1 > 10*snr0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% stopband filtering
try
    
    name = 'stopband filtering';
    
    fs = 250;
    X = filter(filter.sbfilt('fc', [10 30]/(fs/2)), randn(3,10000));
    N = 10*filter(filter.bpfilt('fp', [12 28]/(fs/2)), randn(3, 10000));   
   
    snr0 = 0;
    for i = 1:size(X, 1)
        snr0 = snr0 + var(X(i,:))/var(N(i,:));
    end
    
    % A stop pass filter should improve the SNR
    myFilt = filter.fieldtrip_butter('Fs', [11 29]/(fs/2));
    Y = filtfilt(myFilt, X+N);
    
    snr1 = 0;
    for i = 1:size(X, 1)
        snr1 = snr1 + var(X(i,:))/var(Y(i,:) - X(i,:));
    end
    ok(snr1 > 10*snr0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Testing summary
status = finalize();