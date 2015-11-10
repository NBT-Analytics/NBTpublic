function hdr = signal_info(filename)

import misc.dir;
import mperl.split;

% Note: For some unknown reason, '^info\d\.xml$', which would be more
% appropriate, fails in some Mac systems
infoFiles = dir(filename, '^info.\.xml$', true);

if isempty(infoFiles),
    infoFiles = dir(filename, '[^_]info\d\.xml$', true);
end

hdr = cell(size(infoFiles));

for i = 1:numel(hdr),    
   res = perl('+io/+mff2/private/parse_signal_info.pl', ...
        filename, num2str(i));   
   res = split(char(10), res);
   for j = 1:numel(res)
      thisRes = split(';', res{j});     
      tmp.(thisRes{1}) = thisRes{2}; 
   end
   hdr{i} = tmp;
end

%if numel(hdr) == 1, hdr = hdr{1}; end

end