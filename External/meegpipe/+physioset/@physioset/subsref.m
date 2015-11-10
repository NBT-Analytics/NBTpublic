function val = subsref(obj, s)

try
    
    val = subsref(obj.PointSet, s);
    
catch ME
    
    if strcmpi(ME.identifier, 'MATLAB:noSuchMethodOrField'),
        
        if strcmpi(s(1).type, '.'),
            
            if numel(s) > 1,
                val = subsref(obj.(s(1).subs), s(2:end));
            else
                val = obj.(s(1).subs);
            end
            
        else
            
           rethrow(ME);
           
        end
        
    else
        
        rethrow(ME);
        
    end
    
end

end
