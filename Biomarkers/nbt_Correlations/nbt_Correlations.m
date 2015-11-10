
classdef nbt_Correlations < nbt_Biomarker  % define here the name of the new object, here we choose nbt_Biomarker_template
    properties
        % add here the fields that are specific for your biomarker.
        %See the definition of nbt_Biomarker for fields that are allready there. For example:
        Between_Channels
        Between_Channels_P_values
    end
    methods
        % Now follows the definition of the function that makes a biomarker
        % of the type "nbt_Biomarker_template". The name of this function should alway be
        % the same as the name of the new biomarker object, in this example nbt_Biomarker_template
        % The inputs contain the information you want to add to the biomarker object :
        function BiomarkerObject =nbt_Correlations(Between_Channels,Between_Channels_P_values)
            
            % assign values that each biomarker object has, for example:
            BiomarkerObject.Between_Channels = Between_Channels;
            BiomarkerObject.Between_Channels_P_values=Between_Channels_P_values;
            
%             for i =1:size(Between_Channels,1)
%             BiomarkerObject.Biomarkers{i} =strcat('Between_Channels(',num2str(i),',:)');
%             end
BiomarkerObject.Biomarkers = {'Between_Channels'};
        end
    end
    
end

