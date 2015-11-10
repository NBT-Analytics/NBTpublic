function obj = InvalidArgValue(arg, msg)

[st, i] = dbstack;

st   = st(i+1);
name = strrep(st.name, '.', ':');

obj = MException([name ':InvalidArgValue'], ...
    'Invalid value for argument ''%s'': %s', arg, msg);

end