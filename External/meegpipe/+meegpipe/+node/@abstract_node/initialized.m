function bool = initialized(obj)

bool = ~isempty(obj.RootDir_) && exist(obj.RootDir_, 'dir');

end