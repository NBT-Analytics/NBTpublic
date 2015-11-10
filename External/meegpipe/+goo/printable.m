classdef printable
    % PRINTABLE - Interface for printable objects
    %
    %
    
    methods
        
        % Default implementation, usually overriden
        function count = fprintf(fid, obj, varargin)
            import misc.fid2fname;
            import misc.process_arguments;
            import mperl.file.spec.*;
            import misc.unique_filename;
            import misc.code2multiline;
            
            opt.ParseDisp  = true;
            opt.SaveBinary = false;
            
            if isa(obj, 'goo.method_config'),
                defCfg = get_method_config(obj, 'fprintf');
                [~, opt] = process_arguments(opt, [defCfg(:);varargin(:)]);
            end
            
            % Default implementation simply prints the criterion props into
            % a separate sub-report
            count = 0;
            if opt.ParseDisp,
                objRep = report.object.new(obj);
                
                parentFname = fid2fname(fid);
                
                if ~isnan(parentFname),
                    objRep = childof(objRep, parentFname);
                end
                initialize(objRep);
                generate(objRep);
                [~, repName] = fileparts(get_filename(objRep));
                count = count + ...
                    fprintf(fid, '[%s](%s)', class(obj), [repName '.htm']);
            end
            
            if opt.SaveBinary,
                fName = rel2abs(fid2fname(fid));
                rPath = fileparts(fName);
                
                % Save binary data
                dataName    = get_name(obj);
                
                newDataFile = unique_filename(catfile(rPath, [dataName '.mat']));               
                save(newDataFile, 'obj');
                
                count = count + fprintf(fid, '\n%-20s: [%s][%s]\n\n', ...
                    'Binary object', [dataName '.mat'], [dataName '-data']);
                
                count = count + fprintf(fid, '[%s]: %s\n', [dataName '-data'], ...
                    [dataName '.mat']);
                
                count = count + fprintf(fid, '\n\nTo load to MATLAB''s workspace:\n\n');
                
                count = count + fprintf(fid, '[[Code]]:\n');
                
                code  = sprintf('bss = load(''%s'', ''obj'')', newDataFile);
                code  = code2multiline(code, [], char(9));
                count = count + fprintf(fid, '%s\n\n', code);                
              
                % Try to overcome a problem in remark when a code snippet is followed
                % by a gallery
                count = count + fprintf(fid, '&nbsp;&nbsp;\n');
            end
   
        end
        
    end
    
    
    
end