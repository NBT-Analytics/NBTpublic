function [ev, meta] = read_events(~, fileName, pObj, varargin)

import safefid.safefid;
import mperl.file.spec.catfile;
import mperl.split;

meta = [];

NB_EVENTS = 10000;

[path, name] = fileparts(fileName);

fileName = catfile(path, [name '.events.csv']);

if ~exist(fileName, 'file'),
    ev = [];
    return;
end

fid = safefid(fileName, 'r');

fgetl(fid);
sampl  = nan(1, NB_EVENTS);
evType = cell(1, NB_EVENTS);
count = 0;
tline = fgetl(fid);
while ~isnumeric(tline)
    count = count + 1;
    items = split(',', tline);
    evType{count} = items{2};
    dateTokens = split(':', items{1});
    offset = str2double(dateTokens{1})*3600 + ...
        str2double(dateTokens{2})*60 + ...
        str2double(dateTokens{3});
    sampl(count) = round(pObj.SamplingRate*offset);
    tline = fgetl(fid);
end

if count < 1, 
    ev = []; 
    return;
end

sampl(count+1:end) = [];

ev = physioset.event.event(sampl);
for i = 1:count
    ev(i).Type = evType{i};
end