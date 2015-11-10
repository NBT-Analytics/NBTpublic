classdef tal
    % TAL
    % Time-stamped annotation list class
    %
    % obj = tal(onset, duration, annotation);
    % obj = tal(onset, duration, annotation, 'propName', 'propValue', ...);
    %
    %
    % Where
    %
    % OBJ is @tal object
    %
    % ONSET is a numeric array with annotation onsets, in seconds
    %
    % DURATION is a numeric array with annotation durations, in seconds
    %
    % ANNOTATION is a cell array with annotation texts.
    %
    %
    %
    %
    %
    % More information:
    %
    % [1] http://www.edfplus.info/specs/edfplus.html
    %
    %
    % See also: EDFPLUS
    
    properties (SetAccess = private)
        Onset;
        Duration;
        Annotation;
    end
    
    
    % Constructor
    methods
        function obj = tal(onset, duration, annotation, varargin)
            
            import edfplus.globals;
            import edfplus.tal;
            
            if nargin < 1, return; end            
            
            obj.Onset        = onset;
            obj.Duration     = duration;
            obj.Annotation   = annotation;
            
        end
        
        
    end
    
    % Static helper methods
    methods (Static)
        ann = ann2rec(annIn, annOnset, annDur, nBytes, recOnset)
        
    end
    
    % Public interface
    methods
        function annByRec = records(obj, recOnset, nBytes)
            import edfplus.tal;
            annByRec = tal.ann2rec(obj.Annotation, obj.Onset, obj.Duration, ...
                recOnset, nBytes);
            
        end
    end
    
    
end