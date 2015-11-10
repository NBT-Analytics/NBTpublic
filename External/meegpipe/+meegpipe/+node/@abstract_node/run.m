function [data, dataNew] = run(obj, varargin)

import oge.has_oge;
import oge.has_condor;
import goo.pkgisa;
import misc.exception2str;
import mperl.file.spec.rel2abs;

dataNew = [];

if nargin < 2,
    data = [];
    return;
end

verboseLabel = get_verbose_label(obj);

% Common mistake: user passes multiple files/datasets as a cell array
if nargin == 2 && iscell(varargin{1}) && numel(varargin{1}) == 1,
    varargin = varargin{1};
end

% Another common mistake: user passes an empty cell
if nargin == 2 && isempty(varargin{1})
    error('You need to provide at least one data file to be processed!')
end

%% Take care of multiple input datasets using recursion
if numel(varargin) > 1,
    
    data = cell(1, numel(varargin));
    if isempty(get_parent(obj)) && obj.Parallelize && ...
            ((has_condor && strcmpi(obj.Queue, 'condor')) || ...
            (has_oge && ~strcmpi(obj.Queue, 'condor')))
        for i = 1:numel(varargin)
            %thisObj = clone(obj);
            thisObj = obj; % Will it work?
            data{i} = run_oge(thisObj, varargin{i});
        end
        
    else
        
        dataNew = cell(1, numel(varargin));
        for i = 1:numel(varargin)
             %thisObj = clone(obj);
            thisObj = obj; % Will it work?          
            [data{i}, dataNew{i}] = run(thisObj, varargin{i});
        end
        
    end
    
    return;
end

%% Single dataset case
data = varargin{1};

set_tinit(obj, tic);

% Select data to be processed
if pkgisa(data, 'physioset.physioset') && ~isempty(obj.DataSelector),
    
    [oRows, oCols] = size(data);
    
    
    [~, emptySel] = select(obj.DataSelector, data);
    if emptySel,        
        warning('abstract_node:EmptySelection', ...
            ['The DataSelector of node ''%s'' selects an empty set of data: ' ...
             'skipping node'], get_name(obj));
         return;
    end

    if is_verbose(obj),
        fprintf([verboseLabel 'DataSelector selected %d/%d channels: %s...\n\n'], ...
            size(data,1), oRows, misc.any2str(dim_selection(data), 50));
    end
    if is_verbose(obj),
        dataL = size(data,2)/data.SamplingRate;
        fprintf([verboseLabel 'DataSelector selected %d (%d%%) seconds, '  ...
        'spanning from second %.2f to second %.2f ...\n\n'], ...
            ceil(dataL), round(100*size(data,2)/oCols), ...
            get_sampling_time(data, 1), get_sampling_time(data, size(data,2)));
    end
    
end

initialize(obj, data);

try
    
    data = preprocess(obj, data);
    
    
    % This is implemented by final node classes
    
    if do_reporting(obj) && ~isempty(get_io_report(obj)) && ~ischar(data),
        
        dataIn  = copy(data);
        [data, dataNew] = process(obj, data);
        
    else
        
        dataIn  = data;
        [data, dataNew] = process(obj, data);
        
    end
    
    
    % clear persistent variables in misc.eta
    if is_verbose(obj), clear +misc/eta; end
    
    data = postprocess(obj, data);
    
    % i/o report
    if do_reporting(obj) && ~ischar(dataIn),
        io_report(obj, dataIn, data);
    end
    
    %% save processing history
    if ~isa(obj, 'meegpipe.node.pipeline.pipeline'),
        if ischar(dataIn),
            if exist(dataIn, 'file'),
                inStr = rel2abs(dataIn);
            else
                inStr = dataIn;
            end
            add_processing_history(data, inStr);
        end
        if iscell(data),
            for i = 1:numel(data),
                add_processing_history(data{i}, clone(obj));
            end
        else
            add_processing_history(data, clone(obj));
        end
        
    end
    
    % data is always a physioset, but varargin{1} may not be!
    % some nodes produce a new physioset object (e.g. copy, subset). In those
    % cases you don't want to restore_selection
    if pkgisa(varargin{1}, 'physioset.physioset') && ...
            ~isempty(obj.DataSelector) && ...
            strcmp(get_datafile(data), get_datafile(varargin{1})),
        clear_selection(data);
        % The problem with restore_selection is that we don't know how many
        % cascaded selections were peformed at the input of the node. Using
        % clear_selection will work as expected more often.
        %restore_selection(data);
    end
    
    % Important: output argument is necessary. Otherwise we would break the
    % bss node when Reject=[] because in that case the output physioset is
    % not the same as the input physioset. Other nodes may also have the
    % same behavior.
    data = finalize(obj, data);
    
catch ME
    % This is useful when running through OGE to find out what happened
    if obj.Parallelize && ~usejava('Desktop'),
        exception2str(ME);
    end
    % Necessary to avoid inconsistent global states
    restore_global_state(obj);
    rethrow(ME);
end

end