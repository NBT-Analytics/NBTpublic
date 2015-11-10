function set_confint(obj, ~, ~)

value = get_config(obj, 'ConfInt');
if value, 
    value = 'on';
else
    value = 'off';
end

for i = 1:size(obj.Line,1)
    % Change visibility of shadows/edges
    if ~isempty(obj.Line{i, 2}),
        set(obj.Line{i,2}, 'Visible', value);
        set(obj.Line{i,3}, 'Visible', value);       
    end            
end

plot_legend(obj);



end