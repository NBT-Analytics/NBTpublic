classdef pipeline < meegpipe.node.abstract_node
    % PIPELINE - Class constructor
    %
    % A pipeline is a collection of node objects. Processing some data
    % with a pipeline is equivalent to sequentially processing the data
    % with the pipeline nodes.
    %
    %
    % See also: node, abstract_node
    
    % Declared and defined here
    methods
        
        templateFile = get_template_file(obj);
        function obj = set_fake_id(obj, id)
            obj.FakeID = id;
        end
        function id  = get_fake_id(obj)
            id = obj.FakeID;
        end
        
    end
    
    %%% from abstract_node
    methods
        
        function myPipe = train(myPipe, varargin)
           nodeList = get_config(myPipe, 'NodeList');
           for i = 1:numel(nodeList)
              nodeList{i} = train(nodeList{i}, varargin{:}); 
           end
           set_config(myPipe, 'NodeList', nodeList);
        end
        
        % required by parent meegpipe.node.abstract_node
        [data, dataNew] = process(obj, data, varargin);
        
    end
    
    
    %%% Constructor
    methods
        
        function obj = pipeline(varargin)
            import misc.split_arguments;
            
            if nargin > 0 && ~ischar(varargin{1}) && ...
                    ~isa(varargin{1}, 'meegpipe.node.pipeline.pipeline')
                % Do this only IF not a copy constructor!! Otherwise we
                % will end up with an infinite recursion when cloning
                % pipeline objects
                count = 0;
                while count < nargin && ...
                        isa(varargin{count+1}, 'meegpipe.node.node')
                    count = count+1;
                end
                
                nodeList = varargin(1:count);
                
                args = [{'NodeList', nodeList}, varargin(count+1:end)];                
        
            else
                
                args = varargin;
                
            end            
            
            obj = obj@meegpipe.node.abstract_node(args{:});                   
            
            
            nodeList = get_config(obj, 'NodeList');
            for i = 1:numel(nodeList),
                nodeList{i} = clone(nodeList{i});
            end
            
            for i = 1:numel(nodeList)
                childof(nodeList{i}, obj, i);
            end
            set_config(obj, 'NodeList', nodeList);
            
            if isempty(get_name(obj)),
                set_name(obj, 'pipeline');
            end
            
        end
        
    end
    
end