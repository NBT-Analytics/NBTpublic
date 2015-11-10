function [regionsOut, regions]= nbt_get_regions(channels,regions, SignalInfo)
error(nargchk(2,3,nargin));
%Regions
%1: Frontal
%2: Left temporal
%3: Central
%4: Right temporal
%5: Parietal
%6: Occipital

if (~iscell(regions)) %use 129 EGI system
    %     regions = cell(1,6);
    % regions{1}=[128,32,25,21,26,27,23,19,18,16,15,126,127,14,10,4,8,2,3,123,1,125,9,17,124,122,24,33,22];
    % regions{2}=[48 43 38 49 44 39 34 28 40 35 56 50 46 51 47 41 45 57];
    % regions{3}=[42 29 20 12 5 118 11 93 54 37 30 13 6 112 105 87 79 31 7 106 80 55 36 104 111];
    % regions{4}=[117 110  103 98 116 109 102 97 108 115 121 114 100 107 113 120 119 101];
    % regions{5}=[63 68 64 58 65 59 66 52 60 67 72 53 61 62 78 86 77 85 92 84 91 90 96 95 94 99];
    % regions{6}=[71  76 70 75 83 69 74 82 89 73 81 88];
    
    regions = cell(1,6);
    for i=1:length(SignalInfo.Interface.EEG.chanlocs)
        switch lower(SignalInfo.Interface.EEG.chanlocs(i).labels(1))
            case 'f'
                regions{1} = [regions{1}  i];
            case 't'
                if(length(SignalInfo.Interface.EEG.chanlocs(i).labels) == 2)
                    if(rem(str2double(SignalInfo.Interface.EEG.chanlocs(i).labels(2)),2))
                        %uneven
                        regions{2} = [regions{2}  i];
                    else
                        regions{4} = [regions{4}  i];
                    end
                elseif(length(SignalInfo.Interface.EEG.chanlocs(i).labels) == 3)
                    if(rem(str2double(SignalInfo.Interface.EEG.chanlocs(i).labels(3)),2))
                        %uneven
                        regions{2} = [regions{2}  i];
                    else
                        regions{4} = [regions{4}  i];
                    end
                elseif(length(SignalInfo.Interface.EEG.chanlocs(i).labels) == 4)
                    if(rem(str2double(SignalInfo.Interface.EEG.chanlocs(i).labels(3:4)),2))
                        %uneven
                        regions{2} = [regions{2}  i];
                    else
                        regions{4} = [regions{4}  i];
                    end
                end
            case 'c'
                regions{3} = [regions{3}  i];
            case 'p'
                regions{5} = [regions{5}  i];
            case 'o'
                regions{6} = [regions{6}  i];
        end
    end
    
end

for i=1:length(regions)
    regionsOut(i)=nanmedian(channels(regions{i}));
end