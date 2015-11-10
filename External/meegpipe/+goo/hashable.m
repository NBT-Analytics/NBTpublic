classdef hashable
   % HASHABLE - Interface for hashable classes
   %
   % A class is hashable if an MD5 hash can be produced to identify its
   % objects' data. Namely, hashable classes need to implement the
   % following method:
   %
   % hash = get_hash_code(obj)
   %
   % Where
   %
   % HASH is the MD5 hash (a string of 32 characters).
   %
   % See also: hashable_handle
   
   methods
       
       function code = get_hash_code(obj)
           import datahash.DataHash;
           
           warning('off', 'MATLAB:structOnObject');
           
           str = struct(obj);
           warning('on', 'MATLAB:structOnObject');
           
           warning('off', 'JSimon:BadDataType');
           code = DataHash({str, class(obj)});
           warning('on', 'JSimon:BadDataType');
           
        end
       
   end
    
    
    
    
end