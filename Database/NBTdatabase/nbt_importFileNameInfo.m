%Usage - use to rename filenames into NBT format
% nbt_Rename(StartPath,filenameExt,BlockSep, BlockDef)
% 
%E.g.
% nbt_Rename('/media/Data/','.cnt','_',{'dyslex';1;'yymmdd';5}
% will rename the file format <SubjectID>_x_x_x_<Condition>.cnt to
% dyslex.<SubjectID>.yymmdd.<Condition>.cnt

% Copyright (C) 2010 Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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
%

% ChangeLog - see version control log for details
% 2 August 2011  Written by Simon-Shlomo Poil 

% input (blok definetion) filename dir, info file name dir.


function nbt_importFileNameInfo(SourceDir,InfoFileDir, filenameExt, BlockSep, SubjectIDdef, InfoBlockDef)

%List SourceDir
SourceFilename = nbt_ExtractTree(SourceDir,filenameExt,filenameExt);
%and convet to only file names
for i=1:length(SourceFilename)
   SlashIndex = strfind(SourceFilename{1,i},'/'); 
   filename = SourceFilename{1,i}((SlashIndex(end)+1):end);
   filename = filename(1:strfind(filename,filenameExt)-1);        
   BlockSpots = [ 0 strfind(filename,BloclkSep) length(filename)+1];
   %decode Sourcefilename using BlockSep and InfoBlockDef
   
end


%load info file
d = dir(InfoFileDir);
for j=3:length(d)
    if (d(j).isdir )
        nbt_importFileNameInfo(SourceDir,[startpath,'/', d(j).name ],filenameExt, BlockSep, SubjectIDdef,InfoBlockDef);
    else
        
        
        
    end
    
end
%match SubjectID with SubjectID in SourceDir

%Extract Info from InfoBlockDef

%Save info file


end