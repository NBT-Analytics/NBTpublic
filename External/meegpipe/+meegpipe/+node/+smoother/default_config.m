function value = default_config(param)


switch lower(param),
    case 'mergewindow',
        value = 0.25;
    case 'eventselector',
        value = physioset.event.class_selector('Class', 'discontinuity');
    otherwise,
        throw(exceptions.InvalidProp(param));
end

end