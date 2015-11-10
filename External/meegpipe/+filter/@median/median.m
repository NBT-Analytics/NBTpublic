classdef median < ...
        filter.dfilt & ...
        goo.verbose              & ...
        goo.abstract_setget      & ...
        goo.abstract_named_object
    
    properties
       
        Order;
        BlockSize;
        
    end
    
    
    methods
       % filter.dfilt interface
       function x = filtfilt(obj, x, varargin)
           x = filter(obj, x, varargin);
       end
       
       function [x, obj] = filter(obj, x, varargin)
           if isempty(obj.BlockSize),
               for i = 1:size(x, 1),
                   x(i,:) = medfilt1(x(i,:), obj.Order);
               end
           else
               for i = 1:size(x, 1)
                   x(i,:) = medfilt1(x(i,:), obj.Order, obj.BlockSize);
               end
           end
       end
       
       % Constructor
       function obj = median(varargin)
          
           import misc.process_arguments;
           import misc.set_properties;
           if nargin < 1, return; end
                      
           opt.Order = [];
           opt.Name  = 'median';
           opt.BlockSize = [];
           opt.Verbose = true;
           [~, opt] = process_arguments(opt, varargin);
           obj.Order = opt.Order;
           obj = set_name(obj,  opt.Name);
           obj = set_verbose(obj, opt.Verbose);
           
       end
        
        
    end
    
end