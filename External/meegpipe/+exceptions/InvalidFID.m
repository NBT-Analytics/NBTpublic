function obj = InvalidFID(fname)

if nargin < 1 || isempty(fname), fname = ''; end

[st, i] = dbstack;
st   = st(i+1);
name = strrep(st.name, '.', ':');

if isempty(fname),
    obj = MException([name ':InvalidFID'], ...
        'Invalid File Identifier');
else
    obj = MException([name ':InvalidFID'], ...
        'Invalid File Identifier for file ''%s''',  fname);
end

end