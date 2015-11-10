function disp_meta(obj)

if ~isempty(obj.Info) && ~isempty(fieldnames(obj.Info)),
    disp(obj.Info);
end

end
