classdef percentile < goo.verbose
    
    properties
        Estimator;
    end
    
    methods
        function dspData = psd(obj, varargin)
            import misc.process_arguments;
            import misc.split_arguments;
            import misc.eta;
            
 
            if nargin < 2,
                dspData = [];
                return;
            end
            
            data = cell(nargin-1,1);
            count = 1;
            
            while count < nargin && isnumeric(varargin{count})
                data{count} = varargin{count};
                count = count + 1;
            end
            data(count:end) = [];
            varargin(1:count-1) = [];
            
            opt.Fs              = 'Normalized';
            opt.SpectrumType    = 'Onesided';
            opt.CenterDC        = false;
            opt.Normalize       = true; % Normalize variance?
            opt.Percentile      = [25 75];
            
            THIS_PROPS = {'Percentile'};
            % There is a bug here, this doesnt work if you set Normalize to
            % false. Fix that at some point! In general this function
            % requires heavy cleaning.        
            [~, opt] = process_arguments(opt, varargin);

            if numel(data) == 1 && size(data{1},2)>size(data{1},1) && ...
                    size(data{1},1)>1
                data = mat2cell(data{1}, ones(size(data{1},1),1));
                dspData = psd(obj, data{:}, varargin{:}); %#ok<*FDEPR>
                return;
            elseif numel(data) > 1 && size(data{1},1) > 1,
               
                dspData       = psd(obj, data{1}, varargin{:});
                allData       = nan(1, numel(dspData.Data));
                allData(1,:)  = dspData.Data;
                
                for j = 2:numel(data)
                    tmp = psd(obj, data{j}, varargin{:});
                    %minData  = min(minData,tmp.ConfInterval(:,1));
                    %maxData  = max(maxData,tmp.ConfInterval(:,2));
                    allData(j,:) = tmp.Data;
                end
                medianData = median(allData,1);
                dspData = dspdata.psd(medianData, dspData.Frequencies, ...
                    'Fs', opt.Fs, 'SpectrumType', opt.SpectrumType, ...
                    'CenterDC', opt.CenterDC);
                dspData.ConfLevel = opt.Percentile(2)/100;
                confInt = [prctile(allData, opt.Percentile(1), 1)', ...
                prctile(allData, opt.Percentile(2), 1)'];
            
                dspData.ConfInterval = confInt;
                return;
            end
            
            tic;
            
            dataVar = 0;
            count = 0;
            while (dataVar < eps && count < numel(data)),
                count = count + 1;
                dataVar = var(data{count}, [], 2);
            end
            if dataVar < eps,
                warning('spectrum2:minmax:NoData', ...
                    'All data is <eps. Nothing was plotted');
                dspData = [];
                return;
            end
           
            [~, otherArgs] = split_arguments(THIS_PROPS, varargin);
         
            Hpsd = psd(obj.Estimator, data{count}, otherArgs{:});
           
            if is_verbose(obj) && toc*numel(data) > 10,
                verbose = true;
            else
                verbose = false;
            end
            allData = nan(numel(data), numel(Hpsd.Data));
            
            tinit       = tic;
            psdCount    = 0;

            
            for i = 1:numel(data)
                data{i} = data{i} - mean(data{i});
                thisVar = var(data{i}, [], 2);
                
                % Ignore weird channels? From where could these come from??
                if any(isnan(data{i})) || any(isinf(data{i})),
                    warning('spectrum2:minmax:IgnoredChannel', ...
                        ['\nSignal %d contains NaNs and/or Inf values. ' ...
                        'It will be ignored'], i)
                    continue;
                end
                
                % Ignore flat channels
                if thisVar < eps,
                    continue;
                end
                
                if opt.Normalize ,
                    thisData = data{i}*(1./sqrt(thisVar));
                else
                    thisData = data{i};
                end
                
                [~, otherArgs] = split_arguments(THIS_PROPS, varargin);
                Hpsd = psd(obj.Estimator, thisData, otherArgs{:});
                
                
                psdCount = psdCount + 1;
                allData(psdCount,:) = Hpsd.Data;
                
                if verbose,
                    eta(tinit, numel(data), i);
                end
            end
            if verbose,
                fprintf('\n');
            end
            allData = allData(1:psdCount, :);
            
            if psdCount > 1,
                medianData = median(allData,1);
            else
                medianData = allData;
            end
            dspData = dspdata.psd(medianData, Hpsd.Frequencies, ...
                'Fs', opt.Fs, 'SpectrumType', opt.SpectrumType, ...
                'CenterDC', opt.CenterDC);
            
            if psdCount > 1,
                dspData.ConfLevel = opt.Percentile(2)/100;
                
                confInt = [prctile(allData, opt.Percentile(1), 1)', ...
                    prctile(allData, opt.Percentile(2), 1)'];
                
                dspData.ConfInterval = confInt;
            end
           
        end
    end
    
    % Constructor
    methods
        function obj = percentile(varargin)
            import misc.process_arguments;
            opt.Estimator = spectrum.welch;
            [~, opt] = process_arguments(opt, varargin);
            obj.Estimator = opt.Estimator;
        end
    end
    
    
end