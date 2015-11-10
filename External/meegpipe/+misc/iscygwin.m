function y = iscygwin()


[status, value] = system('uname');
y = false;
if status,    
    return;
end

if ~isempty(strfind(lower(value), 'cygwin')),
    y = true;
end



end