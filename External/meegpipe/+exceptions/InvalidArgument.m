function obj = InvalidArgument(arg, msg)

[st, i] = dbstack;

st   = st(i+1);
name = strrep(st.name, '.', ':');

obj = MException([name ':InvalidArgument'], ...
    'Invalid argument ''%s'': %s', arg, msg);

end
