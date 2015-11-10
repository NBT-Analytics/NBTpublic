function count = print_link2report(rep, target, name)


if nargin < 3, name = ''; end

if isa(target, 'report.report'),
    targetTitle     = get_title(target);
    targetRef       = get_ref(target);
    targetFileName  = get_filename(target);  
elseif ischar(target),
    targetTitle     = target;
    targetRef       = target;
    targetFileName  = target;
else
    error('don''t be naughty'); 
end

if isempty(name), name = targetTitle; end

count = ...
    print_paragraph(rep, '[%s][%s]', name, targetRef);

count = count + ...
    print_ref(rep, targetFileName, targetRef);



end