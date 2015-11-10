function [status, MEh] = test_tpca()
% TEST_TPCA - Tests filter tpca

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;

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
    
    myFilt = filter.tpca;
    
    cond = isa(myFilt, 'filter.tpca') & isa(myFilt, 'filter.dfilt');
    
    myFilt = filter.tpca(...
        'Order', 10, ...
        'PCFilter', filter.lpfilt('fc', 0.1), ...
        'PCA', spt.pca('RetainedVar', 90));
    
    cond = cond & ...
        myFilt.Order == 10 & ...
        isa(myFilt.PCFilter, 'filter.lpfilt') & ...
        myFilt.PCA.RetainedVar == 90;
    
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
    myFilter = filter.tpca('PCFilter', filter.lpfilt('fc', 0.1));    
    
    filter(myFilter, data);
    
    snrAfter = 0;
    for i = 1:size(data,1)
        snrAfter = snrAfter + var(S(i,:))/var(data(i,:)-S(i,:));
    end
    snrAfter = snrAfter/size(data,1);
    ok(snrAfter > 25*snr, name);
    
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

S = randn(10, 10000);
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