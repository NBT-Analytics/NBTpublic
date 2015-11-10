classdef physioset_import < meegpipe.node.abstract_node
    % PHYSIOSET_IMPORT - Creates physioset object from disk file
    %
    % obj = physioset_import;
    % obj = physioset_import(cfg);
    % obj = physioset_import('key', value, ...)
    %
    % Where
    %
    % CFG is a <a href="matlab: help('config')">config</a> object.
    %
    % ('key', value, ...) is a list of construction arguments as key/value
    % pairs. The constructor of class physioset_import accepts exatly the
    % same keys as its associated config class.
    %
    % ## Public interface:
    %
    %   <a href="matlab: help('meegpipe.node.node')">meegpipe.node.node</a>
    %
    %
    % ## Usage examples
    %
    % % Import from a Fieldtrip .mat file, and select only the first 10
    % % channels
    % myImporter = physioset.import.fieldtrip;
    % myDataSel = pset.selector.sensor_idx(1:10);
    % myNode = meegpipe.node.physioset_import.new(...
    %       'Importer', myImporter, ...
    %       'DataSelector', myDataSel );
    % data = run(myNode, 'svui_0003_eeg_wm-second-ns_04_seldata.mat');
    %
    % # Note that property DataSelector has a special meaning for this type
    % # of nodes.
    %
    % See also: config, meegpipe.node.node
    

  
    % meegpipe.node.node interface
    methods
        
        % does something extra on top of abstract_node's method
        [data, dataNew] = process(obj, file, varargin)
        
    end
    
    % Constructor
    methods
        
        function obj = physioset_import(varargin)
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'physioset_import');
            end
            
        end
        
    end
    
end