function bool = has_plink()

[success, msg] = system('plink');

bool = success & ~isempty(strfind(lower(msg), 'putty'));
 


end