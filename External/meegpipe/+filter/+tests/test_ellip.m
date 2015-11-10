function [status, MEh] = test_ellip()
% TEST_ELLIP - Tests filter.ellip

import mperl.file.spec.*;
import filter.*;
import test.simple.*;
import pset.session;
import datahash.DataHash;

MEh     = [];

initialize(6);

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
    filter.ellip;
    warning('off', 'design_filter:VariableGroupDelay');
    % This filter will be non-verbose even if we set Verbose to true
    % becauset he global Verbose variable is set to false during tests
    obj  = filter.ellip([0 0.5], 'Verbose', true);
    obj2 = filter.ellip([0.5 1]);
    warning('on', 'design_filter:VariableGroupDelay');
    ok(...
        isa(obj, 'filter.ellip') && ...
        ~is_verbose(obj) && ... 
        ~is_verbose(obj2) && ...
        obj2.Specs.Fpass == 0.5 && ...
        obj.Specs.Fpass == 0.5, ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% high-pass filter
try
    
    name = 'high-pass filter';
    
    % Length of the test signals
    N = 10000;
    % Number of channels of the test signals
    M = 3; 

    % A high frequency signal
    myFilter = filter.hpfilt(10/(250/2));
    X = filter(myFilter, randn(M, N));
    
    % Low frequency noise
    N = filter(filter.lpfilt(8/(250/2)), 5*randn(M, N));
    
    data = import(physioset.import.matrix('SamplingRate', 250), X+N);
    
    snr0 = 0;
    for i = 1:size(X, 1)
        snr0 = snr0 + var(X(i,:))/var(N(i,:));
    end
    
    % Apply a high-pass filter -> it should increase the SNR!
    warning('off', 'design_filter:VariableGroupDelay');
    myFilt = filter.ellip([10/(data.SamplingRate/2) 1]);
    warning('on', 'design_filter:VariableGroupDelay');
    filtfilt(myFilt, data);
    
    snr1 = 0;
    for i = 1:size(X, 1)
        snr1 = snr1 + var(X(i,:))/var(data(i,:) - X(i,:));
    end
    ok(snr1 > 10*snr0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% low-pass filter
try
    
    name = 'low-pass filter';
    
    % Length of the test signals
    N = 10000;
    % Number of channels of the test signals
    M = 3; 

    % A low frequency signal
    myFilter = filter.lpfilt(10/(250/2));
    X = filter(myFilter, randn(M, N));
    
    % High frequency noise
    N = filter(filter.hpfilt(15/(250/2)), 5*randn(M, N));
    
    data = import(physioset.import.matrix('SamplingRate', 250), X+N);
    
    snr0 = 0;
    for i = 1:size(X, 1)
        snr0 = snr0 + var(X(i,:))/var(N(i,:));
    end
    
    % Apply a low-pass filter -> it should increase the SNR!
    warning('off', 'design_filter:VariableGroupDelay');
    myFilt = filter.ellip([0 10/(data.SamplingRate/2)]);
    warning('on', 'design_filter:VariableGroupDelay');
    filtfilt(myFilt, data);
    
    snr1 = 0;
    for i = 1:size(X, 1)
        snr1 = snr1 + var(X(i,:))/var(data(i,:) - X(i,:));
    end
    ok(snr1 > 10*snr0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% band-pass filter
try
    
    name = 'band-pass filter';
    
    % Length of the test signals
    Ns = 10000;
    % Number of channels of the test signals
    M = 3; 

    % A band-pass signal
    myFilter = filter.bpfilt([10 30]/(250/2));
    X = filter(myFilter, randn(M, Ns));
    
    % High/low frequency noise
    N1 = filter(filter.hpfilt(35/(250/2)), 5*randn(M, Ns));
    N2 = filter(filter.lpfilt(10/(250/2)), 5*randn(M, Ns));
    N = N1 + N2;
    
    data = import(physioset.import.matrix('SamplingRate', 250), X+N);
    
    snr0 = 0;
    for i = 1:size(X, 1)
        snr0 = snr0 + var(X(i,:))/var(N(i,:));
    end
    
    % Apply a band-pass filter -> it should increase the SNR!
    warning('off', 'design_filter:VariableGroupDelay');
    myFilt = filter.ellip([10 30]/(data.SamplingRate/2));
    warning('on', 'design_filter:VariableGroupDelay');
    filtfilt(myFilt, data);
    
    snr1 = 0;
    for i = 1:size(X, 1)
        snr1 = snr1 + var(X(i,:))/var(data(i,:) - X(i,:));
    end
    ok(snr1 > 10*snr0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
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