function obj = InvalidObject(msg)

if nargin < 1 || isempty(msg),
    msg = '??';
end

[st, i] = dbstack;

st   = st(i+1);
name = strrep(st.name, '.', ':');

obj = MException([name ':InvalidObject'], ...
    'Invalid object: %s', msg);

end
