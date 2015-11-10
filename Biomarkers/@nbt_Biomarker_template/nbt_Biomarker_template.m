
classdef nbt_Biomarker_template < nbt_Biomarker  % define here the name of the new object, here we choose nbt_Biomarker_template
    properties
        % add here the fields that are specific for your biomarker.
        %See the definition of nbt_Biomarker for fields that are allready there. For example:      
        SignalVariance
        SignalMean
        SignalMedian
    end
    methods
        % Now follows the definition of the function that makes a biomarker
        % of the type "nbt_Biomarker_template". The name of this function should alway be
        % the same as the name of the new biomarker object, in this example nbt_Biomarker_template
        
        function BiomarkerObject =nbt_Biomarker_template(NumChannels)
           
            % assign values for this biomarker object:
            BiomarkerObject.SignalVariance = nan(1,NumChannels); %note that using columns are more memory efficient than rows.
            BiomarkerObject.SignalMean = nan(1,NumChannels);
            BiomarkerObject.SignalMedian = nan(1,NumChannels);
            
            %make list of biomarkers in this object:
            BiomarkerObject.Biomarkers ={'SignalVariance','SignalMean','SignalMedian'};
        end
    end

end

