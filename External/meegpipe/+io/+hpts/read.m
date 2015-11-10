function [xyz, cat, id] = read(file)

fid = fopen(file, 'r');
C = textscan(fid, '%s %s %f %f %f', 'CommentStyle', '#');
fclose(fid);

xyz = cell2mat(C(3:end));

cat = C{1};

id = C{2};

end