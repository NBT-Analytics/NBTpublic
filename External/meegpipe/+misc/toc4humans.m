function str = toc4humans(ttoc)
% TOC4HUMANS - Time duration as a human-readable string

ttoc    = double(ttoc);
ndays   = floor(ttoc/(3600*24));
ttoc    = ttoc - ndays*(3600*24);
nhours  = floor(ttoc/(3600));
ttoc    = ttoc - nhours*3600;
nmins   = floor(ttoc/(60));
ttoc    = ttoc - nmins*60;
nsecs   = round(ttoc);

if ndays > 0,
    str = sprintf('%dd %dh %dm %ds', ndays, nhours, nmins, nsecs);
elseif nhours > 0,
    str = sprintf('%dh %dm %ds', nhours, nmins, nsecs);
elseif nmins > 0,
    str = sprintf('%dm %ds', nmins, nsecs);
elseif nsecs > 0
    str = sprintf('%ds', nsecs);
else
    str = '0s';
end


end