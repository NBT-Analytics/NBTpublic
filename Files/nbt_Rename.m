%Usage - use to rename filenames into NBT format
% nbt_Rename(StartPath,filenameExt,BlockSep, BlockDef)
% 
%E.g.
% nbt_Rename('/media/Data/','.cnt','_',{'dyslex';1;'yymmdd';5}
% will rename the file format <SubjectID>_x_x_x_<Condition>.cnt to
% dyslex.<SubjectID>.yymmdd.<Condition>.cnt

% Copyright (C) 2011 Simon-Shlomo Poil
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
% 7 July 2011  Written by Simon-Shlomo Poil 


function nbt_Rename(startpath, ext, BlockSep, BlockDef)
%BlockDef ProjectID.SubjectID.Date.Condition
d = dir(startpath);
for j=3:length(d)
    if (d(j).isdir )
        nbt_Rename([startpath,'/', d(j).name ], ext, BlockSep, BlockDef);
    else
        %remove extenstion
        filename = d(j).name;
        try
            filename = filename(1:strfind(filename,ext)-1);
            if(isempty(filename))
                continue
            end
            BlockSpots = [ 0 strfind(filename,BlockSep) length(filename)+1];
            
            %ProjectID
            if(isstr(BlockDef{1,1}))
                ProjectID = BlockDef{1,1};
            else
                StartSpot = BlockSpots(BlockDef{1,1})+1;
                EndSpot   = BlockSpots(BlockDef{1,1}+1)-1;
                ProjectID = filename(StartSpot:EndSpot);
            end
            
            %SubjectID
            if(isstr(BlockDef{2,1}))
                SubjectID = BlockDef{2,1};
            else
                StartSpot = BlockSpots(BlockDef{2,1})+1;
                EndSpot   = BlockSpots(BlockDef{2,1}+1)-1;
                SubjectID = filename(StartSpot:EndSpot);
            end
            
            %Date
            if(isstr(BlockDef{3,1}))
                DateRec = BlockDef{3,1};
            else
                StartSpot = BlockSpots(BlockDef{3,1})+1;
                EndSpot   = BlockSpots(BlockDef{3,1}+1)-1;
                DateRec = filename(StartSpot:EndSpot);
            end
            
            %Condition
            if(isstr(BlockDef{4,1}))
                Condition = BlockDef{4,1};
            else
                StartSpot = BlockSpots(BlockDef{4,1})+1;
                EndSpot   = BlockSpots(BlockDef{4,1}+1)-1;
                Condition = filename(StartSpot:EndSpot);
            end
            
            NewFilename = [ProjectID '.S' SubjectID '.' DateRec '.' Condition ext];
            movefile([startpath,'/', filename ext], [startpath,'/', NewFilename]);
        catch
        end
        
    end
end
end