function bool = has_ssh()

msg = evalc('system(''ssh'')');
bool = isempty(strfind(msg, 'command not found'));

end