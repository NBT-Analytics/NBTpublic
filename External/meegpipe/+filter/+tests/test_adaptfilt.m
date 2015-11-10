function [status, MEh] = test_adaptfilt()
% TEST_ADAPTFILT - Tests class adaptfilt

import mperl.file.spec.*;
import filter.*;
import test.simple.*;

MEh     = [];

initialize(2);

%% Default constructors
try
    
    name = 'default constructors';
    myFilter = adaptfilt;
    ok(isa(myFilter, 'filter.adaptfilt'), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Filtering sinusoidal noise using an RLS filter
try
    
    name = 'filtering sinusoidal noise using an RLS filter';
    % Simulate a noise source
    N = 2*sin(2*pi*(1/500)*(1:10000));
    X = randn(1, size(N,2));
    % A simulated regressor that is correlated with the noise source
    R = 4*sin(2*pi*(1/500)*(1:10000)) + randn(1, size(N,2));
    % Filter out the regressor from X
    myFilter = filter.adaptfilt(adaptfilt.rls);
    snr0 = 0;
    for i = 1:size(X, 1)
        snr0 = snr0 + var(X(i,100:end))/var(N(i,100:end));
    end
    Y = filter(myFilter, X+N, R);
    snr1 = 0;
    for i = 1:size(X, 1)
        snr1 = snr1 + var(X(i,100:end))/var(Y(i,100:end) - X(i,100:end));
    end
    ok(snr1 > 5*snr0 , name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Testing summary
status = finalize();