function obj = Inconsistent(msg)

if nargin < 1 || isempty(msg),
    msg = '??';
end

[st, i] = dbstack;

if numel(st) < 2,
    name = 'Base';
else
    st   = st(i+1);
    name = strrep(st.name, '.', ':');
end

obj = MException([name ':Inconsistent'], ...
    'Inconsistent object: %s', msg);

end
