function [B, A] = get_coefficients(filterOrder, fp)

if any(fp < 0),
    % a stopband filter
    [B, A] = butter(filterOrder, -fp, 'stop');
    return;
end

if fp(1) < eps,
    [B, A] = butter(filterOrder, fp(2), 'low');
elseif (1-fp(2)) < eps
    [B, A] = butter(filterOrder, fp(1), 'high');
else
    [B, A] = butter(filterOrder, fp);
end


end