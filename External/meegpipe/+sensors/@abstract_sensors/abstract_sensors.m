classdef abstract_sensors < sensors.sensors & goo.abstract_setget
    % ABSTRACT_SENSORS - Common methods accross sensors.sensorsclasses

   
    % Default implementations
    methods
        
        obj             = set_physdim_prefix(obj, prefix);
        
        [prefix, power] = get_physdim_prefix(obj);
        
        unit            = get_physdim_unit(obj);
        
        % Default layout is just NaNs
        function layout = layout2d(obj)
            layout = nan(nb_sensors(obj), 3);
        end
        
        function layout = layout3d(obj)
            layout = nan(nb_sensors(obj, 3));
        end
        
        % Default distance is 1
        function dist = get_distance(~, ~)
            dist = 1;
        end
        
        function xyz = cartesian_coords(obj)
           
            xyz = nan(nb_sensors(obj), 3);
            
        end
        
        function bool = has_coords(obj)
           
            bool = ~any(any(isnan(cartesian_coords(obj))));
            
        end
        
        function isMatch = match_label_regex(obj, regex)
            import misc.join;
            
            if iscell(regex), 
                % A cell array of channel labels
                regex = ['^(' join('|', regex) ')$'];
            end
            
            sensLabels = labels(obj);
            
            isMatch = false(1, numel(sensLabels));

            for i = 1:numel(sensLabels)
                
                isMatch(i) = ~isempty(regexp(sensLabels{i}, regex, 'once'));
                
            end
            
            isMatch = isMatch(:);
            
        end
        
        function [LIA, LIB] = ismember(obj, varargin)
           
            if numel(varargin) == 1 && iscell(varargin{1}),
                varargin = varargin{1};
            end
            if ischar(varargin),
                varargin = {varargin};
            end
            [LIA, LIB] = ismember(varargin, labels(obj));
            LIA = LIA(:);
            LIB = LIB(:);
            
        end
        
        % Conversion to other formats
        struct = fieldtrip(obj);
        struct = eeglab(obj);
        
        count = fprintf(fid, obj, varargin);
        
        
    end
    
end