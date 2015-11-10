classdef physioset < ...
        pset.mmappset & ...
        goo.printable_handle & ...
        goo.verbose_handle
    % physioset - Data structure for physiological datasets
    %
    % See: <a href="matlab:misc.md_help('physioset.physioset')">misc.md_help(''physioset.physioset'')</a>
    
    
    properties (GetAccess = private, SetAccess = private)
        
        History;                 % Processing history
        PointSet;                % A pset.pset object
        Offset;                  % For methods remove_offset, restore_offset
        EqWeights;               % Equalization weights
        EqWeightsOrig;           % The inverse of this transforms the data to its original scales
        PhysDimPrefixOrig;       % The original (before equalization) physical dimensions prefix
        BadChan;                 % Indicates whether a channel is bad
        BadSample;               % Indicates whether a sample is bad
        Event;                   % One or more pset.event objects
        Sensors;                 % A sensors.physiology object
        SamplingTime;            % Sampling instants relative to StartTime\
        % Method configuration options
        Config = physioset.default_method_config;
        ProcHistory = {};
        TimeOrig;
        SensorsHistory = {};          % To keep track of proj/bproj
        RerefMatrix;
        MetaMapper;
        EventMapper;
        
    end
    
    properties (Access = private, Dependent)
        
        NbDims;
        NbPoints;
        DimSelection;
        PntSelection;
        DimMap;
        DimInvMap;
        StartTime;
        StartDate;
        
    end
    
    % Get methods for the dependent properties
    methods
        
        function val    = get.NbDims(obj)
            val = obj.PointSet.NbDims;
        end
        
        function val    = get.NbPoints(obj)
            val = obj.PointSet.NbPoints;
        end
        
        function val    = get.DimSelection(obj)
            val = obj.PointSet.DimSelection;
        end
        
        function val    = get.PntSelection(obj)
            val = obj.PointSet.PntSelection;
        end
        
        function val    = get.DimMap(obj)
            val = obj.PointSet.DimMap;
        end
        
        function val    = get.DimInvMap(obj)
            val = obj.PointSet.DimInvMap;
        end
        
        function val    = get.StartTime(obj)
            val = datestr(obj.TimeOrig, pset.globals.get.TimeFormat);
        end
        
        function val    = get.StartDate(obj)
            val = datestr(obj.TimeOrig, pset.globals.get.DateFormat);
        end
        
        
    end
    
    methods (Access = private)
        
        copy_everything(x, y); % from x to y
        
        check(obj);
        
        % Memory mapping (pset.pset forwarded methods)
        varargout = get_chunk(obj, varargin);
        
        varargout = get_map_index(obj, varargin);
        
        destroy_mmemmapfile(obj, varargin);
        
        % For reporting
        myTable = parse_disp(obj);
        
        name = default_name(obj);
        
        % Gets equalization props. taking into account selections
        [weights, origWeights, physdim] = get_equalization(obj);
        
        % Add/Delete events using a GUI
        add_event_gui(obj);
        delete_event_gui(obj);
        
        % Add meta-data info to the physioset
        function apply_meta_mapper(obj)
            
            if isempty(obj.MetaMapper), return; end
            
            meta = obj.MetaMapper(obj);
            if isempty(meta), return; end
            
            fNames = fieldnames(meta);
            for i = 1:numel(fNames),
                set_meta(obj, fNames{i}, meta.(fNames{i}));
            end
            
        end
        
        % Add events to the physioset
        function apply_event_mapper(obj)
            
            if isempty(obj.EventMapper), return; end
            
            evs = obj.EventMapper(obj);
            if isempty(evs), return; end
            
            add_event(obj, evs);
            
        end
        
    end
    
    methods (Access = private, Static)
        
        function list = valid_events()
            
            list = {...
                'AddEventGui', ... % Add events using EEGLAB GUI
                'DelEventGui' ... % Delete events using EEGLAB's GUI
                };
            
        end
        
    end
    
    % Handle events (typically triggered by GUI components)
    methods (Static)
        
        function handle_event(src, eventData)
            
            feval(['physioset.physioset.handle_' eventData.EventName], ...
                src, eventData);
            
        end
        
        function handle_AddEventGui(src, eventData)
            
            this = get_responder(src);
            add_event(this, eventData.EventArray);
            
        end
        
        function handle_DelEventGui(src, eventData)
            
            this = get_responder(src);
            delete_event(this, eventData.DeleteFlag);
            
        end
        
    end
    
    
    
    properties (SetAccess = private)
        
        SamplingRate;       % Sampling rate in Hz
        
    end
    
    % Consistency checks (Set methods)
    methods
        
        
        function set.Event(obj, v)
            import exceptions.*;
            
            if ~all(isempty(v)) && ~isa(v, 'physioset.event.event'),
                throw(InvalidPropValue('Event', ...
                    'Must be (an array of) physioset.event.event object(s)'));
            end
            
            % Do not sort the events here. Method add_event takes care of
            % that already and events are sorted also in the constructor
            obj.Event = v;

        end
        
        function set.Sensors(obj, v)
            import exceptions.*;
            
            if isempty(v),
                obj.Sensors = [];
                return;
            end
            
            if ~isa(v, 'sensors.sensors'),
                throw(InvalidPropValue('Sensors', ...
                    'Must be of class sensors.sensors'));
            end
            obj.Sensors = v;
        end
        
        function set.SamplingRate(obj, v)
            
            import misc.isnatural;
            import exceptions.*;
            
            if numel(v) ~= 1,
                throw(InvalidPropValue('SamplingRate', ...
                    'Must be a scalar'));
            end
            obj.SamplingRate = v;
            
        end
        
        function set.StartDate(obj, v)
            import exceptions.*;
            
            if ~isempty(v) && ~ischar(v),
                throw(InvalidPropValue('Date', ...
                    'Must be a string'));
            end
            
            obj.StartDate = v;
        end
        
        function set.StartTime(obj, v)
            import exceptions.*;
            
            if ~isempty(v) && ~ischar(v),
                throw(InvalidPropValue('Time', ...
                    'Must be a string'));
            end
            
            obj.StartTime = v;
        end
        
        function set.SamplingTime(obj, v)
            import misc.isnatural;
            import exceptions.*;
            import goo.from_constructor;
            
            % Let's allow negative sampling times (e.g. Fieldtrip uses
            % them when defining epochs/trials). 
            obj.SamplingTime = v;
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        function set.TimeOrig(obj, v)
            import exceptions.InvalidPropValue;
            
            if numel(v) ~= 1 || ~isa(v, 'double') || isnan(v) || isinf(v),
                dims = regexprep(num2str(size(v)), '\s+', 'x');
                if isnan(v),
                    c = 'NaN';
                elseif isinf(v),
                    c = 'Inf';
                else
                    c = class(v);
                end
                
                throw(InvalidPropValue('TimeOrig', ...
                    sprintf(['Must be a datenum scalar but is a %s of ' ...
                    'dimensions %s'], c, dims)));
            end
            obj.TimeOrig = v;
            
        end
        
    end
    
    % goo.printable_handle interface
    methods
        
        count = fprintf(fid, obj);
        
    end
    
    % pset.mmappset interface
    methods
        
        y   = subsref(obj, s);
        
        obj = subsasgn(obj, s, b);
        
        function nDims    = nb_dim(obj)
            nDims = nb_dim(obj.PointSet);
        end
        
        function nPnts    = nb_pnt(obj)
            nPnts = nb_pnt(obj.PointSet);
        end
        
        function filename = get_datafile(varargin)
            
            filename = cell(1, nargin);
            for i = 1:nargin,
                filename{i} = get_datafile(varargin{i}.PointSet);
            end
            if numel(filename) == 1,
                filename = filename{1};
            end
        end
        
        function filename = get_hdrfile(obj)
            filename = get_hdrfile(obj.PointSet);
        end
        
        newObj = copy(obj, varargin);
        
        obj    = move(obj, varargin);
        
        newObj = subset(obj, varargin);
        
        obj    = merge(varargin);
        
        function obj = concatenate(varargin)
            obj = merge(varargin{:});
        end
        
        save(obj, filename);
        
        function obj = delay_embed(obj, varargin)
            obj.PointSet = delay_embed(obj.PointSet, varargin{:});
            obj.Sensors  = sensors.dummy(obj.PointSet.NbDims);
        end
        
        function obj = loadobj(obj)
            obj.PointSet = loadobj(obj.PointSet);
            
            % We clear the processing history becuase it crates a lot of
            % troubles. Fix this!
            clear_processing_history(obj);
        end
        
        function obj = saveobj(obj)
            obj.PointSet = saveobj(obj.PointSet);
        end        

        function obj = sphere(obj, varargin)
            obj = sphere(obj.PointSet, varargin{:});
        end
        
        function obj = reref(obj, W)
            if isa(W, 'function_handle'),
                W = W(obj);
            end
            obj.PointSet = W*obj.PointSet;          
            obj.RerefMatrix = W;
        end
        
        function obj = undo_reref(obj, refChanIdx)
            % refChanIdx is the channel that was originally used as ref
            if isempty(obj.RerefMatrix),
                warning('physioset:MissingRerefMatrix', ...
                    ['No re-referencing has been applied to this ' ...
                    'physioset: nothing done']);
                return;
            end
            
            M = obj.RerefMatrix;
            
            idx = setdiff(1:size(M,1), refChanIdx);
            % No need of creating a copy of the pointset because mtimes
            % creates a copy internally
            tmpPset = pinv(M(:, idx))*obj.PointSet;
            for i = 1:numel(idx)
                obj.PointSet(idx(i),:) = tmpPset(i,:);
            end
            obj.PointSet(refChanIdx, :) = 0;
            obj.RerefMatrix = [];
            
        end
        
        function obj = smooth_transitions(obj, evArray, varargin)
            obj.PointSet = ...
                smooth_transitions(obj.PointSet, evArray, varargin{:});
        end
        
        % Selection related methods
        function obj = select(obj, varargin)
            
            if nargin < 2, return; end
            
            select(obj.PointSet, varargin{:});
            
        end
        
        function obj = invert_selection(obj, varargin)
            invert_selection(obj.PointSet, varargin{:});
        end
        
        function obj = clear_selection(obj)
            clear_selection(obj.PointSet);
        end
        
        function obj = restore_selection(obj)
            restore_selection(obj.PointSet);
        end
        
        function obj = backup_selection(obj)
            backup_selection(obj.PointSet);
        end
        
        function bool = has_selection(obj)
            bool = has_selection(obj.PointSet);
        end
        
        function bool = has_pnt_selection(obj)
            bool = has_pnt_selection(obj.PointSet);
        end
        
        function bool = has_dim_selection(obj)
            bool = has_dim_selection(obj.PointSet);
        end
        
        function dimSel = dim_selection(obj)
            dimSel = dim_selection(obj.PointSet);
        end        
    
        function dimSel = relative_dim_selection(obj)
            dimSel = relative_dim_selection(obj.PointSet);
        end
        
        function pntSel = pnt_selection(obj)
            pntSel = pnt_selection(obj.PointSet);
        end
        
        function pntSel = relative_pnt_selection(obj)
            pntSel = relative_pnt_selection(obj.PointSet);
        end
        
        function obj = set_dim_selection(obj, sel)
            set_dim_selection(obj.PointSet, sel);
        end
        
        function obj = set_pnt_selection(obj, sel)
            set_pnt_selection(obj.PointSet, sel);
        end
        
        ev = get_pnt_selection_events(obj, evTemplate);
        
        % Projection related methods
        function obj = project(obj, varargin)
            obj = project(obj.PointSet, varargin{:});
        end
        
        function obj = clear_projection(obj)
            clear_projection(obj);
        end
        
        function obj = restore_projection(obj)
            restore_projection(obj.PointSet);
        end
        
        function obj = backup_projection(obj)
            backup_projection(obj.PointSet);
        end
        
        obj = copy_sensors_history(obj, otherObj);
        
        obj = restore_sensors(obj, projOperator);
        
        obj = backup_sensors(obj, projOperator);
        
        sensObj = retrieve_sensors_history(obj, idx);
        
        function bool = is_temporary(obj)
            bool = is_temporary(obj.PointSet);
        end
        
    end
    
    % Const public methods
    methods
        
        time               = get_time_origin(obj);
        
        args               = construction_args(obj, type);
        
        bool               = is_bad_channel(obj, idx);
        
        bool               = is_bad_sample(obj, idx);
        
        sensObj            = sensors(obj);
        
        % These two methods are identical, sampling_time is kept for
        % backward compatibility
        [sTime, absTime]   = sampling_time(obj);
        [sTime, absTime]   = get_sampling_time(obj, idx);
        
        function absTime   = get_abs_sampling_time(obj, idx)
            [~, absTime] = get_sampling_time(obj, idx);
        end
        
        value              = get_method_config(obj, varargin);
        
        nbEvents           = nb_event(obj);
        
        [evArray, rawIdx]  = get_event(obj, idx);
        
        history            = get_processing_history(obj, idx);
        
        function obj = clear_processing_history(obj)
            obj.ProcHistory = [];
        end
        
        h = plot(obj, varargin);
        
        % For reporting/plotting purposes
        
        [c, cClass, cType] = default_channel_groups(data, varargin);
        
        windows = default_window_selection(data, varargin);
        
        [y, evNew, samplIdx, evOrig, trialEv] = epoch_get(x, trialEv, base);
        
        % Add an event listener
        obj = add_event_listener(obj, evGen, type);
        
        
    end
    
    % Mutable public methods
    methods
        
        [obj, evIdx]    = add_boundary_events(obj, evClass);            
        
        obj             = set_sensors(obj, index);
        
        obj             = set_bad_channel(obj, index);
        
        [obj, bndryEvIdx] = set_bad_sample(obj, index);
        
        obj             = clear_bad_channel(obj, index);
        
        obj             = clear_bad_sample(obj, index);
        
        obj             = select_good_data(data);
        
        [obj, idx]      = add_event(obj, ev);
        
        obj             = delete_event(obj, idx);
        
        obj             = set_method_config(obj, varargin);
        
        % node is a pset.node.node object or
        obj             = add_processing_history(obj, node);
        
        obj             = equalize(obj, varargin);
        
    end
    
    % MATLAB built-in numeric methods (pset.pset forwarded)
    methods
        
        function obj        = circshift(obj, ~, varargin)
            error('Not implemented yet!');
        end
        
        function obj        = conj(obj, varargin)
            obj.PointSet = conj(obj.PointSet, varargin{:});
        end
        
        function C          = cov(obj, varargin)
            C = cov(obj.PointSet, varargin{:});
        end
        
        function obj        = ctranspose(obj, varargin)
            obj.PointSet = ctranspose(obj.PointSet, varargin{:});
        end
        
        function y          = double(obj, varargin)
            y = double(obj.PointSet, varargin{:});
        end
        
        function y          = end(obj, k, ~)
            y = size(obj.PointSet, k);
        end
        
        function obj        = flipud(obj, varargin)
            obj.PointSet = flipud(obj.PointSet, varargin{:});
        end
        
        function bool       = isfloat(obj)
            bool = isfloat(obj.PointSet);
        end
        
        function bool       = isnumeric(obj)
            bool = isnumeric(obj.PointSet);
        end
        
        function bool       = issparse(obj)
            bool = issparse(obj.PointSet);
        end
        
        function val        = length(obj)
            val = length(obj.PointSet);
        end
        
        function bool       = logical(obj)
            bool = logical(obj.PointSet);
        end
        
        function val        = mean(obj, varargin)
            val = mean(obj.PointSet, varargin{:});
        end
        
        function obj        = abs(obj)
            obj.PointSet = abs(obj.PointSet);
        end
        
        function y   = sum(obj, varargin)
            y = sum(obj.PointSet, varargin{:});
        end
        
        function obj = center(obj, varargin)
            verbOrig = is_verbose(obj.PointSet);
            set_verbose(obj.PointSet, is_verbose(obj));
            center(obj.PointSet, varargin{:});
            set_verbose(obj.PointSet, verbOrig);
            
        end
        
        function obj        = minus(varargin)
            
            obj = [];
            for i = 1:nargin
                if isa(varargin{i}, 'physioset.physioset'),
                    if isempty(obj),
                        obj = varargin{i};
                    end
                    varargin{i} = varargin{i}.PointSet;
                end
            end
            obj.PointSet = minus(varargin{:});
        end
        
        function obj        = mrdivide(varargin)
            for i = 1:nargin
                if isa(varargin{i}, 'physioset.physioset'),
                    varargin{i} = varargin{i}.PointSet;
                end
            end
            obj = mrdivide(varargin{:});
        end
        
        function obj        = mtimes(varargin)
            obj = [];
            for i = 1:nargin
                if isa(varargin{i}, 'physioset.physioset'),
                    if isempty(obj),
                        obj = varargin{i};
                    end
                    varargin{i} = varargin{i}.PointSet;
                end
            end
            
            res = mtimes(varargin{:});
            
            if isa(res, 'pset.mmappset'),
                obj.PointSet = res;
                % Important: do not clear the selections of obj. See
                % pset.pset.mtimes() to understand why it is ok like it is.
                obj.Sensors             = sensors.dummy(obj.NbDims);
                obj.EqWeights           = [];
                obj.EqWeightsOrig       = [];
                obj.PhysDimPrefixOrig   = [];
                obj.BadChan             = false(1, obj.NbDims);
                obj.RerefMatrix         = [];
                
            else
                obj = res;
            end
            
        end
        
        function val        = ndims(obj, varargin)
            val = ndims(obj.PointSet, varargin{:});
        end
        
        function obj        = assign_values(obj, otherObj)
            
            obj.PointSet = assign_values(obj.PointSet, otherObj.PointSet);
            
        end
        
        function obj        = plus(varargin)
            obj = [];
            for i = 1:nargin
                if isa(varargin{i}, 'physioset.physioset'),
                    if isempty(obj),
                        obj = varargin{i};
                    end
                    varargin{i} = varargin{i}.PointSet;
                end
            end
            obj.PointSet = plus(varargin{:});
        end
        
        function obj        = power(obj, varargin)
            obj.PointSet = power(obj.PointSet, varargin{:});
        end
        
        function obj        = rdivide(varargin)
            obj = [];
            for i = 1:nargin
                if isa(varargin{i}, 'physioset.physioset'),
                    if isempty(obj),
                        obj = varargin{i};
                    end
                    varargin{i} = varargin{i}.PointSet;
                end
            end
            obj.PointSet = rdivide(varargin{:});
        end
        
        function obj        = repmat(obj, varargin)
            obj.PointSet = repmat(obj.PointSet, varargin{:});
        end
        
        function obj        = reshape(obj, varargin)
            obj = reshape(obj.PointSet, varargin{:});
        end
        
        function obj        = sign(obj, varargin)
            obj.PointSet = sign(obj.PointSet, varargin{:});
        end
        
        function val        = single(obj, varargin)
            val = single(obj.PointSet, varargin{:});
        end
        
        function varargout  = size(obj, varargin)
            if nargout == 0,
                varargout{1} = size(obj.PointSet, varargin{:});
                return;
            elseif nargout == 1,
                varargout{1} = size(obj.PointSet, varargin{:});
            else
                varargout = cell(1, nargout);
                for i = 1:nargout,
                    varargout{i} = size(obj.PointSet, i);
                end
            end
        end        
    
        function obj        = times(varargin)
            obj = [];
            for i = 1:nargin
                if isa(varargin{i}, 'physioset.physioset'),
                    if isempty(obj),
                        obj = varargin{i};
                    end
                    varargin{i} = varargin{i}.PointSet;
                end
            end
            obj.PointSet = times(varargin{:});
        end
        
        function obj        = transpose(obj, varargin)
            obj.PointSet = transpose(obj.PointSet, varargin{:});
        end
        
        function val        = var(obj, varargin)
            val = var(obj.PointSet, varargin{:});
        end
        
    end
    
    % Conversion to other types (and related helper methods)
    methods
        
        obj      = pset(obj);
        
        winrej   = eeglab_winrej(obj);
        
        str      = eeglab(obj, varargin);
        
        [Signal, str, SignalPath]      = NBT(obj, varargin);
        
        str      = fieldtrip(obj, varargin);
        
        
    end
    
    % Static constructors
    methods (Static)
        
        obj = from_fieldtrip(str, varargin);
        
        obj = from_eeglab(str, varargin);
        
        obj = from_nbt(str, SignalInfo, varargin);
        
        obj = from_pset(obj, varargin);
        
        obj = load(obj);
        
    end
    
    % Constructor
    methods
        
        function obj = physioset(varargin)
            
            import pset.pset;
            import misc.process_arguments;
            import pset.globals;
            
            % Ensure each physioset instance gets an independent method
            % configuration object
            obj.Config = physioset.default_method_config;
            
            if nargin > 0 && isa(varargin{1}, 'pset.pset'),
                obj.PointSet = varargin{1};
            else
                obj.PointSet = pset(varargin{:});
            end
            
            varargin = varargin(3:end);
            
            opt.samplingrate    = globals.get.SamplingRate;
            opt.sensors         = [];
            opt.event           = [];
            opt.name            = '';
            
            opt.samplingtime  = [];
            dateFormat        = globals.get.DateFormat;
            timeFormat        = globals.get.TimeFormat;
            opt.startdate     = datestr(now, dateFormat);
            opt.starttime     = now;
            opt.eqweights     = [];
            opt.eqweightsorig = [];
            opt.physdimprefixorig = [];
            opt.badchannel    = [];
            opt.badsample     = [];
            opt.info          = struct;
            opt.header        = [];
            opt.metamapper    = [];
            opt.eventmapper   = [];
            
            [~, opt] = process_arguments(opt, varargin);
            
            if isempty(opt.sensors),
                opt.sensors = sensors.dummy(size(obj.PointSet,1));
            end
            
            if isempty(opt.samplingtime),
                
                opt.samplingtime = ...
                    0:1/opt.samplingrate:obj.PointSet.NbPoints/...
                    opt.samplingrate - 1/opt.samplingrate;
                
            end
            
            % physioset name
            if isempty(opt.name),
                opt.name = default_name(obj);
            end
            
            if ischar(opt.starttime),
                opt.starttime = ...
                    datenum([opt.startdate ' ' opt.starttime], ...
                    [dateFormat ' ' timeFormat]);
            end
            
            obj.SamplingRate    = opt.samplingrate;
            obj.Sensors         = opt.sensors;
            obj.SamplingTime    = opt.samplingtime;
            obj.TimeOrig        = opt.starttime;
            
            if ~isempty(opt.event)
                 try
                    opt.event = sort(opt.event);
                 catch
                     opt.event = [];
                     warning('Events not imported')
                 end
            end
            obj.Event           = opt.event;
            obj.EqWeights       = opt.eqweights;
            obj.EqWeightsOrig   = opt.eqweightsorig;
            obj.PhysDimPrefixOrig = opt.physdimprefixorig;
            obj.MetaMapper      = opt.metamapper;
            obj.EventMapper     = opt.eventmapper;
            
            obj                 = set_name(obj, opt.name);
            
            % Set meta properties
            if ~isempty(opt.header),
                opt.info.header = opt.header;
            end
            
            obj = set_meta(obj, opt.info);
            
            apply_meta_mapper(obj);
            
            apply_event_mapper(obj);
            
            if obj.NbDims > 0,
                obj.BadChan = false(1, obj.NbDims);
                if ~isempty(opt.badchannel)
                    obj.BadChan(opt.badchannel) = true;
                end
            end
            
            if obj.NbPoints > 0,
                if isempty(opt.badsample),
                    obj.BadSample = false(1, obj.NbPoints);
                else
                    obj.BadSample = opt.badsample;
                end
            end
            
            check(obj);
        end
        
    end
    
end