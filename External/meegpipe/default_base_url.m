function y = default_base_url
% DEFAULT_BASE_URL - The default stem for every repositories' URLs
%
% If the user does not provide any URL when using submodule_add, a default
% URL will be constructed by appending the dependency name to the output of
% default_base_url
%
% See also: submodule_adds

y = 'http://germangh@github.com/germangh/matlab_';

end
