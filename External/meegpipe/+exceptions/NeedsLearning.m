function obj = NeedsLearning(msg)

if nargin < 1 || isempty(msg),
    msg = '??';
end

[st, i] = dbstack;

if numel(st) > i,
    st   = st(i+1);
    name = strrep(st.name, '.', ':');
else
    name = 'base';
end

obj = MException([name ':NeedsLearning'], ...
    'Needs learning: %s', msg);

end
