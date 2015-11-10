function generate_spectra_images(obj, rep, plotterObj, data)

import misc.eta;
import meegpipe.node.globals;
import report.gallery.gallery;
import misc.unique_filename;
import plot2svg.plot2svg;
import mperl.join;
import datahash.DataHash;
import meegpipe.node.spectra.eeg_bands;

verbose = goo.globals.get.Verbose;

roi     = get_config(obj, 'ROI');

boi     = get_config(plotterObj, 'BOI');

if isempty(boi),
    boi     = subset(roi, keys(eeg_bands));
end

myGallery = gallery;

tinit     = tic;
channels  = obj.SpectraSensors;
set_config(plotterObj, 'Visible', false);

channels2Plot = get_config(obj, 'Channels2Plot');
channelSets   = obj.ChannelSets;

if ischar(channels2Plot),
    channels2Plot = {channels2Plot};
end

mustPlot = false(1, numel(channels));

if isempty(channels2Plot) && numel(channels) > 5
    mustPlot(round(linspace(1, numel(channels), 5))) = true;
elseif isempty(channels2Plot)
    mustPlot(1:end) = true;
else
    if iscell(channels2Plot),
        % Evaluate any function_handle that may be there
        for i = 1:numel(channels2Plot),
           if isa(channels2Plot{i}, 'function_handle'),
               channels2Plot{i} = channels2Plot{i}(data);
           end
        end
        % Ensure that all channel sets are strings (and not cell arrays of
        % strings)
        channels2PlotChar = cellfun( @(x) datahash.DataHash(x), ...
            channels2Plot, 'UniformOutput', false);
        channelSetsChar   = cellfun( @(x) datahash.DataHash(x), ...
            channelSets, 'UniformOutput', false);
        mustPlot = ismember(channelSetsChar, channels2PlotChar);        
    elseif isnumeric(channels2Plot),        
        mustPlot(intersect(channels2Plot, 1:numel(mustPlot))) = true;
    else
        error('This can''t be');
    end
end

for i = 1:numel(channels)
    
    if ~mustPlot(i) || isempty(obj.Spectra{i}), continue; end
    
    chanLabels = join(', ', labels(obj.SpectraSensors{i}));
    caption = sprintf('Spectra for channel set #%d (%s)', i, chanLabels);
    
    myPlotter = clone(plotterObj);
    
    set_config(myPlotter, 'BOI', boi);
    
    myPlotter = plot(myPlotter, obj.Spectra{i}); %#ok<NASGU>
    
    thisName    = DataHash(rand(1,100));
    thisName    = thisName(1:8);
    fileName    = print_image(rep, ['spectra-chanset-' num2str(i) ...
        '-' thisName]);
    
    myGallery   = add_figure(myGallery, fileName, caption);
    
    if verbose,
        eta(tinit, numel(channels), i);
    end
    
end

fprintf(rep, myGallery);

end
