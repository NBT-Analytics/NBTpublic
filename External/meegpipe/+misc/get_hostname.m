function name = get_hostname

[ret, name] = system('hostname');

if ret
  if ispc,
      name = getenv('COMPUTERNAME');
  else
      name = getenv('HOSTNAME');
  end
end

name = regexprep(name, '[^.\w\d]', '');
   


end