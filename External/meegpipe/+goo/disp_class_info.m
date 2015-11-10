function disp_class_info(obj)


if numel(obj) ~= 1,
    dims = [regexprep(num2str(size(obj)), '\s+', 'x') ' '];
else
    dims = '';
end

objClass = class(obj);

tmp = regexp(objClass, '(?<pkg>.+)?\.(?<class>[^.]+)$', 'names');

if usejava('Desktop'),
    
    disp([dims '<a href="matlab:help ' objClass '">' tmp.class '</a>']);
    disp(['Package: <a href="matlab:help ' tmp.pkg '">' tmp.pkg '</a>']);
    
else
    
    disp([dims tmp.class]);
    disp(['Package: ' tmp.pkg]);
    
end

fprintf('\n\n');


end