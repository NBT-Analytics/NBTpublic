function obj = FailedSystemCall(call, msg)

[st, i] = dbstack;

st   = st(i+1);
name = strrep(st.name, '.', ':');

obj = MException([name ':FailedSystemCall'], ...
    'Failed system call ''%s'': %s', call, msg);

end