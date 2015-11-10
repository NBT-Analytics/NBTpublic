classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node mra_fmrib
    %
    %
    % See also: mra_fmrib
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        LPF      = 40;      % Low-pass filter cutoff
        L        = 10;      % Interpolation folds
        Window   = 30;      % Length of averaging window in number of artifacts
        TR       = [];      % TR duration
        NbSlices = [];      % Number of slices per volume
        ANC      = true;    % Perform adaptive noice cancellation?
        OBS      = 'auto';  % Number of OBS components to remove
        EventSelector  = physioset.event.class_selector('tr');
        
    end
    
    % Consistency checks to be done
    methods
        
        % Global consistency check
        function check(obj)
            import exceptions.Inconsistent;
            
            if isempty(obj.TR) || isempty(obj.NbSlices),
                throw(Inconsistent(...
                    'Properties TR and NbSlices must be provided'));
            end
            
        end
        
        function obj = set.LPF(obj, value)
            
            import exceptions.InvalidPropValue;
            import misc.isnatural;
            import goo.from_constructor;
            
            if isempty(value),
                obj.LPF = 70;
            elseif numel(value) ~= 1 || ~isnumeric(value)  || value < 0
                throw(InvalidPropValue('LPF', ...
                    'Must be a positive scalar'));
            else
                obj.LPF = value;
            end
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        function obj = set.L(obj, value)
            
            import exceptions.InvalidPropValue;
            import misc.isnatural;
            import goo.from_constructor;
            
            if isempty(value),
                obj.L = 10;
            elseif numel(value) ~= 1 || ~isnatural(value)
                throw(InvalidPropValue('L', ...
                    'Must be a natural scalar'));
            else
                obj.L = value;
            end
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        function obj = set.Window(obj, value)
            
            import exceptions.InvalidPropValue;
            import misc.isnatural;
            import goo.from_constructor;
            
            if isempty(value),
                obj.Window = 30;
            elseif numel(value) ~= 1 || ~isnatural(value)
                throw(InvalidPropValue('Window', ...
                    'Must be a natural scalar'));
            else
                obj.Window = value;
            end
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        function obj = set.TR(obj, value)
            
            import exceptions.InvalidPropValue;
            import goo.from_constructor;
            
            if isempty(value),
                obj.TR = [];
            elseif numel(value) ~= 1 || ~isnumeric(value) || value < 0
                throw(InvalidPropValue('TR', ...
                    'Must be a positive scalar'));
            else
                obj.TR = value;
            end
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        function obj = set.NbSlices(obj, value)
            
            import exceptions.InvalidPropValue;
            import goo.from_constructor;
            import misc.isnatural;
            
            if isempty(value),
                obj.NbSlices = [];
            elseif numel(value) ~= 1 || ~isnatural(value)
                throw(InvalidPropValue('NbSlices', ...
                    'Must be a positive scalar'));
            else
                obj.NbSlices = value;
            end
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        function obj = set.ANC(obj, value)
            
            import exceptions.InvalidPropValue;
            import goo.from_constructor;
            
            if isempty(value),
                obj.ANC = true;
            elseif numel(value) ~= 1 || ~islogical(value)
                throw(InvalidPropValue('ANC', ...
                    'Must be a logical scalar'));
            else
                obj.ANC = value;
            end
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        function obj = set.OBS(obj, value)
            
            import exceptions.InvalidPropValue;
            import goo.from_constructor;
            
            if isempty(value),
                obj.OBS = 'auto';
            elseif (ischar(value) && ~strcmp(value, 'auto')) || ...
                    (islogical(value) && numel(value) ~= 1) || ...
                    (~islogical(value) && ~ischar(value)),
                throw(InvalidPropValue('OBS', ...
                    'Must be a logical scalar or the string ''auto'''));
            else
                obj.OBS = value;
            end
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
        function obj = set.EventSelector(obj, value)
            
            import exceptions.InvalidPropValue;
            import goo.from_constructor;
            
            if isempty(value),
                obj.EventSelector = physioset.event.class_selector('tr');
            elseif ~isa(value, 'physioset.event.selector'),
                throw(InvalidPropValue('EventSelector', ...
                    'Must be an event selector object'));
            else
                obj.EventSelector = value;
            end
            
            if ~from_constructor(obj),
                check(obj);
            end
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
            if nargin < 1, return; end
            
            check(obj);
            
        end
        
    end
    
    
    
end