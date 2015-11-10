function [status, MEh] = test1()
% TEST1 - Tests demo functionality

import mperl.file.spec.*;
import plotter.fvtool2.*;
import test.simple.*;

MEh     = [];

initialize(7);

%% plot sample filters
try
    
    name = 'plot sample filters';
    f1 = filter.hpfilt('Fc', .7);
    f2 = filter.lpfilt('Fc', .2);
    h = fvtool2(mdfilt(f1), mdfilt(f2), 'Visible', false);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% plot filer in new figure
try
    
    name = 'plot filter in new figure';
    f3 = filter.bpfilt('Fp', [.3 .6]);
    h = overlay(h, mdfilt(f3), 'Visible', false, 'Analysis', 'freq');
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% change props for all figs
try
    
    name = 'change props for all figs';
    set_axes(h, 'FontSize', 18, 'LineWidth', 2);
    set_line(h, 'Color', 'Black');
    set_line(h, {'phase'}, 'Color', 'Red');
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% add legends
try
    
    name = 'add legends';
    select(h, 1);
    legend(h, 'Filter 1', 'Filter 2');
    select(h, 2);
    legend(h, 'Filter X');
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% change filter color
try
    
    name = 'change filter color';
    select(h, []);
    set_line(h, {'Filter 1'}, 'Color', 'Blue');
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% change legend props
try
    
    name = 'change legend props';
    select(h, []);
    set_legend(h, 'FontSize', 15);
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
end

%% set title, xlabel, ylabel props
try
    
    name = 'set title, xlabel, ylabel props';
    select(h, []);
    set_title(h, 'FontWeight', 'Bold');
    set_xlabel(h, 'FontWeight', 'Bold');
    set_ylabel(h, 'FontWeight', 'Bold');
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Testing summary
status = finalize();