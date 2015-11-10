function obj = set_title(obj, title)
% SET_TITLE - Set the Title property
% 
% set_title(obj, title)
%
% Where
%
% TITLE is the report title (a string). The title property of a report
% generator will be used by method print_title() in the absence of a
% explitly provided report title.
%
% See also: print_title, get_title, abstract_generator

obj.Title = title;

end
