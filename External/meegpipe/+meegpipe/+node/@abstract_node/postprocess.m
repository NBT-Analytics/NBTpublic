function data = postprocess(obj, data)
% POSTPROCESS - Postprocesses data after method process()
%
% data = postprocess(obj, data)
%
% See also: preprocess

import goo.pkgisa;

if has_runtime_config(obj)
    % Information on how to modify the automatic selection  
    ini = get_ini_filename(obj);
    rep = get_report(obj);
    
    print_title(rep, 'User-defined behavior', 2);
    
    print_paragraph(rep, ...
        'To manually modify runtime parameters of this node:');
    
    print_code(rep, sprintf('\tedit(''%s'');',  ini));
    
    print_paragraph(rep, ['Note that you may need to edit the absolute ' ...
        'path above if this report has been moved from its original ' ...
        'location']);   
end


end