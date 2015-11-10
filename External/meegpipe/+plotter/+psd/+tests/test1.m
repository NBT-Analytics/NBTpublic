function [status, MEh] = test1()
% TEST1 - Tests demo functionality

import mperl.file.spec.*;
import test.simple.*;
import plotter.psd.root_path;

MEh     = [];

initialize(11);


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
    h    = spectrum.welch('Hamming', 125);
    hpsd = psd(h, x, 'Fs', 125, 'ConfLevel', 0.99);
    hp   = plotter.psd.psd('Visible', false);
    hp   = plot(hp, hpsd);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% plot sample data
try
    
    name    = 'plot additional PSDs';
    hpsd2   = psd(h, xfilt, 'Fs', 125, 'ConfLevel', 0.95);
    hp      = plot(hp, hpsd2, 'r');
    hpsd3   = psd(h, xfilt2, 'Fs', 125);
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
    set_config(hp, 'ConfInt', false);
    set_config(hp, 'ConfInt', true);
    hp = set_psdname(hp, 1, 'Original signal');
    hp = set_psdname(hp, 2, 'Scaled+filtered signal');
    hp = set_psdname(hp, 3, 'Scaled+filtered signal');
    hp = set_line(hp, 1:3, 'LineWidth', 2);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% match PSD scales
try
    
    name    = 'match PSDs scales';
    hp = match_scale(hp);
    hp = match_scale(hp, [5 25]);
    hp = orig_scale(hp);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% clone figure
try
    
    name    = 'clone figure';
    hpClone = clone(hp);
    hpClone = set_legend(hpClone, 'Visible', 'off');
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% black background
try
    
    name    = 'black background';
    hpClone = blackbg(hpClone);
    hpClone = set_title(hpClone,  'FontWeight', 'bold', 'Fontsize', 12);
    hpClone = set_xlabel(hpClone, 'FontWeight', 'bold');
    hpClone = set_ylabel(hpClone, 'FontWeight', 'bold');
    hpClone = set_legend(hpClone, 'VISIBLE', 'on');
    set(hpClone, 'ConfIntLegend', false);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% playing with figure properties
try
    
    name    = 'playing with fig properties';
    x = randn(1,10000);
    hpsd = psd(spectrum.welch, x);
    h = plotter.psd.psd('Visible', false);
    h = plot(h, hpsd);
    set_line(h, 1,  'LineWidth', 3, 'Color', 'Black');
    legend(h);
    set_legend(h,   'FontSize', 16);
    blackbg(h);
    set_legend(h,   'Visible', 'off');
    set_title(h,    'String', 'Another title', 'FontSize', 18);
    set_ylabel(h,   'Visible', 'off');
    set_xlabel(h,   'Visible', 'off');
    set_axes(h,     'FontSize', 14);
    set_edges(h, [],    'Color', 'red'); % should do nothing
    set_shadow(h, [],   'Color', 'red');
    set_psdname(h, 1,   'My PSD');
    legend(h);  
    rnd_line_colors(h);  
    set_line(h, [],     'Color', 'white');  
    match_scale(h); % should do nothing  
    orig_scale(h);  % should do nothing  
    get_legend(h,       'Visible'); 
    get_title(h,        'String');   
    get_ylabel(h,       'String');  
    get_xlabel(h,       'String'); 
    get_line(h, [],     'Color');
    get_edges(h, [],    'Color');
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% rambling around
try
    
    name    = 'rambling';
    h       = spectrum.welch;
    hpsd    = psd(h, randn(1,1000), 'Fs', 100, 'ConfLevel', 0.95);
    hp      = plot(plotter.psd.psd('Visible', false), hpsd);
    hpsd2   = psd(h, 0.5*randn(1,1000), 'Fs', 100, 'ConfLevel', 0.9);
    plot(hp, hpsd2, 'r'); 
    set_edges(hp, 2, 'LineWidth', 3, 'Color', 'green');
    get_edges(hp, [], 'Color');
    set(hp, 'ConfIntLegend', false);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end


%% focus/unfocus on freq. range
try
    
    name = 'focus/unfocus on freq range';
    set_config(hpClone, 'FrequencyRange', [5 30]);
    set_config(hpClone, 'FrequencyRange', [-Inf Inf]);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% using MatchScale property
try
    
    name = 'focus/unfocus on freq range';
    set_config(hpClone, 'FrequencyRange', [0 60]);
    set_config(hpClone, 'MatchScale', [40 60]);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Testing summary
status = finalize();


end