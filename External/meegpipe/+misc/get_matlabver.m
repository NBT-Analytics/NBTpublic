function y = get_matlabver

y = regexprep(version, '.+\((\w+)\).*', '$1');

end