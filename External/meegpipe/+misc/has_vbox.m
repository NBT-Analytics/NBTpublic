function bool = has_vbox()

[~, msg] = system('VBoxManage');

bool = ~isempty(strfind(lower(msg(1:300)), 'oracle'));
 


end