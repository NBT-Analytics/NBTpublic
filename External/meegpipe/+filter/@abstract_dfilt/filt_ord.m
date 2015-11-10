function [y, wp, ws, rp, rs] = filt_ord(designmethod, wp, ws, rp, rs, type)


max_filt_order = filter.globals.evaluate.MaxOrder;

switch lower(designmethod),
    case 'butter',
        y = buttord(wp, ws, rp, rs);
    case 'cheby1',
        y = cheb1ord(wp, ws, rp, rs);
    case 'cheby2',
        y = cheb2ord(wp, ws, rp, rs);
    case 'ellip',
        y = ellipord(wp, ws, rp, rs);
        
    otherwise,
        error('Unsupported filter design method ''%s''.', designmethod);
end
while y > max_filt_order,
    if strcmpi(type, 'low')
        ws = min(.99999, 1.05*ws);
    elseif strcmpi(type, 'high'),
        ws = max(0.00001, 0.95*ws);
    else
        error('Unknown filter type ''%s''.', type);
    end
    rs = max(0.95*rs, 20);
    rp = min(3, 1.01*rp);
    switch lower(designmethod),
        case 'butter',
            y = buttord(wp, ws, rp, rs);
        case 'cheby1',
            y = cheb1ord(wp, ws, rp, rs);
        case 'cheby2',
            y = cheb2ord(wp, ws, rp, rs);
        case 'ellip',
            y = ellipord (wp, ws, rp, rs);
            
        otherwise,
            error('Unsupported filter design method ''%s''.', designmethod);
    end
end