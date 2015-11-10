function colorbar(obj)
import misc.exception2str;

try
    obj.ColorBar = colorbar;
catch ME
    warning('topography:colobar', ...
        'colorbar threw the following exception: %s', exception2str(ME));
end


end