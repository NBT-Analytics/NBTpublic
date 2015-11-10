classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node copy
    %
    % ## Usage synopsis:
    %
    % % Create a copy node that will attach postfix '_mycopy' to the copy
    % import meegpipe.node.copy.*;
    % myConfig = config('PostFix', '_mycopy');
    % myNode   = copy(myConfig);
    %
    % % Alternatively:
    % myNode = copy('PostFix', '_copy');
    %
    % ## Accepted configuration options (as key/value pairs):
    % 
    %       Filename : A string. Default: '', i.e. based on input file name
    %           The name of the generated file
    %
    %       Path : A string. Default: '', i.e. same as input
    %           Disk location where the copy should be created.
    %
    %       Postfix : A string. Default: '_copy'
    %           If the Filename key is not provided, this key will lead to
    %           an output file whose name is identical to the input file
    %           name but with the provided postfix string.
    %
    %       Prefix : A string. Default: ''
    %           A prefix to append to the name of the generated file.
    %
    %       Writable : Logical scalar. Default: same as input.
    %           If set to false, the copied object will not be writable.
    %
    %       Temporary : Logical scalar. Default: same as input. 
    %           If set to true, the output object will be temporary.
    %
    % See also: copy
  
    properties
        
        Path;
        PostFix     = '_copy';
        PreFix;
        Filename;
        
    end
    
    % Consistency checks (to be done...)
    methods
        
        function obj = set.PostFix(obj, value)
            obj.PostFix = value;
        end
        
        function obj = set.PreFix(obj, value)
            obj.PreFix = value;
        end
        
        function obj = set.Filename(obj, value)
            obj.Filename = value;
        end
        
    end
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@meegpipe.node.abstract_config(varargin{:});            
           
        end
        
    end
    
    
    
end