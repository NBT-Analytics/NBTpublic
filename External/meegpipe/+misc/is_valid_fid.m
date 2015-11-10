function valid = is_valid_fid(fid)
% IS_VALID_FID - Check if a file identifier is valid
%
% valid = is_valid_fid(fid)
%
% Where
%
% FID is a file identifier
%
% VALID is true if FID is a valid file identifier or is false otherwise
%
%
% See also: misc

% Documentation: pkg_misc.txt
% Description: Check if a file identifier is valid

if fid > 2
    try
        ftell(fid);
        valid = true;
    catch ME
        if regexpi(ME.identifier, '^MATLAB:badfid'),
            valid = false; 
        else
            rethrow(ME);
        end
    end
else
    valid = false;
end

end