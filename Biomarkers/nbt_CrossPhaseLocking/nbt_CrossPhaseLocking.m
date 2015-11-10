% nbt_CrossPhaseLocking - Creates a Cross Phase Locking biomarker object 
%
% Usage:
%   BiomarkerObject = nbt_CrossPhaseLocking
%   or
%   BiomarkerObject = nbt_CrossPhaseLocking(NumChannels)
%
% Inputs:
%   NumChannels
%
% Outputs:
%   CrossPhaseLocking BiomarkerObject    
%
% Example:
%   
% References:
% 
% See also: 
%   nbt_PhaseLocking
%  
  
%------------------------------------------------------------------------------------
% Originally created by "your name" (2010), see NBT website (http://www.nbtwiki.net) for current email address
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

classdef nbt_CrossPhaseLocking < nbt_Biomarker  
    properties 
        
        crossplf
        crossphase
%         crossP 
        crossRatio
        
        
    end
    methods
       
        function BiomarkerObject = nbt_CrossPhaseLocking(NumChannels)
            if nargin == 0
                NumChannels = 1;
%                 SamplesInterval = 1;
               
            end
%             if nargin == 1
%                 SamplesInterval = 1;
%         
%             end
            
           
            % assign values for this biomarker object:
            %% Define Cross Phase Locking values
            
            BiomarkerObject.crossplf =  nan(NumChannels,NumChannels); 
            BiomarkerObject.crossphase =  nan(NumChannels,NumChannels);
%             BiomarkerObject.crossP = nan(NumChannels,NumChannels,SamplesInterval); 
            BiomarkerObject.crossRatio = nan(1,2);
            
            %% Define fields for additional information
            BiomarkerObject.DateLastUpdate = datestr(now);
            BiomarkerObject.PrimaryBiomarker = 'CrossPhaseLocking';
            BiomarkerObject.Biomarkers = {'crossplf','crossphase'};
           
            
        end
    end

end

