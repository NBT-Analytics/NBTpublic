classdef signal
    % SIGNAL
    % EDF+ signal class
    %
    % obj = signal;
    % obj = signal('propName', propValue, ...)
    %
    % Where
    %
    % OBJ is a signal object
    %
    % Accepted arguments:
    %
    % --type <signaltype>
    %       A string specifying the signal type
    %
    % --spec <specification>
    %       A specification string, e.g. Fpz-Cz
    %
    % --dim <string>
    %       A string specifying the basic dimension for the signal. See
    %       signal.signal_types for a list of valid signal types and
    %       corresponding valid dimensions.
    %
    % --prefix <string>
    %       Multiplier factor of the basic dimension. See signal.prefixes
    %       for a list of valid prefixes and corresponding multipliers.
    %
    %
    % Static factories
    %
    % eeg()
    %       EEG signal measured in microvolts
    %
    %
    %
    % See also: edfplus.signal.prefixes, edfplus.signal, EDFPLUS
    
    
    properties (SetAccess = private)
        Dimension;
        Prefix;
        Type;
        Spec;
        Transducer;
        PreFilter;
        PhysMin;
        PhysMax;
        DigMin;
        DigMax;
    end
    
    
    % Constructor
    methods
        function obj = signal(varargin)
            import misc.process_arguments;
            import misc.isnatural;
            import misc.strtrim;
            import edfplus.signal;
            
            keySet = {...
                'spec', ...
                'dim', ...
                'prefix', ...
                'type', ...
                'transducer', ...
                'prefilter', ...
                'physmin', ...
                'physmax', ...
                'digmin', ...
                'digmax' ...
                };
            
            spec        = '';
            dim         = [];
            prefix      = '';
            type        = 'X';
            transducer  = '';
            prefilter   = '';
            physmin     = [];
            physmax     = [];
            digmin      = -2048;
            digmax      = 2047;
            
            eval(process_arguments(keySet, varargin));
            
            if isempty(dim) && ~isempty(type),
                [~, signalDims] = signal.signal_types(type);
                dim = strtrim(signalDims{1});
            end
            
            obj.Spec        = spec;
            obj.Dimension   = dim;
            obj.Type        = type;
            obj.Prefix      = prefix;
            obj.Transducer  = transducer;
            obj.PreFilter   = prefilter;
            obj.PhysMin     = physmin;
            obj.PhysMax     = physmax;
            obj.DigMin      = digmin;
            obj.DigMax      = digmax;
            
            check(obj);
        end
    end
    
    % Consistency checks: set methods
    methods
        function obj = set.Spec(obj, value)
            if isempty(value), return; end
            if ~ischar(value),
                ME = MException('EDFPLUS:signal:signal:InvalidArgument', ...
                    'The ''Spec'' property must be a string');
                throw(ME);
            end
            obj.Spec = value;
        end
        
        function obj = set.Dimension(obj, value)
            if isempty(value), return; end
            if ~ischar(value),
                ME = MException('EDFPLUS:signal:signal:InvalidArgument', ...
                    'The Dimension property must be a string');
                throw(ME);
            end
            obj.Dimension = value;
        end
        
        function obj = set.Type(obj, value)
            if isempty(value), return; end
            import edfplus.signal;
            if ~ischar(value),
                ME = MException('EDFPLUS:signal:signal:InvalidArgument', ...
                    'The Type property must be a string');
                throw(ME);
            end
            
            if ~ismember(value, signal.signal_types),
                ME = MException('EDFPLUS:signal:signal:InvalidArgument', ...
                    'Signal type ''%'' is not valid', value);
                throw(ME);
            end
            
            obj.Type = value;
            
        end
        
        function obj = set.Prefix(obj, value)
            if isempty(value), return; end
            import edfplus.signal;
            if ~ischar(value),
                ME = MException('EDFPLUS:signal:signal:InvalidArgument', ...
                    'The ''Prefix'' property must be a string');
                throw(ME);
            end
            if ~ismember(value, signal.prefixes),
                ME = MException('EDFPLUS:signal:signal:InvalidArgument', ...
                    'Prefix ''%s'' is not valid', value);
                throw(ME);
            end
            obj.Prefix = value;
            
        end
        
        function obj = set.Transducer(obj, value)
            if isempty(value), return; end
            if ~ischar(value),
                ME = MException('EDFPLUS:signal:signal:InvalidArgument', ...
                    'The ''Transducer'' property must be a string');
                throw(ME);
            end
            obj.Transducer = value;
        end
        
        function obj = set.PreFilter(obj, value)
            if isempty(value), return; end
            if ~ischar(value),
                ME = MException('EDFPLUS:signal:signal:InvalidArgument', ...
                    'The ''PreFilter'' property must be a string');
                throw(ME);
            end
            obj.PreFilter = value;
        end
        
        function obj = set.PhysMin(obj, value)
            import misc.isinteger;
            if isempty(value), return; end
            if ~isinteger(value),
                ME = MException('EDFPLUS:signal:signal:InvalidArgument', ...
                    'The ''PhysMin'' property must be an integer');
                throw(ME);
            end
            obj.PhysMin = value;
        end
        
        function obj = set.PhysMax(obj, value)
            import misc.isinteger;
            if isempty(value), return; end
            if ~isinteger(value),
                ME = MException('EDFPLUS:signal:signal:InvalidArgument', ...
                    'The ''PhysMax'' property must be an integer');
                throw(ME);
            end
            obj.PhysMax = value;
        end
        
        function obj = set.DigMin(obj, value)
            import misc.isinteger;
            if isempty(value), return; end
            if ~isinteger(value),
                ME = MException('EDFPLUS:signal:signal:InvalidArgument', ...
                    'The ''DigMin'' property must be an integer');
                throw(ME);
            end
            obj.DigMin = value;
        end
        
        function obj = set.DigMax(obj, value)
            import misc.isinteger;
            if isempty(value), return; end
            if ~isinteger(value),
                ME = MException('EDFPLUS:signal:signal:InvalidArgument', ...
                    'The ''DigMax'' property must be an integer');
                throw(ME);
            end
            obj.DigMax = value;
        end
    end
    
    % Global consistency checks
    methods
        function check(obj)
            import edfplus.signal;
            [~, properDims] = signal.signal_types(obj.Type);
            if ~ismember(obj.Dimension, properDims),
                ME = MException('EDFPLUS:signal:signal:InvalidArgument', ...
                    ['Dimension ' obj.Dimension ' is not ' ...
                    'a valid dimension for an ' obj.Type ' signal']);
                throw(ME);
            end
            
            if xor(isempty(obj.PhysMin), isempty(obj.PhysMax)),
                ME = MException('EDFPLUS:signal:signal:InvalidArgument', ...
                    ['Either both or none of the properties ''PhysMin'' '...
                    'and ''PhysMax'' have to be specified']);
                throw(ME);
            end
            
            if ~isempty(obj.PhysMin) && obj.PhysMin > obj.PhysMax,
                ME = MException('EDFPLUS:signal:signal:InvalidArgument', ...
                    '''PhysMin'' is greater than ''PhysMax''');
                throw(ME);
            end
            
            if ~isempty(obj.DigMin) && obj.DigMin > obj.DigMax,
                ME = MException('EDFPLUS:signal:signal:InvalidArgument', ...
                    '''DigMin'' is greater than ''DigMax''');
                throw(ME);
            end
            
        end
    end
    
    % Static factories
    methods (Static)
        obj = eeg(ns);
    end
    
    % Static methods
    methods (Static)
        [prefix, power, name]	= prefixes;
        [type, dim, descr]      = signal_types(queryType);
    end
    
    % Public interface
    methods
        function str = sensor_label(obj)
            import edfplus.globals;            
            nChar = globals.evaluate.NbCharsSensor;
            str = repmat(' ', 1, nChar); 
            if ~isempty(obj.Spec),
                thisStr = [obj.Type ' ' obj.Spec];
            else
                thisStr = obj.Type;
            end
            if numel(thisStr)> nChar,
               thisStr = thisStr(1:nChar);                
            end
            str(1:numel(thisStr)) = thisStr;
        end
        
        function str = transducer_label(obj)
            import edfplus.globals;            
            nChar = globals.evaluate.NbCharsTransducer;
            str = repmat(' ', 1, nChar);       
            thisStr = obj.Transducer;
            if numel(thisStr)> nChar,
               thisStr = thisStr(1:nChar);                
            end
            str(1:numel(thisStr)) = thisStr;
        end       
        
        function str = dimension_label(obj)
            import edfplus.globals;            
            nChar = globals.evaluate.NbCharsDimension;
            str = repmat(' ', 1, nChar);
            thisStr = [obj.Prefix obj.Dimension];             
            if numel(thisStr)> nChar,
               thisStr = thisStr(1:nChar);                
            end
            str(1:numel(thisStr)) = thisStr;
            str(1:numel(thisStr)) = thisStr;
        end
        
        function str = physmin_label(obj)
            import edfplus.globals;            
            nChar = globals.evaluate.NbCharsPhysMin;
            str = repmat(' ', 1, nChar);       
            thisStr = num2str(obj.PhysMin);
            if numel(thisStr)> nChar,
               thisStr = thisStr(1:nChar);                
            end
            str(1:numel(thisStr)) = thisStr;
            str(1:numel(thisStr)) = thisStr;
        end
        
        function str = physmax_label(obj)
            import edfplus.globals;            
            nChar = globals.evaluate.NbCharsPhysMax;
            str = repmat(' ', 1, nChar);       
            thisStr = num2str(obj.PhysMax);
            if numel(thisStr)> nChar,
               thisStr = thisStr(1:nChar);                
            end
            str(1:numel(thisStr)) = thisStr;
            str(1:numel(thisStr)) = thisStr;
        end
        
        function str = digmin_label(obj)
            import edfplus.globals;            
            nChar = globals.evaluate.NbCharsDigMin;
            str = repmat(' ', 1, nChar);       
            thisStr = num2str(obj.DigMin);
            if numel(thisStr)> nChar,
               thisStr = thisStr(1:nChar);                
            end
            str(1:numel(thisStr)) = thisStr;
            str(1:numel(thisStr)) = thisStr;
        end
        
        function str = digmax_label(obj)
            import edfplus.globals;            
            nChar = globals.evaluate.NbCharsDigMax;
            str = repmat(' ', 1, nChar);       
            thisStr = num2str(obj.DigMax);
            if numel(thisStr)> nChar,
               thisStr = thisStr(1:nChar);                
            end
            str(1:numel(thisStr)) = thisStr;
            str(1:numel(thisStr)) = thisStr;
        end
        
        function str = prefilter_label(obj)
            import edfplus.globals;            
            nChar = globals.evaluate.NbCharsPreFilter;
            str = repmat(' ', 1, nChar);      
            thisStr = obj.PreFilter;
            if numel(thisStr)> nChar,
               thisStr = thisStr(1:nChar);                
            end
            str(1:numel(thisStr)) = thisStr;
            str(1:numel(thisStr)) = thisStr;
        end   
        
    end
    
end
