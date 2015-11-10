classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node obs
    %
    % ## Usage synopsis:
    %
    % % Create a node that will remove 4 OBS components
    %
    % import meegpipe.node.obs.*;
    % myConfig = config('nPC', 4);
    % myNode = obs(myConfig);
    %
    % % Alternatively:
    % myNode = obs('nPC', 4);
    %
    % ## Accepted configuration options:
    %
    % * obs class constructor admits all the key/value pairs
    %   admitted by the abstract_node class.
    %
    %       Method : A string. Default: 'OBS'   
    %           The algorithm to use for BCG removal. Alternatives are:
    %           'mean', 'gmean', 'median'.
    %
    %       nPc : A natural scalar. Default: 4
    %           Number of principal components to use for OBS. This option
    %           is only relevant for Method OBS.
    %
    %       EventSelector : A physioset.event.selector object. 
    %           Default: physioset.event.class_selector('qrs')
    %
    %       ERPDuration : A positive scalar. Default: 1.2
    %           Duration in seconds of the BCG ERP that will be stored in
    %           the node after identifying BCG instances.
    %
    %       ERPOffset : A numeric scalar. Default: 0.1
    %           Offset in seconds from the occurrence of a QRS event to the
    %           beginning of a BCG instance. 
    %           
    %
    % See also: obs
    
    % Documentation: pkg_obs.txt
    % Description: Configuration for node obs
    
    
     %% PUBLIC INTERFACE ...................................................
    
    properties       
        
        Method          = 'obs';
        NPC             = 4;
        EventSelector   = physioset.event.class_selector('qrs');
        ERPDuration     = 1.2; % in seconds
        ERPOffset       = 0.1; % in seconds
        
    end
    
    % Consistency checks
    methods
       
         function obj = set.Method(obj, value)
           
            import exceptions.*;
            import misc.isstring;
            import mperl.join;
            
            if isempty(value),
                value = 'obs';
            end
            
            if ~isstring(value)
                throw(InvalidPropValue('Event', ...
                    'Must be a string'));
            end
            
            validMethods = {'obs', 'mean', 'gmean', 'median'};
            
            if ~ismember(lower(value), validMethods),
                throw(InvalidPropValue('Method', ...
                    sprintf('Must be any of: %s', ...
                    join(', ', validMethods))));
            end
            
            obj.Method = lower(value); 
            
         end
         
         function obj = set.NPC(obj, value)
            
             import exceptions.*;
             import misc.isnatural;
             
             if isempty(value),
                 value = 4;
             end
             
             if numel(value) ~= 1 || ~isnatural(value),
                 throw(InvalidPropValue('NPC', ...
                     'Must be a natural scalar'));
             end
             
             obj.NPC = value;
             
             
         end
         
         function obj = set.EventSelector(obj, value)
             
            import exceptions.*;
            import goo.pkgisa;
            
            if isempty(value), 
                value = physioset.event.class_selector('qrs');
            end
            
            if numel(value) ~= 1 || ~pkgisa(value, 'physioset.event.selector'),
                throw(InvalidPropValue('EventSelector', ...
                    'Must be an event_selector object'));
            end
            
            obj.EventSelector = value;
             
             
         end
         
         function obj = set.ERPDuration(obj, value)
            
             import exceptions.*;
             import goo.pkgisa;
             
             if isempty(value),
                 obj.ERPDuration = 1.2;
                 return;
             end
             
             if numel(value) ~= 1 || ~isnumeric(value) || value < 0,
                 throw(InvalidPropValue('ERPDuration', ...
                     'Must be a positive scalar'));
             end
             
             obj.ERPDuration = value;
             
         end
         
         function obj = set.ERPOffset(obj, value)
            
             import exceptions.*;
             import goo.pkgisa;
             
             if isempty(value),
                 obj.ERPOffset = 0.1;
                 return;
             end
             
             if numel(value) ~= 1 || ~isnumeric(value),
                 throw(InvalidPropValue('ERPOffset', ...
                     'Must be a numeric scalar'));
             end
             
             obj.ERPOffset = value;
             
         end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});            
           
        end
        
    end
    
    
    
end