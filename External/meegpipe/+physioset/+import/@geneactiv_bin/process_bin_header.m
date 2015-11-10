function hdr = process_bin_header(hdrIn)

import misc.strtrim;

hdr.device          = [];
hdr.config          = [];
hdr.capabilities    = [];
hdr.trial           = [];
hdr.subject         = [];

for i = 1:numel(hdrIn)
    
    switch lower(hdrIn{i}.Page_Name),
        
        case 'device identity',
            
            fnames = fieldnames(hdrIn{i});
            for j = 1:numel(fnames)
                
                this = strtrim(hdrIn{i}.(fnames{j}));
                hdr.device.(lower(fnames{j})) = this;
                
            end
            
        case 'device capabilities',
            
            fnames = fieldnames(hdrIn{i});
            for j = 1:numel(fnames)
                
                this = strtrim(hdrIn{i}.(fnames{j}));
                hdr.capabilities.(lower(fnames{j})) = this;
        
            end
            
        case 'configuration info'
            
            fnames = fieldnames(hdrIn{i});
            for j = 1:numel(fnames)
                
                this = strtrim(hdrIn{i}.(fnames{j}));
                hdr.config.(lower(fnames{j})) = this;
                
                if ~isempty(regexpi(fnames{j}, 'frequency')),                
                    hdr.fs = str2double(regexprep(this, '(\d+)\s+Hz', '$1'));
                end
                if ~isempty(regexpi(fnames{j}, 'start_time')),
                    hdr.start_time = this;
                end                
                
            end
            
        case 'trial info'
            
            fnames = fieldnames(hdrIn{i});
            for j = 1:numel(fnames)
                
                this = strtrim(hdrIn{i}.(fnames{j}));
                hdr.trial.(lower(fnames{j})) = this;
                
            end
            
        case 'subject info'
            
            fnames = fieldnames(hdrIn{i});
            for j = 1:numel(fnames)
                
                this = strtrim(hdrIn{i}.(fnames{j}));
                hdr.subject.(lower(fnames{j})) = this;
                
            end
            
        case 'calibration data'
            
            fnames = fieldnames(hdrIn{i});
            for j = 1:numel(fnames)
                
                this = strtrim(hdrIn{i}.(fnames{j}));
                hdr.calib.(lower(fnames{j})) = this;
                
                        
                if ~isempty(regexpi(fnames{j}, 'x.+gain')),
                    hdr.x_gain = str2double(this);
                end
                if ~isempty(regexpi(fnames{j}, 'x.+offset')),
                    hdr.x_offset = str2double(this);
                end
                if ~isempty(regexpi(fnames{j}, 'y.+gain')),
                    hdr.y_gain = str2double(this);
                end
                if ~isempty(regexpi(fnames{j}, 'y.+offset')),
                    hdr.y_offset = str2double(this);
                end
                if ~isempty(regexpi(fnames{j}, 'z.+gain')),
                    hdr.z_gain = str2double(this);
                end
                if ~isempty(regexpi(fnames{j}, 'z.+offset')),
                    hdr.z_offset = str2double(this);
                end
                if ~isempty(regexpi(fnames{j}, '^volts$')),
                    hdr.volts = str2double(this);
                end
                if ~isempty(regexpi(fnames{j}, '^lux$')),
                    hdr.lux = str2double(this);
                end                
                
            end
            
        otherwise
            % ignore
            
    end
    
end



end