classdef bad_epochs < meegpipe.node.abstract_node
    % BAD_EPOCHS - Reject bad data epochs
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.bad_epochs')">misc.md_help(''meegpipe.node.bad_epochs'')</a>
    
    % Helper methods
    methods (Access = private, Static)
        
        generate_rank_report(obj, data, sensors, rejIdx, rankVal);
        
    end
    
    % Helper static methods
    methods (Access = private, Static)
        
        hFig = make_topo_plots(sens, rejIdx, xvar)
        
        hFig = make_rank_plots(sens, rejIdx, xvar);
        
    end
    
    methods
        % meegpipe.node.node interface
        [data, dataNew] = process(data, varargin);
        
        % reimplementation of method from abstract_node
        disp(obj);
        
    end
    
    
    % Constructor
    methods
        
        function obj = bad_epochs(varargin)
            
            import pset.selector.sensor_class;
            import pset.selector.good_data;
            import pset.selector.cascade;
            import misc.prepend_varargin;
            
            dataSel1 = sensor_class('Class', {'EEG', 'MEG'});
            dataSel2 = good_data;
            dataSel  = cascade(dataSel1, dataSel2);
            varargin = prepend_varargin(varargin, 'DataSelector', dataSel);  
  
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'bad_epochs');
            end
            
        end
        
    end
    
end