classdef printable_handle < handle
    % PRINTABLE_HANDLE - Interface for printable (handle) objects
    %
    % See also: printable
    
    methods
       
        % Default implementation, usually overriden
        function count = fprintf(fid, critObj, varargin)
            import misc.fid2fname;
            
            % Default implementation simply prints the criterion props into
            % a separate sub-report
            count = 0;
            objRep = report.object.new(critObj);
            parentFname = fid2fname(fid);
            
            if ~isnan(parentFname),
                objRep = childof(objRep, parentFname);
            end
            initialize(objRep);
            generate(objRep);
            [~, repName] = fileparts(get_filename(objRep));
            count = count + ...
                fprintf(fid, '[%s](%s)', class(critObj), [repName '.htm']);
        end
        
    end
    
    
    
end