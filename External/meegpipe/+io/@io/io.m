classdef io
   % Defines interface and provides basic functionality to all io
   % sub-classes
   
   
   properties
       Verbose;
       Fid;
   end   
   
   % Constructor
   methods
       function obj = io(varargin)
           import misc.process_arguments;
           
           opt.verbose = true;
           opt.fid     = 1;
           
           [~, opt] = process_arguments(opt, varargin);
           
           obj.Verbose = opt.verbose;
           obj.Fid     = opt.fid;
       end
   end
   
   % Check invariants
   methods
       function obj = set.Verbose(obj, value)
          if numel(value) ~= 1 || ~islogical(value),
              throw_me(obj, [], 'InvalidType', ...
                  'The ''Verbose'' property must be a logical scalar');
          end
          obj.Verbose = value;
       end
       function obj = set.Fid(obj, value)
          import misc.isnatural;
          if numel(value) ~= 1 || ~isnatural(value),
              throw_me(obj, [], 'InvalidFileIdentifier', ...
                  'The ''Fid'' property must be a valid file identifier')
          end
          obj.Fid = value;
       end
       
   end
      
   % Interface methods
   methods
       [hdr, data] = read(obj, varargin);
       data        = read_data(obj, varargin);
       hdr         = read_header(obj, varargin);
       status      = write(obj, varargin);
   end
   
  % Methods implemented by this class
  methods
      status = print_msg(obj, method, msg);
      status = print_warning(obj, method, warn);
      throw_me(obj, method, id, msg);
  end
    
    
end