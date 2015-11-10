function value = get_static(obj, varargin)


if isempty(obj.Static_),
    obj.Static_ = get_static_config(obj);
end

value = val(obj.Static_, varargin{:});

end