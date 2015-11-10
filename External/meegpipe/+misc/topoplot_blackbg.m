function topoplot_blackbg(h)
import misc.topoplot_blackbg;
import misc.euclidean_dist;

for i = 1:numel(h),
    thisProp = get(h(i));
    if isfield(thisProp, 'FaceColor')        
        if isnumeric(thisProp.FaceColor) && ...
                euclidean_dist(thisProp.FaceColor, [237 245 255]/255)<0.1
            set(h(i), 'FaceColor', 'black');
        end
    end
    if isfield(thisProp, 'Children'),
        for j = 1:numel(thisProp.Children)
            topoplot_blackbg(thisProp.Children(j));
        end
    end
end

end