function [status, MEh] = test_eeglab_fir()
% TEST_EEGLAB_FIR - Tests eeglab_fir filter
import mperl.file.spec.*;
import filter.*;
import test.simple.*;
import pset.session;
import datahash.DataHash;

% Number of samples for simulated signals
NB_SAMPLES = 10000;

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

%% constructor
try
    
    name = 'constructor';
    warning('off', 'eeglab_fir:SubOptimal');
    filter.eeglab_fir;
    obj  = filter.eeglab_fir([0 20], 'Verbose', false);
    obj2 = filter.eeglab_fir('Fp', [0 20]);
    warning('on', 'eeglab_fir:SubOptimal');
    ok(...
        isa(obj, 'filter.eeglab_fir') & ~is_verbose(obj) & ...
        all(obj2.Fp == [0 20]) & all(obj.Fp == [0 20]), ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% filtering across boundaries
try
    
    name = 'filtering across boundaries';
    X = randn(5, 10000);
    
    X = filter(filter.bpfilt('Fp', [5 15]/(250/2)), X);
    
    N = 0.1*randn(5, size(X,2));   
    
    data = import(physioset.import.matrix('SamplingRate', 250), X+N);
    
    set_bad_sample(data, [200:250 600:750]);
    
    snr0 = 0;
    for i = 1:size(X, 1)
        snr0 = snr0 + var(X(i,:))/var(N(i,:));
    end
    
    warning('off', 'eeglab_fir:TooShortBlock');
    warning('off', 'eeglab_fir:SubOptimal');
    myFilt = filter.eeglab_fir('Fp', [5 15], 'Notch', false);
    warning('on', 'eeglab_fir:SubOptimal');
    filter(myFilt, data);
    warning('on', 'eeglab_fir:TooShortBlock');
    
    snr1 = 0;
    for i = 1:size(X, 1)
        snr1 = snr1 + var(X(i,:))/var(data(i,:) - X(i,:));
    end
    [~, warnId] = lastwarn;
    ok( ~isempty(warnId) && ...
        strcmp(warnId, 'eeglab_fir:TooShortBlock') && ...
        snr1 > 2*snr0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% band-pass filter
try
    
    name = 'band-pass filter';
    X = randn(5, NB_SAMPLES);
    
    X = filter(filter.bpfilt('Fp', [5 15]/(250/2)), X);
    
    N = 0.1*randn(5, NB_SAMPLES);   
    
    data = import(physioset.import.matrix('SamplingRate', 250), X+N);
    
    snr0 = 0;
    for i = 1:size(X, 1)
        snr0 = snr0 + var(X(i,:))/var(N(i,:));
    end
    
    warning('off', 'eeglab_fir:SubOptimal');
    myFilt = filter.eeglab_fir('Fp', [5 15], 'Notch', false);
    warning('on', 'eeglab_fir:SubOptimal');
    filter(myFilt, data);
    
    snr1 = 0;
    for i = 1:size(X, 1)
        snr1 = snr1 + var(X(i,:))/var(data(i,:) - X(i,:));
    end
    ok(snr1 > 5*snr0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% low-pass filter
try
    
    name = 'low-pass filter';
    X = randn(5, NB_SAMPLES);
    
    X = filter(filter.lpfilt('fc', 10/(250/2)), X);
    
    N = 0.1*randn(5, NB_SAMPLES);   
    
    data = import(physioset.import.matrix('SamplingRate', 250), X+N);
    
    snr0 = 0;
    for i = 1:size(X, 1)
        snr0 = snr0 + var(X(i,:))/var(N(i,:));
    end
    
    warning('off', 'eeglab_fir:SubOptimal');
    myFilt = filter.eeglab_fir('Fp', [0 10]);
    warning('on', 'eeglab_fir:SubOptimal');
    filter(myFilt, data);
    
    snr1 = 0;
    for i = 1:size(X, 1)
        snr1 = snr1 + var(X(i,:))/var(data(i,:) - X(i,:));
    end
    ok(snr1 > 3*snr0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% high-pass filter
try
    
    name = 'low-pass filter';
    X = randn(5, NB_SAMPLES);
    
    X = filter(filter.lpfilt('fc', 10/(250/2)), X);
    
    N = 0.1*randn(5, NB_SAMPLES);   
    
    data = import(physioset.import.matrix('SamplingRate', 250), X+N);
    
    snr0 = 0;
    for i = 1:size(X, 1)
        snr0 = snr0 + var(N(i,:))/var(X(i,:));
    end
    
    warning('off', 'eeglab_fir:SubOptimal');
    myFilt = filter.eeglab_fir('Fp', [0 10], 'Notch', true);
    warning('on', 'eeglab_fir:SubOptimal');
    filter(myFilt, data);
    
    snr1 = 0;
    for i = 1:size(X, 1)
        snr1 = snr1 + var(N(i,:))/var(data(i,:) - N(i,:));
    end
    ok(snr1 > 3*snr0, name);
    
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