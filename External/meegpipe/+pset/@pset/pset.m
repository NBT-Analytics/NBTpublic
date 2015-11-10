classdef pset < pset.mmappset & ...
        goo.abstract_setget_handle & ...
        goo.abstract_named_object_handle
    % PSET - Memory-mapped point-set
    %
    % pset_obj = pset(fname, nDims);
    % pset_obj = pset(fname, nDims, 'key', value, ...)
    %
    % Where
    %
    % FNAME is the full path name of the file to be memory mapped
    %
    % NDIMS (obj scalar) is the dimensionality of the points stored in the
    % provided file
    %
    %
    % ## Accepted key/value pairs
    %
    %       Precision:  String. Def: 'double'
    %           Precision of the numeric values stored in the file.
    %           Supported values are 'int8', 'int16', 'int32', 'int64',
    %           'uint8', 'uint16', 'uint32', 'uint64', 'single', and
    %           'double'
    %
    %       Writable: Logical scalar. Default: false
    %           Can the pset be assigned to?
    %
    %       Temporary: Logical scalar. Default: false
    %           Determines whether the associated data file should be
    %           erased after obj pset object goes out of scope or is
    %           otherwise cleared
    %
    %       Transposed: Logical scalar. Default: false
    %           Determines whether the subsref should use column-wise
    %           or row-wise points. By default Transposed is false and
    %           obj(:,i) will return the value of the ith point. If
    %           Transposed is set to true, the ith point would be
    %           referenced by obj(i,:)
    %
    %       Mapsize: Natural scalar. Def: globals.evaluate.MapSize
    %           Maximum size (in bytes) of a single memory map
    %
    %
    % ## Example:
    %
    % % To create obj pset associated with the data file 'pointset.dat,
    % % (which contains 7-dimensional points in single opt.precision), and
    % % set every other point in the pset object to zero:
    % %
    %  p = pset('records.dat', 7, 'opt.precision', 'single', 'opt.writable', true)
    %  pset(:,1:2:end) = 0;
    %
    %
    % See also: physioset, pset
    
    %% IMPLEMENTATION .....................................................
    properties (GetAccess = private, SetAccess = private)
        
        % For storing previous selections
        DimSelectionH;
        PntSelectionH;
       
        % For storing previous spatial maps
        DimMapH;
        DimInvMapH;        
    
    end
    
    % Private static methods
    methods (Access = private, Static)
        
        write_mmap(data, filename, varargin);
        
        nPoints = get_nb_points(fid, nDims, precision);
        
        [mMap, pIdx] = mmemmapfile(datafile, nDims, nPoints, ...
            precision, varargin);
        
    end
    
        
    methods (Access = private)
        
        [mIdx, pIdx] = get_map_index(obj, p_index);
        
    end
    
    properties
        
        Temporary   = true;    % Is the object opt.temporary?
        Transposed  = false;   % Are the sample values stored rowwise?
        Writable    = true;    % Write access           
        AutoDestroyMemMap = false;  % Destroy memmaps inmmediatelty after use?        
        
    end
    
    properties (SetAccess = private)
        
        DataFile;           % Binary file where the data values are stored
        HdrFile;            % Associated binary header file
        Info;               % Miscellaneous information (a struct)
        NbPoints  = 0;      % Number of points (samples) in the pset object
        NbDims    = 0;      % Cardinality of the pset.
        PntSelection = [];  % Selected data sub-set
        DimSelection = [];
        DimMap       = [];  % Data has been spatially projected
        DimInvMap    = [];
        Precision;          % Numeric opt.precision used in the data file
        
    end
    
    properties (GetAccess = private, SetAccess = private)
        
        MapIndices;
        ChunkIndices;
        MemoryMap;
        MapSize;            % Size of obj map size in number of points.
        
    end
    
    properties (Dependent)
        
        NbMaps;             % Number of memory maps used.
        NbChunks;           % Number of memory chunks needed to load the whole pset.
        ChunkSize;          % Size of obj data chunk in number of points.
        
    end
    
    % Set/Get methods
    methods
        
        function y = get.NbMaps(obj)
            % Number of memory maps in the pset object.
            y = length(obj.MapIndices);
        end
        
        function y = get.NbChunks(obj)
            y = length(obj.ChunkIndices);
        end
        
        function y = get.ChunkSize(obj)
            if isempty(obj.ChunkIndices),
                y = [];
            else
                y = [diff(obj.ChunkIndices) ...
                    obj.NbPoints-obj.ChunkIndices(end)+1];
            end
        end
        
        function set.Temporary(obj, v)
            if ~isscalar(v) || ~isa(v, 'logical')
                ME = MException('pset:illegalPropertyValue', ...
                    'The Temporary field must contain a logical scalar');
                throw(ME);
            end
            obj.Temporary = v;
        end
        
        function set.Transposed(obj, v)
            if ~isscalar(v) || ~isa(v, 'logical')
                ME = MException('pset:illegalPropertyValue', ...
                    'The Transposed field must contain a logical scalar');
                throw(ME);
            end
            obj.Transposed = v;
        end
        
        function set.Writable(obj, v)
            if ~isscalar(v) || ~isa(v, 'logical')
                ME = MException('pset:illegalPropertyValue', ...
                    'The Writable field must contain a logical scalar');
                throw(ME);
            end
            obj.Writable = v;
        end
        
        function set.DataFile(obj, v)
            import mperl.file.spec.rel2abs;
            obj.DataFile = rel2abs(v);
        end
        
    end
    
    % pset.mmappset interface
    methods
        
        y         = subsref(obj, s);
        
        obj       = subsasgn(obj, s, b);
        
        function filename = get_datafile(obj)
            filename = obj.DataFile;
        end
        
        function filename = get_hdrfile(obj)
            filename = obj.HdrFile;
        end
        
        newObj          = copy(obj, varargin);
        
        newObj          = subset(obj, varargin);
        
        obj             = concatenate(varargin);
        
        nDims           = nb_dim(obj);
        
        nPnts           = nb_pnt(obj);
        
        save(filename, obj);
        
        objEmbd         = delay_embed(obj, dim, delay, shift);
        
        obj             = loadobj(obj);
        
        obj             = saveobj(obj);
        
        obj             = move(obj, varargin);
        
        obj             = sphere(obj, varargin);
        
        obj             = smooth_transitions(obj, evArray, varargin);
        
        % Selection related methods
        
        obj = select(obj, varargin);
        
        obj = clear_selection(obj);
        
        obj = restore_selection(obj);
        
        obj = backup_selection(obj);
        
        bool = has_selection(obj);
        
        bool = has_dim_selection(obj);
        
        bool = has_pnt_selection(obj);
        
        rowIdx = dim_selection(obj);
        
        rowIdx = relative_dim_selection(obj);
        
        colIdx = pnt_selection(obj);
        
        colIdx = relative_pnt_selection(obj);
        
        function obj = set_dim_selection(obj, sel)
            obj.DimSelection = sel;
        end
        
        function obj = set_pnt_selection(obj, sel)
            obj.PntSelection = sel;
        end
        
        % Projection related methods
        
        obj = project(obj, varargin);
        
        obj = clear_projection(obj);
        
        obj = restore_projection(obj);
        
        obj = backup_projection(obj);
        
        obj = assign_values(obj, otherObj);
        
        [y, pIdx] = get_chunk(obj, chunk_index);
        
        function bool = is_temporary(obj)
           bool = obj.Temporary;            
        end
        
    end
    
    % Other public methods
    methods
        
        obj = destroy_mmemmapfile(obj, idx);
        
        obj = make_mmemmapfile(obj);
        
        function obj = set_datafile(obj, value)
            obj.DataFile = value;
        end
        
        function obj = set_hdrfile(obj, value)
            obj.HdrFile = value;
        end
        
    end
    
    % MATLAB built-in numeric numeric operators
    methods
        
        obj = unary_operator(obj, op);
        
        function obj = abs(obj)
           unary_operator(obj, @(x) abs(x));
        end
        
        y = flipud(x);
        y = reshape(obj, varargin);
        varargout = size(obj, dim);
        y = end(obj,k,n);
        y = isempty(obj);
        y = isnumeric(obj);
        y = isfloat(obj);
        y = issparse(obj);
        y = double(obj);
        y = single(obj);
        y = logical(obj);
        y = plus(obj,b);
        y = minus(obj,b);
        y = times(obj,b);
        y = mtimes(obj,b);
        y = rdivide(obj,b);
        y = ldivide(obj,b);
        y = mrdivide(obj,b);
        y = mldivide(obj,b);
        y = power(obj,b);
        y = nthroot(obj,b);
        y = sum(obj,dim);
        y = mean(obj, dim);
        y = repmat(obj, dim1, dim2);
        y = demean(obj, dim);
        y = lt(obj,b);
        y = gt(obj,b);
        y = le(obj,b);
        y = ge(obj,b);
        y = ne(obj,b);
        y = eq(obj,b);
        y = conj(obj);
        y = ctranspose(obj);
        y = transpose(obj);
        y = horzcat(obj,b,varargin);
        y = vertcat(obj, b,varargin);
        
    end
    
    
    % Static constructors
    methods (Static)
        
        obj = load(filename);
        
        obj = nan(nDims, nPoints, varargin);
        
        obj = ones(nDims, nPoints, varargin);
        
        obj = zeros(nDims, nPoints, varargin);
        
        obj = rand(nDims, nPoints, varargin);
        
        obj = randn(nDims, nPoints, varargin);
        
        obj = generate_data(type, nDims, nPoints, varargin);
        
        
    end
    
    % Constructor
    methods
        
        function obj = pset(filename, nDims, varargin)

            import pset.pset;
            import misc.get_full_path;
            import misc.process_arguments;
            import misc.sizeof;
            import meegpipe.get_config;
  
            if nargin < 1, return; end
            
            if nargin < 2,
                
                error('pset:invalidInputArg', ...
                    'At least two input arguments are expected');
                
            end
            
            dataFileExt = get_config('pset', 'data_file_ext');
            hdrFileExt  = get_config('pset', 'hdr_file_ext');
            
            if isunix,
                obj.DataFile = filename;
            else
                obj.DataFile = get_full_path(filename);
            end
            
            obj.HdrFile = strrep(obj.DataFile, dataFileExt, hdrFileExt);
            
            opt.Temporary    = get_config('pset', 'temporary');
            opt.Transposed   = get_config('pset', 'transposed');
            opt.Precision    = get_config('pset', 'precision');
            opt.Writable     = get_config('pset', 'writable');
            
            opt.AutoDestroyMemMap = get_config('pset', 'auto_destroy_mem_map');
            
            if isempty(opt.AutoDestroyMemMap),
                % Just in case...
                opt.AutoDestroyMemMap = false;
            end
            
            [~, opt] = process_arguments(opt, varargin);
            
            fNames = fieldnames(opt);
            for i = 1:numel(fNames)
                obj.(fNames{i}) = opt.(fNames{i});
            end
            
            % Number of points stored in the file
            fid = fopen(filename);
            nPoints = pset.get_nb_points(fid, nDims, obj.Precision);
            fclose(fid);
            
            % Create the memory maps
            [obj.MemoryMap, obj.MapIndices] = pset.mmemmapfile(...
                filename, nDims, nPoints, obj.Precision, ...
                'mapsize',  obj.MapSize, ...
                'writable', obj.Writable);
            
            
            % Dimensions of the dataset
            obj.NbDims = nDims;
            obj.NbPoints = 0;
            for i = 1:length(obj.MemoryMap)
                obj.NbPoints = obj.NbPoints + ...
                    size(obj.MemoryMap{i}.Data.Data,2);
            end
            
            % Number of points in each memory chunk
            chunkSize = pset.globals.get.MemoryMapSize;
            nPointsChunk = floor(chunkSize/(sizeof(obj.Precision)*nDims));
            obj.ChunkIndices = 1:nPointsChunk:nPoints;
            if obj.ChunkIndices(end) == nPoints && numel(obj.ChunkIndices)>1,
                obj.ChunkIndices(end) = [];
            end
            
        end
        
    end
    
    
    % Destructor
    methods
        
        function delete(obj)
            
            % Deletes the associated file, if the pset was 'temporary'
            if obj.Temporary,
                destroy_mmemmapfile(obj);
                warning('off', 'MATLAB:DELETE:Permission');
                warning('off', 'MATLAB:DELETE:FileNotFound');
                try
                    % If they file is referred to by another pset object we
                    % will not be allowed to erase it
                    delete(obj.DataFile);
                catch %#ok<CTCH>
                    fclose('all');
                    delete(obj.DataFile);
                end
                delete(obj.HdrFile);
            end
            
        end
        
    end
    
end