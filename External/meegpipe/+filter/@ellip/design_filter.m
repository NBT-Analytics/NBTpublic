function [H, specs, order, delay] = design_filter(wn, rp, rs, maxOrder)

if nargin < 4, maxOrder = 30; end

if any(wn > 1),
    error('Invalid band edges: %s', misc.any2str(wn));
end

if any(wn < 0),
    type = 'stop';
    % How the hell do you do this?? The MATLAB docs are not clear:
    % http://www.mathworks.nl/help/signal/ref/ellipord.html
    error('Not implemented yet!');
elseif wn(1) < eps,
    type = 'low';
    wp = wn(2);
    ws = 1.01*wp;
elseif (1-wn(2)) < eps,
    type = 'high';
    wp = wn(1);
    ws = 0.99*wp;
else
    type = 'pass';
    wp = wn;
    ws = [0.99*wn(1) 1.01*wn(2)];
end

% Find the filter order that meets (approximately) the specs
order = ellipord(wp, ws, rp, rs);

while order > maxOrder && order > 2,
    switch type,
        case 'low'
            ws = ws*1.01;
            order = ellipord(wp, ws, rp, rs);
            
        case 'high'
            ws = 0.99*ws;
            order = ellipord(wp, ws, rp, rs);
            
        case 'pass'
            ws(1) = 0.99*ws(1);
            ws(2) = 1.01*ws(2);
            order = ellipord(wp, ws, rp, rs);
    end
end

% Design the filter
switch type
    case 'low'
        specs = fdesign.lowpass('Fp,Fst,Ap,Ast', wp, ws, rp, rs);
    case 'high'
        specs = fdesign.highpass('Fst,Fp,Ast,Ap', ws, wp, rs, rp);
    case 'pass'
        specs = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2', ...
            ws(1), wp(1), wp(2), ws(2), rs, rp, rs);
    otherwise,
        error('Invalid filter type: %s', type);
        
end

H = design(specs, 'ellip');

[Gd,W] = grpdelay(H, 256);

% Group delay of the filter within the passband
switch type
    case 'low'
        grpDelay = Gd(W < ws);
    case 'high'
        grpDelay = Gd(W > wp);
    case 'pass'
        grpDelay = Gd(W > wp(1) & W < wp(2));
        
    otherwise,
        error('Invalid filter type: %s', type);
        
end
grpDelayRange = range(grpDelay);
if grpDelayRange > 5,
    warning('design_filter:VariableGroupDelay', ...
        ['Filter group delay within the passband has a range of %d samples.\n', ...
        'You may need to use filtfilt() to correct for filter delays'], ...
        round(grpDelayRange));
end
delay = round(median(grpDelay));

end


