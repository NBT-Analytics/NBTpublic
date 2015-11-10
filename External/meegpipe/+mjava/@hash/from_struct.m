function obj = from_struct(str)

keys = fieldnames(str);

obj = mjava.hash;

s.type = '()';
for i = 1:numel(keys)
    s.subs = keys(i);
    obj = subsasgn(obj, s, str.(keys{i}));
end


end