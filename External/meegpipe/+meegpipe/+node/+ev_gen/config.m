classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration of ev_gen nodes
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.ev_gen.config')">misc.md_help(''meegpipe.node.ev_gen.config'')</a>
 
    
    properties
        
        EventGenerator = physioset.event.periodic_generator;
        Plotter = {physioset.plotter.snapshots.snapshots('WinLength', 10)};
        
    end
    
    % Consistency checks
    
    methods
        
        function obj = set.Plotter(obj, value)
            
            import exceptions.InvalidPropValue;
            
            if isempty(value), value = {}; end 
            
            if ~iscell(value),
                value = {value};
            end
            
            if ~all(cellfun(@(x) isa(x, 'report.gallery_plotter'), value)),
                throw(InvalidPropValue('Plotter', ...
                    'Must be a cell array of gallery_plotter objects'));
            end
           
            obj.Plotter = value;
        end
        
        function obj = set.EventGenerator(obj, value)
            
            import exceptions.*;
            
            if isempty(value),
                value = physioset.event.periodic_generator;
            end
            
            if numel(value) ~= 1 || ...
                    ~isa(value, 'physioset.event.generator'),
                throw(InvalidPropValue('EventGenerator', ...
                    'Must be an event generator object'));
            end
            
            obj.EventGenerator = value;            
            
        end
      
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});
            
        end
        
    end
    
    
end