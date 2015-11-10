function pkgName = parse_pkg_name(mfile)


this = strrep(mfile, '\', '/');

if isempty(regexp(this, '[^+]*+\+([^@]+)/.+$', 'once'))
    thisPkg = ''; 
else
    thisPkg = regexprep(this, '[^+]*+\+([^@]+)/.+$', '$1');
end

pkgName = strrep(thisPkg, '/+', '.');



end