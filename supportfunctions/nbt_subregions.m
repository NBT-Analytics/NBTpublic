
function ind = nbt_subregions(nchannels,plotoption)
switch nchannels
    case 129
        ind{1}=[128,32,25,21,26,27,23,19,18,16,15,126,127,14,10,4,8,2,3,123,1,125,9,17,124,122,24,33,22];%frontal
        ind{2}=[48 43 38 49 44 39 34 28 40 35 56 50 46 51 47 41 45 57];% left temporal
        ind{3}=[42 29 20 12 5 118 11 93 54 37 30 13 6 112 105 87 79 31 7 106 80 55 36 104 111]; %central
        ind{4}=[117 110  103 98 116 109 102 97 108 115 121 114 100 107 113 120 119 101];%right temporal
        ind{5}=[63 68 64 58 65 59 66 52 60 67 72 53 61 62 78 86 77 85 92 84 91 90 96 95 94 99];%parietal
        ind{6}=[71  76 70 75 83 69 74 82 89 73 81 88];% occipital
        if exist('plotoption','var') &&  plotoption == 1
        for i = 1:6
            C = zeros(129,1);
            C(ind{i}) = 1;
            figure
            topoplot(C,'GSN-HydroCel-129.sfp','style','blank', 'electrodes','labels');
        end
        end
    otherwise
         ind = [];
      disp('Subregions configuration does not exist for this EEG set')
end