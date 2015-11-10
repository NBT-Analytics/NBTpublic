function obj = InvalidFileFormat(ext)

[st, i] = dbstack;

if numel(st) > i,
    st   = st(i+1);
    name = strrep(st.name, '.', ':');
else
    name = 'base';
end

obj = MException([name ':InvalidFileFormat'], ...
    'Invalid data file format ''%s''', ext);

end