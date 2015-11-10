function origStatus = set_warning_status(id, status)

if ischar(status),
    status = {status};
end

if numel(status) == 1, status = repmat(status, 1, numel(id)); end

origStatus = cell(1, numel(id));
for i = 1:numel(id)
   str = warning('query', id{i});
   origStatus{i} = str.state;
   warning(status{i}, id{i});
end

end