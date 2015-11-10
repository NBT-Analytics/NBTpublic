classdef physioset_export < meegpipe.node.abstract_node
    % physioset_export - Creates physioset object from disk file
    %
    %
    % See also: meegpipe.node
   
   
    % meegpipe.node.node interface
    methods
        
        % does something extra on top of abstract_node's method
        [data, dataNew] = process(obj, file, varargin)
        
    end
    
    % Constructor
    methods
        
        function obj = physioset_export(varargin)
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'physioset_export');
            end
            
        end
        
    end
    
end