% nbt_PhaseLocking - Creates a Phase Locking biomarker object 
%
% Usage:
%   BiomarkerObject = nbt_PhaseLocking
%   or
%   BiomarkerObject = nbt_PhaseLocking(NumChannels)
% Inputs:
%   NumChannels
%
% Outputs:
%   PhaseLocking BiomarkerObject    
%
% Example:
%   
% References:
% 
% See also: 
%   nbt_CrossPhaseLocking
%  
  
%------------------------------------------------------------------------------------
% Originally created by Giuseppina Schiavone (2011), see NBT website (http://www.nbtwiki.net) for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) <year>  <Main Author>  (Neuronal Oscillations and Cognition group, 
% Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, 
% Neuroscience Campus Amsterdam, VU University Amsterdam)
%
% Part of the Neurophysiological Biomarker Toolbox (NBT)
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
% See Readme.txt for additional copyright information.
% -------------------------------------------------------------------------

    
classdef nbt_PhaseLocking < nbt_Biomarker  
    properties 
        
    Ratio 
    PLV 
    Instphase
%     frequencyRange 
    filterorder 
    interval 
%     synchlag
    IndexE %index based on the Shannon entropy
    IndexF %based on the intensity of the first Fourier mode of the distribution
    IndexCP %based on the conditional probability

    PLV_in_time
    time_int
    IndexE_in_time
    IndexCP_in_time
    IndexF_in_time
    end
    methods
       
        function BiomarkerObject = nbt_PhaseLocking(LengthSign,NumChannels)
            if nargin == 0
                LengthSign = 1;
                NumChannels = 1;
                
            
            end
            % assign values for this biomarker object:
            %% Define Phase Locking values
            BiomarkerObject.Ratio = nan(NumChannels,NumChannels);
            BiomarkerObject.PLV = nan(NumChannels,NumChannels);
            BiomarkerObject.Instphase = nan(LengthSign,NumChannels);
            BiomarkerObject.filterorder =  nan(1);
            BiomarkerObject.interval =  nan(1,2); 
%             BiomarkerObject.synchlag =  nan(2,NumChannels,NumChannels); 
            BiomarkerObject.IndexE = nan(NumChannels,NumChannels); %index based on the Shannon entropy
            BiomarkerObject.IndexCP = nan(NumChannels,NumChannels);%based on the conditional probability
            BiomarkerObject.IndexF = nan(NumChannels,NumChannels);%based on the intensity of the first Fourier mode of the distribution     
            %% Define fields for additional information
            BiomarkerObject.DateLastUpdate = datestr(now);

             BiomarkerObject.PLV_in_time = [];
             BiomarkerObject.time_int = [];
            BiomarkerObject.IndexE_in_time = [];
            BiomarkerObject.IndexCP_in_time = [];
            BiomarkerObject.IndexF_in_time = [];
            
            BiomarkerObject.PrimaryBiomarker = 'PLV';
            BiomarkerObject.Biomarkers = {'PLV','Instphase'};
           
            
        end
        function plot(obj)
            figure
            imagesc(obj.PLV')
            colorbar
            colormap(flipud(gray))
        end
        
        function plotPLV(obj)
            %for backward compatibility
            plot(obj)
        end
    end

end

