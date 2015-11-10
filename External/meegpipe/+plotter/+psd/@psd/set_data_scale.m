function set_data_scale(obj, ~, ~)

logData   = get_config(obj, 'LogData');
normScale = get_config(obj, 'NormalizeScale');

if isempty(obj.Data),
    return;
end

if logData,
    func  = @(x) 10*log10(x);   
    set_ylabel(obj, 'String', 'Power/frequency (dB/Hz)');
else
    func  = @(x) x;   
    set_ylabel(obj, 'String', 'Power/frequency (u^2/Hz)');
end

if normScale,
  
    % Normalize so that average power is 1 for all PSDs   
    func2 = cell(numel(obj.Data),1);
    for i = 1:numel(obj.Data)
        
        normFactor = avgpower(obj.Data(i));
        func2{i}  = @(x) func(x/normFactor);
     
    end
    
else
    
   func2  = repmat({func}, numel(obj.Data), 1); 

end

for i = 1:numel(obj.Data)
    thisData = obj.Data(i).Data;        
    set_line(obj, i, 'YData', func2{i}(thisData));
    
    % Do the same for the edges
    if ~isempty(obj.Line{i,3}),
           %thisData = get(obj.Line{i,3}(1), 'YData');    
           confInt = get(obj.Data(i), 'ConfInterval');
           set(obj.Line{i,3}(1),'YData', func2{i}(confInt(:,1)));      
           %thisData = get(obj.Line{i,3}(2), 'YData');    
           set(obj.Line{i,3}(2),'YData', func2{i}(confInt(:,2)));      
    end
    
    % And for the shadows
    if ~isempty(obj.Line{i,2})
       %thisData = get_shadow(obj, i, 'YData');
      
       nbFreqs = numel(obj.Data(i).Frequencies);
       shadowData = nan(nbFreqs*2, 1);
       shadowData(1:nbFreqs)     = func2{i}(confInt(:,1));
       shadowData(nbFreqs+1:end) = func2{i}(flipud(confInt(:,2)));
       set_shadow(obj, i, 'YData', shadowData);
       
    end
    
end



end