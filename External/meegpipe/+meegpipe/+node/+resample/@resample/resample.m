classdef resample < meegpipe.node.abstract_node
    % RESAMPLE - Change sampling rate of a pointset
    %
    % obj = resample('P', p, 'Q', q)
    %
    %
    % Where
    %
    % OBJ is an meegpipe.node.resample object
    %
    %
    % ## Accepted key/value pairs:
    %
    % * All key/value pairs accepted by aar.node.abstract_node
    %
    % * The data will be resampled to a rate P/Q times the original
    %   sampling rate.
    %
    %
    % See also: meegpipe.node.abstract_node, meegpipe.node
    
    
    % from meegpipe.node.abstract_node
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = ['Nodes of class _resample_ modify the sampling rate ' ...
                'of the input data.'];
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = resample(varargin)
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
          
            if isempty(get_name(obj)),
                obj = set_name(obj, 'resample');
            end
            
        end
        
    end
    
    
end