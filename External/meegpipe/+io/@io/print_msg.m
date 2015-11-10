function [status, ME] = print_msg(obj, method, msg)

status = 0;
ME = [];
try
    metaObj = meta.class.fromName(class(obj));
    msg = sprintf('\n(%s.%s.%s) %s \n', ...
        metaObj.ContainingPackage.Name, ...
        class(obj), ...
        method, ...
        msg);
    fprintf(obj.Fid, msg);    
catch ME
    warning('io:io:print_msg', ...
        'Unable to write message to fid=%d', obj.Fid);
    status = 1;
end


end