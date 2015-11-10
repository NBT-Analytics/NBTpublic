function dirName = root_repo_path()

dirName = regexprep(meegpipe.root_path, '.\+meegpipe$', '');

end