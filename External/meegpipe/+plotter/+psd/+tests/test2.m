function [status, MEh] = test2()
% TEST2 - Tests BOIs functionality

import mperl.file.spec.*;
import test.simple.*;
import plotter.psd.root_path;

MEh     = [];
VISIBLE = false;

initialize(4);


%% Load sample data
try
    
    name = 'load sample data';
    x      = dlmread(catfile(root_path, 'x.csv'));
    xfilt  = dlmread(catfile(root_path, 'xfilt.csv'));
    xfilt2 = dlmread(catfile(root_path, 'xfilt2.csv'));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end


%% plot sample data
try
    
    name = 'plot sample data';
    h    = spectrum.welch('Hamming', 250);
    hpsd = psd(h, x, 'Fs', 250, 'ConfLevel', 0.99);
    hp   = plotter.psd.psd('Visible', VISIBLE, 'LogData', false);
    hp   = plot(hp, hpsd);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% plot sample data
try
    
    name    = 'plot additional PSDs';
    hpsd2   = psd(h, xfilt, 'Fs', 250, 'ConfLevel', 0.95);
    hp      = plot(hp, hpsd2, 'r');
    hpsd3   = psd(h, xfilt2, 'Fs', 250);
    hp      = plot(hp, hpsd3, 'b');
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% modify PSDs props
try
    
    name    = 'modify PSDs props';
    set_config(hp, 'Transparent', true);
    set_config(hp, 'NormalizeScale', true);
    set_config(hp, 'BOI', plotter.psd.eeg_bands);
    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end


%% Testing summary
status = finalize();


end