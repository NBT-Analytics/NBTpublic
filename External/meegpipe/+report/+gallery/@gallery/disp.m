function disp(obj)

import misc.cell2str;

if usejava('Desktop'),
    
    disp(...
        ['<a href="matlab:help ' class(obj) '">' class(obj) '</a> ' ...
        '<a href="matlab:help handle">handle</a>'] ...
        );
    
    disp('Package: <a href="matlab: help report">report</a>');
    
else
    % Hyperlinks are messed if MATLAB started without a display
    
    disp([class(obj) ' handle']);
    
    disp('Package: report');
    
end

fprintf('\n\n');

disp_body(get(obj));

% Print some other useful pieces of information
fprintf('%20s : %d\n',  '# of figures',    nb_figures(obj));

fprintf('\n');

end