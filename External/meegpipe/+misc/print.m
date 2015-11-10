function print(varargin)
% PRINT - Like MATLAB's built-in but a bit more robust

import misc.warning2error;

try    
    
    warning2error('print(varargin{:})', 'MATLAB:glren:print');
   
catch ME
    
    try         
        
        if ~isunix,
            opengl software;
            print(varargin{:});
            opengl hardware;
        else
            rethrow(ME);
        end
        
    catch ME
        
        if ~isunix,
            opengl hardware;
        end
        
        try
            
            print_inkscape(varargin{:});
                        
        catch ME
            
            % Last resort, delete all transparent elements and try again
            try
                
                if nargin < 0 && isnumeric(varargin{1}),
                    h = varargin{1};
                else
                    h = gcf;
                end
                hT1 = findobj(h, '-property', 'FaceAlpha');
                hT2 = findobj(h, '-property', 'EdgeAlpha');
                delete([hT1(:);hT2(:)]);                
                print(varargin{:});
                warning('misc:print:NonTransparentOnly', ...
                    'I could not print any transparent element');
            catch ME
                
                rethrow(ME);                
                
            end
                
            
        end
    end
    
end



end




function print_inkscape(varargin)

import plot2svg.plot2svg;
import inkscape.*;

if nargin < 0 && isnumeric(varargin{1}),
    h = varargin{1};
else
    h = gcf;
end

driver = '';
res    = [];
fName = '';

for i = 1:numel(varargin)
   
     if ~ischar(varargin{i}), continue; end
     
     if ~isempty(regexp(varargin{i}, '^-d(\w+)$', 'once')),
         driver = regexprep(varargin{i}, '^-d(\w+)$', '$1');
     end
     if ~isempty(regexp(varargin{i}, '^-r(\d+)$', 'once')),
         res    = regexprep(varargin{i}, '^-r(\d+)$', '$1');
     end
     if ~isempty(regexp(varargin{i}, '^[^-].+', 'once')),
         fName = varargin{i};
     end          
        
end

if isempty(driver) || ~ismember(driver, {'png', 'eps', 'epsc', 'pdf'}),
    throw(MException('misc:print:UnableToPrint', ...
        'I tried lots of things but could not print the figure'));
end

if isempty(res),
    res = 300;
else
    res = eval(res);
end

% Plot a temporary svg file
tmpFName = [tempname '.svg'];
plot2svg(tmpFName, h);

% And convert to desired format 
switch lower(driver)
   
    case 'png'
        svg2png(tmpFName, fName, res);
    case 'pdf'
        svg2pdf(tmpFName, fName);
    case {'epsc', 'eps'}
        svg2eps(tmpFName, fName);
end
    
delete(tmpFName);


end