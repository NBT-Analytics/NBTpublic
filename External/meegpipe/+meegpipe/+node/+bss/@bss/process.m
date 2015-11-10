function [data, dataNew] = process(obj, data, varargin)

import misc.eta;
import goo.globals;
import meegpipe.node.bss.bss;

verbose          = is_verbose(obj);
verboseLabel     = get_verbose_label(obj);
origVerboseLabel = globals.get.VerboseLabel;
globals.set('VerboseLabel', verboseLabel);

dataNew = [];

% Configuration options
myRegrFilter = get_config(obj, 'RegrFilter');
myPCA        = get_config(obj, 'PCA');
myBSS        = get_config(obj, 'BSS');
myCrit       = get_config(obj, 'Criterion');
reject       = get_config(obj, 'Reject');
myFilt       = get_config(obj, 'Filter');

sr = data.SamplingRate;
if isa(myFilt, 'function_handle'),
    myFilt = myFilt(sr);
end
if ~isempty(myFilt),
    % Some filters (e.g. LASIP) take a long while to compute. It is a good
    % idea to activate the filter verbose feature.
    myFilt = set_verbose(myFilt, verbose);
end

% Random seed for BSS algorithms that require it
seed = get_runtime(obj, 'bss', 'seed');
if iscell(seed), seed = eval(seed{1}); end
init = get_runtime(obj, 'bss', 'init');
if iscell(init), init = eval(init{1}); end

myBSS  = set_seed(myBSS, seed);
myBSS  = set_init(myBSS, init);
set_runtime(obj, 'bss', 'seed', get_seed(myBSS));
set_runtime(obj, 'bss', 'init', get_init(myBSS, nb_component(myPCA)));

% Perform a global PCA on the whole dataset
center(data);
myPCA = learn(myPCA, data);
pcs   = proj(myPCA, subset(data));

if verbose,
    fprintf( [verboseLabel 'Learning %s basis ...\n\n'], class(myBSS));
end

myBSS = learn(myBSS, pcs);
ics   = proj(myBSS, pcs);

% Give a proper name to the ics. This is necessary to be able to predict
% the name of the output file when reject=[]. See method
% get_output_filename()
BSSName = get_name(myBSS);
BSSName = regexprep(BSSName, '.+\.([^.]+$)', '$1');
set_name(ics, [get_name(data) '_' BSSName, ' activations']);
add_event(ics, get_event(data));

[~, myBSS] = cascade(myPCA, myBSS);

warning('off', 'MATLAB:RandStream:ActivatingLegacyGenerators');
rand('state',  seed); %#ok<RAND>
randn('state', seed); %#ok<RAND>
warning('on', 'MATLAB:RandStream:ActivatingLegacyGenerators');
[selected, featVal, rankVal, myCrit]  = select(myCrit, myBSS, ics, data);

if verbose,
    if isempty(reject)
        str = 'produced';
    elseif reject,
        str = 'rejected';
    else
        str = 'accepted';
    end
    fprintf([verboseLabel '%d components will be %s ...\n\n'], ...
        numel(find(selected)), str);         
end

% For convenience, we will sort everything in decreasing rank value
% This also means renaming the ICs so that IC #1 corresponds to the highest
% ranked component and so on.
% rankVal can have multiple columns (multiple features!)
[~, sortedIdx] = sort(rankVal(:,1), 'descend');

featVal = featVal(sortedIdx, :);
write_training_data_to_disk(obj, featVal);

myBSS  = reorder_component(myBSS, sortedIdx);
myCrit = reorder(myCrit, sortedIdx);

ics   = select(ics, sortedIdx);
ics   = set_sensors(ics, sensors.dummy(size(ics,1)));

selected = selected(sortedIdx);

% Has the user made a manual selection?
% If the user wants the manual selection of components to be
% ignored she can do either of three things:
%
% - Delete the .ini file
% - Delete the "selection" parameter in section bss
% - Set selection=NaN
userSel = get_runtime(obj, 'bss', 'selection', true);
if iscell(userSel), 
    userSel = cellfun(@(x) eval(x), userSel);
end
autoSel = find(selected);

% If there is training data available, use it!
selectedTrain = predict_selection(obj, featVal);
icSelTrain = find(selectedTrain);
if ~isempty(icSelTrain),
    if verbose
        fprintf([verboseLabel 'Using training-based selection (%s) ...\n\n'], ...
            misc.any2str(icSelTrain)); %#ok<*FNDSB>
    end
    autoSel = icSelTrain;
end

if isempty(userSel) || ~all(isnan(userSel)) && ~isempty(setxor(userSel, autoSel))
    userSel = intersect(userSel, 1:size(ics,1));
    if verbose,
        fprintf([ get_verbose_label(obj) ...
            'User selection overrides automatic selection ' ...
            '(%d selected)...\n\n'], numel(userSel));
    end
    icSel = userSel;
    isAutoSel = false;
else
    icSel = autoSel;
    isAutoSel = true;
end

myBSS = select(myBSS, icSel);

if verbose,    
    fprintf( [verboseLabel, 'Denoising ...\n\n']);   
end

% Write selection .ini file
selArg  = num2cell(icSel);
set_runtime(obj, 'bss', 'selection', selArg{:});

make_pca_report(obj, myPCA);
if do_reporting(obj)
   % Wee need to copy the ics or otherwise some of the reports may modify
   % them (e.g. by back-projecting them to the sensors).
   bssRep = make_bss_report(obj, myBSS, copy(ics), data, icSel);    
end
make_criterion_report(obj, myCrit, [], icSel, isAutoSel);

% This may also add information regarding the features to the node report.
% If the bss node does not contain any feature extrators, then this does
% nothing.
extract_bss_features(obj, myBSS, ics, data, icSel);

if isempty(icSel),
    
    if isempty(reject),
        error('No components were selected! Cannot output an empty set.'); 
    elseif ~reject,        
        data(:,:) = 0;
    end    
    
elseif numel(icSel) == size(ics, 1),
    
    if isempty(reject), 
        % So that if Save=true the file name will have the proper name
        set_name(ics, get_name(data));
        data = ics;
    elseif reject,
        data(:,:) = 0;
    end
 
else  
    % Not all, but some components are selected
    
    % Filter the components, if the user provided a filter
    if ~isempty(myFilt),  
        select(ics, icSel);    
        if do_reporting(obj),            
            icsIn = copy(ics);
        end
        if verbose,
            fprintf([verboseLabel 'Filtering SPCs using %s ...\n\n'], ...
                class(myFilt));
        end 
        ics = filtfilt(myFilt, ics);
        if do_reporting(obj),           
            bss.make_filtering_report(bssRep, icsIn, ics);
        end  
        restore_selection(ics);
    end 

    if isempty(reject)
        % An empty Reject property means: do not reject or accept
        % components, simply retrieve the components in the output of the
        % node. 
        select(ics, icSel);
        set_name(ics, get_name(data));
        data = ics;   
        if verbose,
           fprintf([verboseLabel 'Reject=[], so I will produce %d ' ...
               'BSS components as output ...\n\n'], size(ics, 1));
        end
        
    elseif reject,
        if ~isempty(myRegrFilter),
            % We need to keep a backup copy of the original ics.
            select(ics, icSel);
            rejectedICs = subset(ics);
            restore_selection(ics);
        end
        noise = bproj(myBSS, ics);
        data = data - noise;
    else
        signal = bproj(myBSS, ics);
        data = assign_values(data, signal);
    end
    
    % Remove residual noise using a regression filter
    if ~isempty(reject) && reject && ~isempty(myRegrFilter),       
        filter(myRegrFilter, data, rejectedICs);
    end
    
end

if verbose,
    globals.set('VerboseLabel', origVerboseLabel);
end


end



