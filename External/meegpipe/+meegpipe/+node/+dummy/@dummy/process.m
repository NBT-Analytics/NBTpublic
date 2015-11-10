function [data, dataNew] = process(obj, data, varargin)

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

dataNew = [];

if verbose,
    
    [~, fname] = fileparts(data.DataFile);
    fprintf([verboseLabel 'Doing nothing on ''%s''...'], fname);

end

% Here you could do anything you want with data  
% Note that data is a physioset object. If you don't know how 
% to work with physiosets then you can just de-reference the 
% specific set of data that you are processing:
%
% for i = 1:size(data,1)
%     data(i,:) = do_something(data(i,:));
% end
%
% Or you could simply de-reference the whole dataset and 
% work with that:
%
% dataMatrix = data(:,:); % dataMatrix is just a built-in numeric matrix
% processedDataMatrix = do_something(dataMatrix);
% data(:,:) = processedDataMatrix; % Store result in the physioset object
%
% But remember that data may be very large so you should de-reference 
% a whole physioset only when strickly necessary

if verbose, fprintf('[done]\n\n'); end



end