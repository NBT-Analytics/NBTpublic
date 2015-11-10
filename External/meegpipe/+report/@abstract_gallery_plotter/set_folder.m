function obj = set_folder(obj, folder)

tmp = get_config(obj);
if ~exists(tmp, 'Folder'),
    error(['Don''t know how to set the Folder property ' ...
        'for this class. Did you forget to implement ' ...
        'method set_folder?']);
end
obj = set_config(obj, 'Folder', folder);

end