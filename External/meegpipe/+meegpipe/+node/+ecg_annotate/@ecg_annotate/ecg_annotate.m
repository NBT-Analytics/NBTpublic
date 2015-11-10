classdef ecg_annotate < meegpipe.node.abstract_node
    % ecg_annotate - Annotate heartbeats using ECG
    %
    % See: <a href="matlab:misc.md_help('meegpipe.node.ecg_annotate')">misc.md_help(''meegpipe.node.ecg_annotate'')</a>
    
    properties (SetAccess = private, GetAccess = private)
        HRVFeatures_;
    end
    
    methods (Access = private)
        [info, hrvInfo, evArray] = ecgpuwave(obj, data);
    end
    
    % from meegpipe.node.abstract_node
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % redefinition of report.reportable method whatfor()
    methods
        
        function str = whatfor(~)
            
            str = ['Nodes of class __ecg_annotate__ identify the locations ' ...
                'of QRS complexes, and annotate heartbeat types. The '  ...
                'produced annotations are stored in the input physioset ' ...
                'as events of class physioset.event.std.ecg_ann'];
            
        end
        
    end
    
    % Constructor
    methods
        
        function obj = ecg_annotate(varargin)
            
            import pset.selector.sensor_label;
            import misc.prepend_varargin;
            
            dataSel = sensor_label('^ECG');
            varargin = prepend_varargin(varargin, 'DataSelector', dataSel);  
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'ecg_annotate');
            end
            
        end
        
    end
    
    
end