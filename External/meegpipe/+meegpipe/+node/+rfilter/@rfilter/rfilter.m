classdef rfilter < meegpipe.node.abstract_node
    % RFILTER - Regression filter
    
    methods (Static, Access = private)
        
        gal = generate_filt_plot(rep, idx, data1, data2, samplTime, gal, showDiff);
        
    end
    
    % meegpipe.node.node interface
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % Constructor
    methods
        function obj = rfilter(varargin)
            import misc.prepend_varargin;
            
            dataSel = pset.selector.good_data;
            varargin = prepend_varargin(varargin, 'DataSelector', dataSel);       
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                filtObj = get_config(obj, 'Filter');
                if isempty(filtObj),
                    obj = set_name(obj, 'rfilter');
                elseif isa(filtObj, 'filter.rfilt') && ...
                        ~isempty(get_name(filtObj)),
                    obj = set_name(obj, ['rfilter-' get_name(filtObj)]);
                else
                    set_name(obj, 'rfilter');
                end
            end
            
        end
    end
    
    
end