function end_document(obj)

if isempty(obj.FID), return; end

fprintf(obj.FID, '\n%s\n\n', '\end{document}');

obj.FID = [];

end
