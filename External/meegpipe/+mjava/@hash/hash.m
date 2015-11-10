classdef hash < goo.hashable
    % HASH - Class for a hash-like data structure
    %
    %
    % obj = hash;
    % obj = hash('key', value, ...);
    % obj = hash.new(capacity);
    % obj = hash.new(capacity, loadFactor);
    %
    %
    % Where
    %
    % OBJ is a hash object
    %
    % CAPACITY is the initial capacity of the hash, which is 11 by default
    %
    % LOADFACTOR is the initial load factor, which is 0.75 by default
    %
    %
    % ## Add a key/value pair to a hash
    %
    % obj = hash;
    % obj('key') = value;
    %
    %
    % ## Add several key/value pairs to a hash
    %
    % obj = hash;
    % obj{'key1', 'key2', 'key3'} = {value1, value2, value3}
    %
    %
    % ## Delete one or more key/value pairs
    %
    % obj = hash('key1', value1, 'key2', value2, 'key3', value3);
    % obj = delete(obj, 'key1');			% Removes only key1 and its value
    % obj = delete(obj, {'key2','key3'});   % Now this is an empty hash
    %
    %
    % ## Get hash keys and has values
    %
    % obj 		 = hash('key1', value1, 'key2', value2);
    % keysCell   = keys(obj);
    % valuesCell = values(obj);
    % values     = obj({'key1', 'key2'});
    %
    % See also: keys, values

    
    %% IMPLEMENTATION ......................................................
    properties (GetAccess=private, SetAccess = private)
        
        Hashtable;
        Class;
        Dimensions;
        FieldNames;
        
    end
    
    
    %% PUBLIC INTERFACE ...................................................
    methods
        
        obj             = subsasgn(obj, S, B);
        value           = subsref(A, S);
        keysCell        = keys(obj);
        valuesCell      = values(obj);
        obj             = delete(obj, key);
        str             = struct(obj);
        cArray          = cell(obj);
        bool            = isempty(obj);   
        newObj          = clone(obj);     
        keys            = sort(obj, fh);
        value           = regexp_match(obj, key);
        hashObj         = subset(obj, keyArray);
        disp(obj);
        
        % from eegpipe.types.hashable interface
        hash            = get_hash_code(obj);
        
    end

    % Static constructor
    methods (Static)
        
        obj = from_struct(str);
        obj = from_cell(str);
        
        function obj = new(varargin)
            import mjava.hash;
            obj = hash;
            if nargin < 1, return; end
            obj.Hashtable  = java.util.Hashtable(varargin{:});
            obj.Class      = java.util.Hashtable(varargin{:});
            obj.FieldNames = java.util.Hashtable(varargin{:});
            obj.Dimensions = java.util.Hashtable(varargin{:});
        end
        
    end
    
    % Constructor
    methods
        
        function obj = hash(varargin)
            obj.Hashtable  = java.util.Hashtable;
            obj.Class      = java.util.Hashtable;
            obj.FieldNames = java.util.Hashtable;
            obj.Dimensions = java.util.Hashtable;
            
            if numel(varargin) == 1,
                varargin = varargin{:};
            end
            
            count = 1;
            while count < numel(varargin)
                s.type = '()';
                s.subs = varargin(count);
                obj = subsasgn(obj, s, varargin{count+1});
                count = count+2;
            end
        end
        
        
    end
    
    
    
    
end