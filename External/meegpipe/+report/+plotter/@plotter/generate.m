function repObj = generate(repObj, obj, varargin)


import exceptions.*;
import goo.globals;

generate@report.generic.generic(repObj);

level = get_level(repObj) + 1;

%% Use recursion to take care of multiple plotters
plotterObj  = get_config(repObj, 'Plotter');

if numel(plotterObj) > 1    
    
    for i = 1:numel(plotterObj),
        
        repObjClone = clone(repObj);
        set_config(repObjClone, 'Plotter', plotterObj{i});        
        set_level(repObjClone,  level);
        set_title(repObjClone,  ['Plotter ' get_name(plotterObj{i})]);        
        embed(repObjClone, repObj);
        print_title(repObjClone, get_title(repObjClone), level);
        generate(repObjClone, obj, varargin{:}); 
         
    end    
    
    return;
    
else    
    
    plotterObj = plotterObj{1};  
    
end

fid   = get_fid(repObj);
rPath = get_rootpath(repObj);


%% Info about the plotter
% Note: even if the plotter does not implement the goo.reportable
% interface, it must implement method struct() (abstract_plotter provides a
% default implementation of such method), which should be enough for
% providing a rough report on the plotter characteristics
objectReport = report.object.object(plotterObj, ...
    'Parent',           get_filename(repObj), ...
    'RootPath',         rPath, ...
    'Title',            ['Plotter ' get_name(plotterObj)]);
initialize(objectReport);
generate(objectReport);
plotterClass = class(plotterObj);
[~, repName] = fileparts(get_filename(objectReport));
fprintf(fid, 'Plots generated with plotter [%s][%s]\n', ...
    plotterClass, repName);
fprintf(fid, '[%s]: [[Ref: %s]]\n\n', repName, [repName '.txt']);


%% Generate figures
%set_config(repObj, 'Plotter', plotterObj);
origVerbose = globals.get.Verbose;
globals.set('Verbose', false);

pset.session.subsession(get_rootpath(repObj));
[h, captions,  groups, extra, extraCap] = plot(plotterObj, obj, ...
    varargin{:});
pset.session.clear_subsession;

globals.set('Verbose', origVerbose);

% Plotting may fail for whatever reasons
isEmpty = cellfun(@(x, y) isempty(x) && isempty(y), h, extra); 
h(isEmpty)          = [];
captions(isEmpty)   = [];
groups(isEmpty)     = [];
extra(isEmpty)      = [];
extraCap(isEmpty)   = [];

%% Generate a Remark gallery for each group
printGalleryTitle = get_config(repObj, 'PrintGalleryTitle');
for i = 1:numel(groups),
    galObj = get_config(repObj, 'Gallery');
    if printGalleryTitle,
        galObj = set_title(galObj, groups{i});
    else
        galObj = set_title(galObj, '');
    end
    galObj = set_level(galObj, get_level(repObj)+2);
    
    galObj = add_figure(galObj, h{i}, captions{i});
    
    if get_config(repObj, 'ExtraLinks'),
        % Do not print thumbnails for extra figures of this group
        galObj = add_figure(galObj, extra{i}, extraCap{i}, false);
    end
    
    fprintf(fid, galObj);
end

end