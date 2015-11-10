classdef config < goo.abstract_setget_handle   
    % CONFIG - Configuration for class topography
    
    %% PUBLIC INTERFACE ...................................................
    properties
        
        DeleteOnDestroy = true;
        ChannelClass    = {'eeg'};
        ChannelType     = [];
        ColorBar        = false;
        EMarker         = {'.', 'k', [], 1};
        GridScale       = 128;
        HColor          = 'k';      % Head color
        Normalized      = false;
        NoseDir         = '+X';
        NumContour      = 6;        % Number of contour lines
        MapLimits       = 'absmax';                
        Sensors         = 'on';
        Fiducials       = 'off';
        Extra           = 'ptslabels'
        Shading         = 'flat';          
        Style           = 'both';   % See topoplot's options   
        WhiteBk         = 'off';
        Visible         = true;
        
    end
    
    % Consistency checks (still to be done!)
    methods
        
        function obj = set.DeleteOnDestroy(obj, value)
           
            import exceptions.*;
            
            if isempty(value),
                obj.DeleteOnDestroy = true;
                return;
            end
            
            if ~islogical(value) && numel(value) > 1,
                throw(InvalidPropValue('DeleteOnDestroy', ...
                    'Must be a logical scalar'));
            end
            
            obj.DeleteOnDestroy = value;
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
           obj = obj@goo.abstract_setget_handle(varargin{:});
           
        end
        
    end
    
    
end