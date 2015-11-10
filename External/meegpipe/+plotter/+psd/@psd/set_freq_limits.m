function set_freq_limits(obj, ~, ~)

if isempty(obj.Data), return; end

value = get_config(obj, 'FrequencyRange');

value(1) = max(value(1), min(obj.Frequencies));
value(2) = min(value(2), max(obj.Frequencies));

set_axes(obj, 'XLim', value);

end