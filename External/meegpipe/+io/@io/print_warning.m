function [status, ME] = print_warning(obj, method, msg)

status = 0;
ME = [];
try
    metaObj = meta.class.fromName(class(obj));
    warnId = sprintf('%s:%s:%s', ...
        metaObj.ContainingPackage.Name, ...
        class(obj), ...
        method);
    evalin(sprintf('warning(''%s'', ''%s'')', warnId, msg), 'caller');  
catch ME
    warning('io:io:print_warning', ...
        'Unable to write warning to fid=%d', obj.Fid);
    status = 1;
end