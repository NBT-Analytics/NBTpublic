classdef mri < head.head & ...
        goo.method_config & ...
        goo.printable & ...
        goo.abstract_named_object & ...
        goo.hashable 
    % MRI
    % Head model based on an MRI scan
    %
    % 
    % obj = head.mri;
    %
    % obj = head.mri('SubjectPath', subjpath);
    %
    %
    % where
    %
    % OBJ is a head.mri object
    %
    % SUBJPATH is the full path where the subject MRI surfaces are located
    %
    % 
    % 
    % See also: head.mri
    %

    properties (SetAccess =  private)
        Sensors;
        ID;
        SurfacesPath;
        SourceSpace;        
        Source;
        OuterSkin;
        OuterSkull;
        InnerSkull; 
        InnerSkullNormals;
        OuterSkinDense;
        OuterSkullDense;
        InnerSkullDense; 
        FieldTripVolume;
        LeadField;
        SourceDipolesLeadField;
        InverseSolution; 
        MeasNoise; 
    end
    
    properties (GetAccess = private, SetAccess = private)
        DelaunayTess;
    end
    
        
    properties (Dependent)
        NbSensors;
        NbSourceVoxels;
        NbSources;
    end
    
        
    % Global consistency check
    methods (Access=private)
        check_sources(obj); 
    end   

    % Helper methods
    methods (Static, Access = private)
        [subj, filesOut] = get_surface_files(subjectPath, nbVertices)
        value = point_depth(surfPoints, point)
    end

    
    % head.head interface
    methods
        y   = kernel(obj, sensor, dipole)
        h   = plot(obj, sensor, dipole, varargin)
        obj = add_source(obj, varargin)
        obj = remove_source(obj, sourceName)
    end
    
    % Other public methods
    methods       
        % goo.hashable interface
        function code = get_hash_code(obj)
            import datahash.DataHash;
            if isempty(obj.Sensors),
                code = DataHash([]);
            else
                code = get_hash_code(obj.Sensors);
            end
            if ~isempty(obj.SourceSpace),
                code = DataHash([code;obj.SourceSpace(:)]);
            end
        end
        obj = sensors_to_outer_skin(obj);
        obj = make_source_grid(obj, density);    
        obj = make_source_surface(obj, density);        
        obj = make_bem(obj, varargin);
        index = source_index(obj, names);
        h = plot_source(obj, index, varargin);
        h = plot_source_topography(obj, index, varargin);
        h = plot_scalp_potentials(obj, index, varargin);
        h = plot_inverse_solution_dipoles(obj, varargin);
        h = plot_inverse_solution_leadfield(obj, varargin);
        obj = make_leadfield(obj);
        obj = add_source_noise(obj, varargin);
        obj = add_source_activation(obj, index, activation, varargin);
        obj = get_source_centroid(obj, index, varargin);
        obj = inverse_solution(obj, varargin);
        [coord, m] = get_inverse_solution_centroid(obj);
        r   = brain_radius(obj);
        [pnt, tri] = source_layer(obj, dist);
        
        function obj = set_sensors(obj, sens)
            sensNew = map2surf(sens, obj.OuterSkin, 'fig', false, ...
                'verbose', false);
            obj.Sensors = sensNew;
        end
        
        function obj = select_sensor(obj, idx)
           
            obj.LeadField = obj.LeadField(idx, :, :);
            obj.Sensors = subset(obj.Sensors, idx);
            obj.SourceDipolesLeadField = obj.SourceDipolesLeadField(idx,:);
            
            
        end
    end

    % Dependent properties
    methods
        function value = get.NbSensors(obj)
            if isempty(obj.Sensors),
                value = 0;
            else
                value = size(obj.Sensors.Cartesian, 1);
            end
        end
        
        function value = get.NbSources(obj)
            if isempty(obj.Source),
                value = 0;
            else
                value = numel(obj.Source);
            end
        end
        
        function value = get.NbSourceVoxels(obj)
            if isempty(obj.SourceSpace),
                value = 0;
            else
                value = size(obj.SourceSpace.pnt,1);
            end
        end
        
    end    
    
    % Constructor
    methods
        function obj = mri(varargin)
            import misc.process_arguments;
            import head.mri;
            import misc.plot_mesh;
            import mperl.file.spec.catdir;
            import mperl.file.spec.rel2abs;
            import exceptions.MissingData;
          
            opt.SurfacesPath = catdir(...
                rel2abs([meegpipe.root_path filesep '..']), ...
                'data', 'head_models', '0003');
            opt.NbVertices   = 5120;
            opt.Sensors      = sensors.eeg.from_template('egi256');
           
            [~, opt] = process_arguments(opt, varargin);  
            
            if isempty(opt.Sensors),
                throw(MissingData('Sensor coordinates'));
            end

            % Load surface files and identify the subject name
            info = head.mri.get_surface_files(opt.SurfacesPath, opt.NbVertices);
                     
            obj.ID = info.id;
            obj.SurfacesPath = rel2abs(opt.SurfacesPath);
            if isempty(info.outerskin),  
                throw(MissingData('Outer Skin surface'));  
            end
            if isempty(info.outerskull), 
                throw(MissingData('Outer Skull surface'));
            end
            if isempty(info.innerskull), 
                throw(MissingData('Inner Skull surface')); 
            end           
            
            surfaces = {'OuterSkin', 'OuterSkull', 'InnerSkull', ...
                'OuterSkinDense', 'OuterSkullDense', 'InnerSkullDense'};            
            
            for surfIter = surfaces
               thisSurf = lower(surfIter{1});
               thisFile = info.(thisSurf);
               [pnt, tri] = io.tri.read(thisFile);
               tmp = struct('pnt', pnt, 'tri', tri, 'file', thisFile);
               obj.(surfIter{1}) = tmp; 
            end
            
            obj = set_sensors(obj, opt.Sensors);
            
            % Do not attempt to print this type of objects using fprintf().
            % It can lead to the object being serilized using XML. And this
            % is a huge object!
            obj = set_method_config(obj, 'fprintf', 'ParseDisp', false);
        end
        
    end
  
end