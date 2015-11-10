function [maxVar, maxAbsVar] = make_explained_var_report(rep, myBSS, ics, data, verbose, verboseLabel)

import plot2svg.plot2svg;
import inkscape.svg2png;
import misc.rnd_line_format;
import misc.unique_filename;
import mperl.file.spec.catfile;
import goo.globals;
import misc.cell2char;
import rotateticklabel.rotateticklabel;

visible = globals.get.VisibleFigures;
if visible,
    visibleStr = 'on';
else
    visibleStr = 'off';
end

[sensorArray, sensorIdx] = sensor_groups(sensors(data));

% The full back-projection matrix (including non-selected components)
A = bprojmat(myBSS, true);

if verbose
    fprintf([verboseLabel, ...
        '\tGenerating backprojected variance report ...']);
end

print_title(rep, 'SPC''s backprojected variance', get_level(rep)+1);

print_paragraph(rep, [...
    'The first figure below plots the percentage of variance explained by a ' ...
    'given component at the sensor where that component is strongest '   ...
    '(red line). The black line depicts the median (across all sensors) ' ...
    'variance that may be attributed to a given component.']);

print_paragraph(rep, [...
    'The second figure plots the absolute log-scaled variances of each ' ...
    'component at the sensor where that component is strongest (red line). ' ...
    'It also displays various other summary statistics of the variances ' ...
    'produced by those components across sensors.']);

bpVarStats = meegpipe.node.bss.default_bp_var_stats;

for i = 1:numel(sensorArray),
    
    subTitle = sprintf('Sensor set #%d (%d %s sensors)', ...
        i, nb_sensors(sensorArray{i}), class(sensorArray{i}));
    print_title(rep, subTitle, get_level(rep)+2);
    
    %% Mean and maximum backprojected variance, relative to global variance
    maxVar    = nan(1, size(A,2));
    meanVar   = nan(1, size(A,2));
    maxSensor = nan(1, size(A,2));
    select(data, sensorIdx{i});
    rawVar = var(data, [], 2);
    restore_selection(data);
    for j = 1:size(A,2)
        icVar = A(sensorIdx{i},j).^2;
        [varAtMax, maxSensor(j)] = max(icVar);
        maxVar(j) = varAtMax/rawVar(maxSensor(j));
        meanVar(j) = median(icVar)/mean(rawVar); % median, not mean!!!
    end          
    maxVar = floor(100*maxVar);
    meanVar = floor(100*meanVar);
    
    % Plot the meanVar and the maxvar
    figure('Visible', visibleStr);
    plot(meanVar, '-ko', 'LineWidth', 2);
    hold on;
    plot(maxVar, '-ro', 'LineWidth', 2, 'MarkerFaceColor', 'red')
    hold on;
    stem(maxVar, ':r');

    legend('Median', 'Max');
    set(gca, 'XTick', 1:size(A,2));
    set(gca, 'XTickLabel', cell2char(labels(sensors(ics))));    
    
    hLabel = xlabel('SPC #');
    rotateticklabel(gca, 90);
    labelPos = get(hLabel, 'Position');
    yDiff = diff(get(gca, 'YLim'));
    labelPos(2) = labelPos(2)-0.05*yDiff;
    set(hLabel, 'Position', labelPos);
    ylabel('Explained variance at the sensors (%)');
    
    % Print the label of the max sensor for each component
    sensLabels = labels(sensorArray{i});
    for icItr = 1:size(A,2)
        text(icItr, maxVar(icItr), sensLabels{maxSensor(icItr)}, ...
            'Rotation', 90, ...
            'FontSize', 6);
    end

    % Print to a disk file and then to the report
    rDir = get_rootpath(rep);
    fileName = unique_filename(catfile(rDir, 'bp_variance.svg'));
    evalc('plot2svg(fileName, gcf);');
    svg2png(fileName);
    close;
    myGallery = report.gallery.new;
    caption = ['Backprojected relative variance (across all ' ...
        'channels) for each SPC'];
    
    add_figure(myGallery, fileName, caption);
    
    %% Absolute max backprojected variance
    maxAbsVar = nan(1, size(A,2));    
    maxSensor = nan(1, size(A,2));
    for j = 1:size(A,2)
        [maxAbsVar(j), maxSensor(j)] = max(10*log10(A(sensorIdx{i},j).^2));        
    end
     % Plot the maximum absolute variances
    figure('Visible', visibleStr);    
    plot(maxAbsVar, '-ro', 'LineWidth', 2, 'MarkerFaceColor', 'red');    
    legend('Max');
    % Print the label of the max sensor for each component
    sensLabels = labels(sensorArray{i});
    for icItr = 1:size(A,2)
        text(icItr, maxAbsVar(icItr), sensLabels{maxSensor(icItr)}, ...
            'Rotation', 90, ...
            'FontSize', 6);
    end       
    yLim = get(gca, 'YLim');   
    yMin = yLim(1);
    yMax = yLim(2);
 
    if ~isempty(bpVarStats)
        statNames = keys(bpVarStats);
        statVal   = zeros(size(A,2), numel(statNames));  
        pos = round(linspace(1, size(A,2), numel(statNames)+2));
        for j = 1:numel(statNames)
            for k = 1:size(A,2)
                stat = bpVarStats(statNames{j});
                statVal(k, j) = stat(A(sensorIdx{i},k));
                yMin = min(yMin, statVal(k, j));
                yMax = max(yMax, statVal(k, j));
            end
            hold on;
            plot(statVal(:,j), rnd_line_format(j));
            text(pos(1+j), statVal(pos(1+j),j), statNames{j}, ...
                'FontSize', 10, 'BackgroundColor', 'white', 'FontWeight', 'bold');
        end
        R = (yMax - yMin);
        axis([0.75 numel(maxAbsVar)+0.25 yMin-0.05*abs(R) yMax+0.05*R]);
    end
    set(gca, 'XTick', 1:size(A,2));
    set(gca, 'XTickLabel', cell2char(labels(sensors(ics))));    
    set(gca, 'XGrid', 'on');
    hLabel = xlabel('SPC #');
    rotateticklabel(gca, 90);
    labelPos = get(hLabel, 'Position');
    yDiff = diff(get(gca, 'YLim'));
    labelPos(2) = labelPos(2)-0.05*yDiff;
    set(hLabel, 'Position', labelPos);
    ylabel('log-variance statistis (dB)');
    
     % Print to a disk file and then to the report
    rDir = get_rootpath(rep);
    fileName = unique_filename(catfile(rDir, 'bp_abs_variance.svg'));
    evalc('plot2svg(fileName, gcf);');
    svg2png(fileName);
    close;    
    caption = ['Backprojected absolute log-variance statistics (across all ' ...
        'channels) for each SPC'];
    
    add_figure(myGallery, fileName, caption);
 
    fprintf(rep, myGallery);  
    
end

if verbose,
    fprintf('[done]\n\n');
end

end
