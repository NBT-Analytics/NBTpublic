function count = print_gallery(obj, galleryObj)
% PRINT_GALLERY - Print a gallery of images to report
%
% count = print_gallery(obj, galleryObj)
%
% Where
%
% GALLERYOBJ is a gallery object.
%
% COUNT is the number of characters actually written to the report file.
%
% See also: gallery

% Description: Print a gallery of images to report
% Documentation: class_abstract_generator.txt


count = fprintf(get_fid(obj), galleryObj);


end