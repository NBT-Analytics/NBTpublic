function coords = cartesian(varargin)
% Returns cartesian coordinates

import misc.process_arguments;

InvalidCoordinates = MException(...
    'misc:cartesian:InvalidCoordinates', ...
    'Invalid coordinates: cannot convert to Cartesian');

opt.cartesian   = [];
opt.spherical   = [];
opt.polar       = [];

[~, opt] = process_arguments(opt, varargin);


if isempty(opt.cartesian),
    if isempty(opt.spherical),
        if isempty(opt.polar),
            coords = [];
            return;
        elseif ~isnumeric(opt.polar) || ...
                size(opt.polar, 2) ~= 3,
            throw(InvalidCoordinates);
        else
            coords = nan(size(opt.polar));
            [coords(:,1), coords(:,2), coords(:,3)] = ...
                pol2cart(opt.polar(:,1), ...
                opt.polar(:,2), opt.polar(:,3));
        end
    elseif ~isnumeric(opt.spherical) || ...
            size(opt.spherical,2)~=3,
        throw(invalidSensorCoordinates);
    else
        if ~isempty(opt.polar),
            warning('misc:cartesian:AmbiguousCoordinates', ...
                ['Multiple coordinates were provided: ' ...
                'using the provided spherical coordinates']);
        end
        coords = nan(size(opt.spherical));
        [coords(:,1), coords(:,2), coords(:,3)] = ...
            sph2cart(opt.spherical(:,1), opt.spherical(:,2), ...
            opt.spherical(:,3));
    end
else
    if ~isempty(opt.spherical) || ~isempty(opt.polar),
        warning('misc:cartesian:AmbiguousArguments', ...
            ['Multiple coordinates were provided: ' ...
            'using the provided cartesian coordinates']);
    end
    coords = opt.cartesian;
end


end