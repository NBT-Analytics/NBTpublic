function disp_body(obj)
 
import misc.any2str;

import misc.dimtype_str;

fprintf('%20s : %s\n',  'Name',           get_full_name(obj));

if ~isempty(obj.DataSelector),
    
    fprintf('%20s : [%s]\n',  'DataSelector', ...
        dimtype_str(obj.DataSelector, true));
end

fprintf('%20s : %s\n',  'Initialized', bool2str(initialized(obj)));
fprintf('%20s : %s\n',  'IOReport', bool2str(~isempty(get_io_report(obj))));
fprintf('%20s : %s\n',  'GenerateReport', bool2str(obj.GenerateReport));
fprintf('%20s : %s\n',  'Parallelize', bool2str(obj.Parallelize));
fprintf('%20s : %s\n',  'Queue', get_queue(obj));
fprintf('%20s : %s\n',  'Save', bool2str(obj.Save));
fprintf('%20s : %s\n',  'TempDir', any2str(obj.TempDir));
if ~isempty(obj.FakeID),
   fprintf('%20s : %s\n',  'FakeID', obj.FakeID); 
end
 

end



function str = bool2str(bool)

if bool,
    str = 'yes';
else
    str = 'no';
end

end

