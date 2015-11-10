classdef event < goo.abstract_setget & ...
        goo.abstract_named_object & ...
        matlab.mixin.Heterogeneous
    
    % EVENT - Class for events in a pointset container
    %
    %   EV = event(SAMPLE [,PROP1,VAL1,...,PROPN,VALN]) constructs an event
    %   which is located at the time instant POS and that has the
    %   properties specified as pairs (PROP_NAME, PROP_VALUE). An event
    %   object follows a similar format as the event structures in
    %   Fieldtrip: http://fieldtrip.fcdonders.nl/.
    %
    %   EV = event(STRUCT_ARRAY) builds an array of event objects using as
    %   input argument an array of structs having fields with names that
    %   match the properties of event objects. This constructor can be used
    %   to convert an array of Fieldtrip event structs into an array of event
    %   objects.
    %
    %   EV = event(TAL_CELL) builds and array of event objects using a cell
    %   array containing Time Annotated Lists (TALs). Such TALs are
    %   typically obtained when reading an EDF+ file using io.edfplus.read.
    %
    %   ## Property/Value pairs and descriptions:
    %
    %       Type: Char array or Scalar. Default: []
    %           The type of the event.
    %
    %       Sample: Scalar. Default: []
    %           Time instant at which the event occurs.
    %
    %       Value: Scalar. Default: []
    %           A numeric property of the event. Alternatively, this
    %           property might be the value of the associated signal at the
    %           event time.
    %
    %       Duration: Scalar. Default: 1
    %           In the case of events with duration that define trials,
    %           the Sample property is the first sample of a trial and the
    %           Offset property is the offset of the trigger with respect
    %           to the trial. An offset of 0 means that the first sample of
    %           the trial corresponds to the trigger. A positive offset
    %           indicates that the first sample is later than the trigger,
    %           a negative offset indicates that the trial begins before
    %           the trigger.
    %
    %       Offset: Scalar. Default: 0
    %           See the explanation above for the Duration property.
    %
    %       Dims: Scalar array. Default: []
    %           The specific data dimensions (e.g. sensors) at which the
    %           event is present. By default this property is empty,
    %           meaning that the event is present in all data channels.
    %
    %   All the properties above are public and can therefore be modified
    %   after the object has been created.
    %
    %   ## Note:
    %
    %   Contrary to Fieldtrip, an event object considers that a
    %   single-sample event has a duration of 1 sample and an offset of 0.
    %   Fieldtrip sets those properties to empty in such a case.
    %
    %   ## Usage synopsis:
    %
    %   % To create a 'QRS' event that spans the whole duration of a
    %   % QRS complex and that is located around the position of the
    %   % R-peak:
    %
    %   import physioset.event.event;
    %   ev = event(1000, 'Type', 'QRS', 'Offset', -40, 'Duration', 100)
    %
    %   % which assumes that the QRS complex was located at sample
    %   % 1000, and that spanned from sample 1000-Offset = 960 until
    %   % sample (1000-Offset)+Duration-1 = 1059.
    %
    %
    %
    % See also: pset.physioset, pset, io.edfplus.read
    
    
    %% PUBLIC INTERFACE ...................................................
    properties
        
        Type     = '';  % Type of the event (a scalar or a char array).
        Sample   = NaN; % Sample at which the event occurs.
        Time;           % Time instant at which the event occurs.
        Value;          % A numeric property of the event.
        Offset   = 0;   % Beginning of the event relative to Sample.
        Duration = 1;   % The duration of the event (used to specify trials).
        Dims;           % The data dimensions to which the event applies.
        
    end
    
    % Set/Get methods
    % Note: No set methods for properties Sample and Type, as such methods
    % slow considerably the creation of large arrays of event objects. For
    % checked assignment use methods set_type, set_sample instead.
    methods
        
        
        function obj = set.Value(obj, v)
            
            obj.Value = v;
            
        end
        
        function obj = set.Offset(obj, v)
            
            import exceptions.*;
            
            if isempty(v), v = 0; end % Fieldtrip convention
            
            if numel(v) ~=1 || ~isnumeric(v),
                throw(InvalidPropValue('Offset', ...
                    'Must be a numeric scalar'));
            end
            
            obj.Offset = v;
            
        end
        
        function obj = set.Dims(obj, v)
            import misc.isinteger;
            import exceptions.*;
            
            if ~isinteger(v) || any(v < 0),
                throw(InvalidPropValue('Dims', ...
                    'Must be a(n array of) integer(s)'));
            end
            
            obj.Dims = v;
            
        end
        
    end
    
    % Need to be sealed because of matlab.mixin.Heterogeneous
    methods (Sealed)
        
        time        = etime(ev1, ev2);
        
        evArray     = group_types(evArray);
        
        b           = struct(a);
        
        b           = fieldtrip(a);
        
        [ev, dur, trialBeginEv] = eeglab(a, makeEpochs);
        
        y           = eq(a,b);
        
        y           = ne(a,b);
        
        disp(obj);
        
        [setN, getN, allN] = fieldnames(varargin);
        
        bool = isa(obj, varargin);
        
        function value = get_sample(obj)
            
            value = arrayfun(@(x) get(x, 'Sample'), obj,'UniformOutput',false);
            
        end
        
        function value = get_duration(obj)
            
            value = arrayfun(@(x) get(x, 'Duration'), obj);
            
        end
        
        function value = get_offset(obj)
            
            value = arrayfun(@(x) get(x, 'Offset'), obj);
            
        end
        
        [evArray, idx] = nn_all(evArray1, evArray2, forward);
        
        [ev, idx] = select(ev, varargin);
        
        [evArray, idx] = sort(evArray, varargin);
        
        [y, ca, cb] = unique(evArray, property)
        
        ev = resample(ev, p, q);
        
        ev = shift(ev, nsamples);
        
        ev = map2class(ev, mapHash);
        
        str = event2str(ev);
        
        count = fprintf(fid, ev, varargin);
      
        
        % Consistency checks have been moved here in order to allow for
        % checked (slow) modifiers and unchecked (fast) modifiers
        
        function obj = set_sample(obj, v)
            
            import misc.isnatural;
            import exceptions.*
            
            if numel(v) == 1, v = repmat(v, 1, numel(obj)); end
            
            if isempty(v) || numel(v) ~= numel(obj) || ...
                    any(isnan(v)) || ~isnatural(v) || any(v > 1e100),
                throw(InvalidPropValue('Sample', ...
                    'Must be a natural scalar < 1e100'));
            end
            
            for i = 1:numel(obj)
                
                obj(i).Sample = v(i);
                
            end
            
        end
        
        function obj = set_type(obj, v)
            
            import exceptions.*
            
            if isempty(v), v = ''; end
            
            if ~isscalar(v) && ~isa(v, 'char'),
                throw(InvalidPropValue('Type', ...
                    'Must be a string or numeric scalar'));
            end
            
            if numel(obj) > 1 && ischar(v),
                for i = 1:numel(obj)
                    obj(i).Type = v;
                end
            else
                obj.Type = v;
            end
            
        end
        
        function obj = set_duration(obj, v)
            
            import misc.isnatural;
            import exceptions.*
            
            if numel(obj) > 1,
                
                if numel(v) == 1, v = repmat(v, 1, numel(obj)); end
                
                for i = 1:numel(obj)
                    
                    obj(i) = set_duration(obj(i), v(i));
                    
                end
                return;
                
            end
            
            if isempty(v), v = 1; end % Default duration is 1 sample
            
            if numel(v) ~= 1 || ~isnatural(v) ,
                throw(InvalidPropValue('Duration', ...
                    'Must be a natural scalar'));
            end
            
            if numel(v) == 1 && numel(obj) > 1,
                v = repmat(v, 1, numel(obj));
            end
            
            for i = 1:numel(obj),
                obj(i).Duration = v(i);
            end
            
        end
        
        function obj = set_offset(obj, v)
            
            import misc.isinteger;
            import exceptions.*
            
            if isempty(v), v = 1; end % Default duration is 1 sample
            
            if numel(v) ~= 1 || ~isinteger(v),
                throw(InvalidPropValue('Offset', ...
                    'Must be an integer'));
            end
            
            if numel(v) == 1 && numel(obj) > 1,
                v = repmat(v, 1, numel(obj));
            end
            
            for i = 1:numel(obj),
                obj(i).Offset = v(i);
            end
            
        end
        
    end
    
    % Static constructors
    methods (Static)
        
        ev = from_struct(structArray);
        
        ev = from_eeglab(structArray);
        
        ev = from_fieldtrip(structArray);
        
        ev = from_tal(talArray);
        
    end
    
    % Constructor
    methods
        
        function obj = event(pos, varargin)
            
            import physioset.event.event;
            
            if nargin < 1 || isempty(pos), return; end
            
            if nargin == 1 && isa(pos, 'physioset.event.event'),
                % copy constructor
                obj(size(pos,1), size(pos,2)) = event;
                for i = 1:numel(pos)
                    obj(i).Sample = pos(i).Sample;
                    obj(i).Type   = pos(i).Type;
                    obj(i).Time   = pos(i).Time;
                    obj(i).Value  = pos(i).Value;
                    obj(i).Offset = pos(i).Offset;
                    obj(i).Duration = pos(i).Duration;
                    obj(i).Dims   = pos(i).Dims;
                end
                return;
            end
            
            pos = sort(pos, 'ascend');
            
            obj(size(pos,1), size(pos,2)) = event;
            
            for i = 1:numel(obj)
                
                obj(i).Sample = pos(i);
                
                obj(i) = set(obj(i), varargin{:});
                
            end
            
            
        end
        
    end
    
    
end


