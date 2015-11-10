function [status, MEh] = test_sliding_window()
% TEST_SLIDING_WINDOW - Tests filter sliding_window

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

NB_SAMPLES = 10000;

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

%% constructor
try
    
    name = 'constructor';
    
    myFilt = filter.sliding_window;
    
    cond = isa(myFilt, 'filter.sliding_window') & ...
        isa(myFilt, 'filter.dfilt');
    
    myFilt = filter.sliding_window(...
        'WindowLength', 10, ...
        'WindowOverlap', 20, ...
        'WindowFunction', @kaiser, ...
        'Filter', filter.pca('Name', 'noname'));
    
    cond = cond & ...
        myFilt.WindowLength == 10 & ...
        myFilt.WindowOverlap == 20 & ...
        mean(myFilt.WindowFunction(2)) > 0.9402 & ...
        mean(myFilt.WindowFunction(2)) < 0.9404 & ...
        strcmp(get_name(myFilt.Filter), 'noname');
    
    myFilt = filter.sliding_window(filter.tpca('Order', 5));
    
    cond = cond & myFilt.Filter.Order == 5;
    
    ok(cond, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end

%% Sample filtering
try
    
    name = 'sample filtering';
    
    [data, ~, S, ~, snr] = sample_data();
    myFilter = filter.pca('PCA', spt.pca('MaxCard', 4), ...
        'PCFilter', filter.lpfilt('fc', 0.1));    
    
    mySlidingWindowFilter = filter.sliding_window(myFilter, ...
        'WindowLength', NB_SAMPLES);
    
    filter(mySlidingWindowFilter, data);
    
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