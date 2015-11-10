classdef brainloc < spt.feature.feature & goo.verbose
    % BRAINLOC - Brain localization of a SPT component
    
    properties
       HeadModel;
       InverseSolver;
       CoordinatesOnly = true; % Should only the location coordinates be produced
    end
    
    methods
        
        % spt.feature.feature interface
        [idx, featName] = extract_feature(obj, sptObj, tSeries, raw, rep, varargin)
        
        % Constructor        
        function obj = brainloc(varargin)
            import misc.process_arguments;            

            evalc('opt.HeadModel = make_bem(head.mri)');
            opt.HeadModel       = [];
            opt.InverseSolver   = 'dipfit';  
            opt.CoordinatesOnly = true;
            [~, opt] = process_arguments(opt, varargin);
            
            if isempty(opt.HeadModel),
                evalc(['headModel = make_leadfield(make_source_surface(' ...
                    'make_bem(head.mri(''Sensors'', ' ...
                    ' sensors.eeg.from_template(''egi256'')))))']);
                obj.HeadModel = headModel;
            else
                obj.HeadModel = opt.HeadModel;
            end
            obj.InverseSolver = opt.InverseSolver;
            obj.CoordinatesOnly = opt.CoordinatesOnly;
        end
        
    end
    
    
    
end