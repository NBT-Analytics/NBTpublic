function bool = has_pscp()

[success, msg] = system('pscp');

bool = success & ~isempty(strfind(lower(msg), 'putty'));
 

end