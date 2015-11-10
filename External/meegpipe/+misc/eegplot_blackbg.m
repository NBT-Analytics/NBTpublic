function eegplot_blackbg(h)

BGCOLOR = [0 0 0];
FGCOLOR = [1 1 1];

set(h, 'Color', BGCOLOR);

children = get(h, 'Children');

for i = 1:numel(children)    
    thisChild = children(i);
    tag = get(thisChild, 'Tag');
    
    if strmpci(tag, 'eyeaxes'), 
        subChildren = get(thisChild, 'Children');
        for j = 1:numel(subChildren),
            set(subChildren, 'Color', FGCOLOR);
        end
    elseif strcmpi(tag, 'backeeg'),
        set(thisChild, 'Color', BGCOLOR);
    elseif strcmpi(tag, 'eegaxis'),
        subChildren = get(thisChild, 'Children');
        for j = 1:numel(subChildren),
            set(subChildren, 'Color', FGCOLOR);
        end
        
    end
        
        
    
end

end