function [figNames, captions, groups, extra, extraCap] = plot(obj, data, varargin)
% PLOT - Plots filter characteristics
%
% See also: fvtool2, report.gallery_plotter

% Documentation: class_fvtool2.txt
% Description: Plot filter characteristics

import mperl.file.spec.catfile;
import mperl.join;
import plotter.driver2format;
import plot2svg.plot2svg;
import plotter.fvtool2.fvtool2;

%% Error checking
if ~isa(data, 'filter.dfilt'),
    error('DATA must be a filter.dfilt object');
end

% For convenience
config = get_config(obj);

%% Initialize the output arguments
figNames    = cell(2, 1);
captions    = cell(2, 1);
extra       = cell(2, 1);
extraCap    = cell(2, 1);
groups{1}   = 'Frequency response';

extraPicCount = 0;

if get_config(obj, 'Visible'),
    visible = 'on';
else
    visible = 'off';
end

%% Plot frequency response magnitude
h       = fvtool2(mdfilt(data), 'Visible', visible);

%% Plot frequency response phase
overlay(h, mdfilt(data), 'Analysis', 'phase', 'PhaseDisplay', ...
    'Continuous Phase', 'Visible', visible);

select(h, 1:2);
set_line(h, [], 'LineWidth', 2, 'Color', 'Black');
set_spec_mask(h, [], 'LineWidth', 1, 'Color', 'Red', 'LineStyle', '--'); 
set_xlabel(h,   'FontSize', 12);
set_ylabel(h,   'FontSize', 12);
set_title(h,    'FontSize', 14);
set_axes(h,     'FontSize', 14);


%% Set up figure captions
captions{1} = 'Freq. Resp. Magnitude';
captions{2} = 'Freq. Resp. Phase';

%% Set up a relevant file name for the printed figure
filterName = strrep(class(data), 'filter.', '');
filterName = strrep(filterName, '.', '-');

filename           = cell(1,2);
fullFilename       = cell(1,2);
filename{1}        = sprintf('%s_freqresp-magn', filterName);
fullFilename{1}    = catfile(config.Folder, filename{1});
filename{2}        = sprintf('%s_freqresp-phase', filterName);
fullFilename{2}    = catfile(config.Folder, filename{2});

%% Print figure in .svg format
hF   = get_figure_handle(h);
for j = 1:numel(filename)
    % We always print a .png version anyways (for Remark thumbnails)
    print(hF(j), '-dpng', fullFilename{j});    
    % We need to do this to ensure the same looks also when running
    % MATLAB without a display. No idea why...
    if ~usejava('Desktop'),
        set_fvtool_looks(h);
    end
    if get_config(obj, 'SVG'),
        evalc('plot2svg([fullFilename{j} ''.svg''], hF(j))');
        figNames{j} = [filename{j} '.svg'];
    else
        figNames{j} = [filename{j} '.png'];
    end
    
    %% Print also other with other drivers
    printDrivers = get_config(obj, 'PrintDrivers');
    blackBgPlots = get_config(obj, 'BlackBgPlots');
    for i = 1:numel(printDrivers)
        thisDriver      = printDrivers{i};
        thisDriverFmt   = driver2format(thisDriver);
        print(['-d' thisDriver], fullFilename{j});
        extraPicCount   = extraPicCount + 1;
        thisImgFileName = [filename{j} thisDriverFmt];
        figCap =  sprintf('%s (%s)', captions{j}, ...
            thisDriverFmt);
        extra{extraPicCount}    = thisImgFileName;
        extraCap{extraPicCount} = figCap;
        
        %% Print also black pdf version
        if blackBgPlots,
            blackbg(hF(j));
            print(['-d' thisDriver], [fullFilename{j} '-black']);
            extraPicCount = extraPicCount + 1;
            thisImgFileName = [filename{j} '-black' thisDriverFmt];
            figCap  =  sprintf('%s (black, %s)', ...
                captions{j}, thisDriverFmt);
            extra{extraPicCount}    = thisImgFileName;
            extraCap{extraPicCount} = figCap;
        end
    end
    
end
%close(hF);

% There is only one group
figNames = {figNames};
captions = {captions};
extra    = {extra};
extraCap = {extraCap};



end