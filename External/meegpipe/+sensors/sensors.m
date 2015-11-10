classdef sensors
    % SENSORS - Interface for sensor array description classes
    %
    %
    % See also: sensors.

    
    methods (Abstract)
        
        %% To be implemented by final classes
        [cArray, cArrayIdx] = sensor_groups(obj);
        
        cellArray           = labels(obj, varargin);
        
        isMatch             = match_label_regex(obj, regex);
        
        nbSensors           = nb_sensors(obj);
        
        cellArray           = types(obj);
        
        labels              = orig_labels(obj);
        
        cellArray           = get_physdim(obj);
        
        obj                 = set_physdim(obj, value);
        
        weights             = get_eqweights(obj);
        
        obj                 = subset(obj, idx);
        
        %% Implemented by abstract_sensors.
        
        obj                 = set_physdim_prefix(obj, prefix);
        
        [prefix, power]     = get_physdim_prefix(obj);
        
        unit                = get_physdim_unit(obj);
        
        dist                = get_distance(obj, idx);
        
        xyz                 = cartesian_coords(obj);
        
        bool                = has_coords(obj);        
      
        % For plotting purposes
        layout = layout2d(obj);
        
        layout = layout3d(obj);
        
        % Conversion to other formats
        struct = fieldtrip(obj);
        struct = eeglab(obj);
        
        % In order to be able to embed the sensors in the HTML reports
        count   = fprintf(fid, obj, varargin);
        
    end
    
    
end