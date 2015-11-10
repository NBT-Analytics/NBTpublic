function set_visibility(obj, ~, ~)

if isempty(obj.Figure),
    return;
end

flag = get_config(obj, 'Visible');

if flag, 
    visible = 'on';
else
    visible = 'off';
end

set(obj.Figure, 'Visible', visible);


end