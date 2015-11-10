function [gcalOut, icalOut] = read_cal(filename)

import mperl.split;

res = perl('+io/+mff2/private/parse_cal.pl', filename);

if isempty(res),
    gcalOut = [];
    icalOut = [];
    return;
end

cals = split([char(10) char(10) char(10)], res);

gcal = str2num(cals{1}); %#ok<*ST2NM>
gcalOut = mjava.hash;
gcalOut{round(gcal(:,1))} = num2cell(gcal(:,2));

icalOut = [];
if numel(cals) > 1,
    ical = str2num(cals{2});
    
    icalOut = mjava.hash;
    icalOut{round(ical(:,1))} = num2cell(ical(:,2));
end





end