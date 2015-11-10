function [d,si,h]=abfload(fn,varargin)
% ** function [d,si,h]=abfload(fn,varargin)
% loads and returns data in ABF (Axon Binary File) format.
% Data may have been acquired in the following modes:
% (1) event-driven variable-length (currently only abf versions < 2.0)
% (2) event-driven fixed-length or waveform-fixed length
% (3) gap-free
% Information about scaling, the time base and the number of channels and 
% episodes is extracted from the header of the abf file.
%
% OPERATION
% If the second input variable is the char array 'info' as in 
%         [d,si,h]=abfload('d:\data01.abf','info') 
% abfload will not load any data but return detailed information (header
% parameters) on the file in output variable h. d and si will be empty.
% In all other cases abfload will load data. Optional input parameters
% listed below (= all except the file name) must be specified as
% parameter/value pairs, e.g. as in 
%         d=abfload('d:\data01.abf','start',100,'stop','e');
%
% >>> INPUT VARIABLES >>>
% NAME        TYPE, DEFAULT      DESCRIPTION
% fn          char array         abf data file name
% start       scalar, 0          only gap-free-data: start of cutout to be 
%                                 read (unit: s)
% stop        scalar or char,    only gap-free-data: end of cutout to be  
%             'e'                 read (unit: sec). May be set to 'e' (end 
%                                 of file).
% sweeps      1d-array or char,  only episodic data: sweep numbers to be 
%             'a'                 read. By default, all sweeps will be read
%                                 ('a').
% channels    cell array         names of channels to be read, like 
%              or char, 'a'       {'IN 0','IN 8'} (make sure spelling is
%                                 100% correct, including blanks). If set 
%                                 to 'a', all channels will be read.
% chunk       scalar, 0.05       only gap-free-data: the elementary chunk  
%                                 size (megabytes) to be used for the 
%                                 'discontinuous' mode of reading data 
%                                 (fewer channels to be read than exist)
% machineF    char array,        the 'machineformat' input parameter of the
%              'ieee-le'          matlab fopen function. 'ieee-le' is the 
%                                 correct option for windows; depending on 
%                                 the platform the data were recorded/shall
%                                 be read by abfload 'ieee-be' is the 
%                                 alternative.
% << OUTPUT VARIABLES <<<
% NAME  TYPE            DESCRIPTION
% d                     the data read, the format depending on the record-
%                        ing mode
%   1. GAP-FREE:
%   2d array        2d array of size 
%                    <data pts> by <number of chans>
%                    Examples of access:
%                    d(:,2)       data from channel 2 at full length
%                    d(1:100,:)   first 100 data points from all channels
%   2. EPISODIC FIXED-LENGTH/WAVEFORM FIXED-LENGTH:
%   3d array        3d array of size 
%                    <data pts per sweep> by <number of chans> by <number 
%                    of sweeps>.
%                    Examples of access:
%                    d(:,2,:)            a matrix containing all episodes 
%                                        (at full length) of the second 
%                                        channel in its columns
%                    d(1:200,:,[1 11])   contains first 200 data points of 
%                                        episodes 1 and 11 of all channels
%   3. EPISODIC VARIABLE-LENGTH:
%   cell array      cell array whose elements correspond to single sweeps. 
%                    Each element is a (regular) array of size
%                    <data pts per sweep> by <number of chans>
%                    Examples of access:
%                    d{1}            a 2d-array which contains episode 1 
%                                    (all of it, all channels)
%                    d{2}(1:100,2)   a 1d-array containing the first 100
%                                    data points of channel 2 in episode 1
% si    scalar           the sampling interval in us
% h     struct           information on file (selected header parameters)
% 
% 
% CONTRIBUTORS
%   Original version by Harald Hentschke (harald.hentschke@uni-tuebingen.de)
%   Extended to abf version 2.0 by Forrest Collman (fcollman@Princeton.edu)
%   pvpmod.m by Ulrich Egert (egert@bccn.uni-freiburg.de)
%   Date of this version: May 20, 2009

% -------------------------------------------------------------------------
%                       PART 1: check of input vars
% -------------------------------------------------------------------------
disp(['** ' mfilename])
% --- defaults   
% gap-free
start=0.0;
stop='e';
% episodic
sweeps='a';
% general
channels='a';
% the size of data chunks (see above) in Mb. 0.05 Mb is an empirical value
% which works well for abf with 6-16 channels and recording durations of 
% 5-30 min
chunk=0.05;
machineF='ieee-le';
verbose=1;
% if first and only optional input argument is string 'info' the user's
% request is to obtain information on the file (header parameters), so set
% flag accordingly
if nargin==2 && ischar(varargin{1}) && strcmp('info',varargin{1})
 doLoadData=false;
else
 doLoadData=true;
 % assign values of optional input parameters if any were given
 pvpmod(varargin);
end

% some constants
BLOCKSIZE=512;
% output variables
d=[]; 
si=[];
h=[];
if ischar(stop)
 if ~strcmpi(stop,'e')
   error('input parameter ''stop'' must be specified as ''e'' (=end of recording) or as a scalar');
 end
end
% check existence of file
if ~exist(fn,'file'), 
 error(['could not find file ' fn]); 
end

% -------------------------------------------------------------------------
%                       PART 2a: determine abf version
% -------------------------------------------------------------------------
disp(['opening ' fn '..']); 
[fid,messg]=fopen(fn,'r',machineF); 
if fid == -1,
 error(messg);
end
% on the occasion, determine absolute file size
fseek(fid,0,'eof');
fileSz=ftell(fid);
fseek(fid,0,'bof');

% *** read value of parameter 'fFileSignature' (i.e. abf version) from header ***
sz=4;
[fFileSignature,n]=fread(fid,sz,'uchar=>char');
if n~=sz,
 fclose(fid);
 error('something went wrong reading value(s) for fFileSignature');
end
% rewind
fseek(fid,0,'bof');
% transpose
fFileSignature=fFileSignature';

% -------------------------------------------------------------------------
%    PART 2b: define file information ('header') parameters of interest
% -------------------------------------------------------------------------
% The list of header parameters created below (variable 'headPar') is
% derived from the abf version 1.8 header section. It is by no means 
% exhaustive (i.e. there are many more parameters in abf files) but
% sufficient for proper upload, scaling and arrangement of data acquired
% under many conditons. Further below, these parameters will be made fields
% of struct h. h, which is also an output variable, is then used in PART 3,
% which does the actual job of uploading, scaling and rearranging the data.
% That part of the code relies on h having a certain set of fields
% irrespective of ABF version. 
% Unfortunately, in the transition to ABF version 2.0 many of the header
% parameters were moved to different places within the abf file and/or
% given other names or completely restructured. In order for the code to
% work with pre- and post-2.0 data files, all parameters missing in the
% header must be gotten into h. This is accomplished in lines ~262 and
% following:
%     if h.fFileVersionNumber>=2
%       ...
% Furthermore,
% - h as an output from an ABF version < 2.0 file will not contain new 
%   parameters introduced into the header like 'nCRCEnable'
% - h will in any case contain a few 'home-made' fields that have
%   proven to be useful. Some of them depend on the recording mode. Among
%   the more or less self-explanatory ones are
% -- si                   sampling interval
% -- recChNames           the names of all channels, e.g. 'IN 8',...
% -- dataPtsPerChan       sample points per channel
% -- dataPts              sample points in file
% -- recTime              recording start and stop time in seconds from
%                         midnight (millisecond resolution)
% -- sweepLengthInPts     sample points per sweep (one channel)
% -- sweepStartInPts      the start times of sweeps in sample points 
%                         (from beginning of recording)


% call local function for header proper
headPar=define_header(fFileSignature);
  TagInfo=define_TagInfo;
switch fFileSignature
 case 'ABF ' % ** note the blank
   % ************************
   %     abf version < 2.0
   % ************************
   % do nothing, header already defined above

 case 'ABF2'
   % ************************
   %     abf version >= 2.0
   % ************************
   Sections=define_Sections;
   ProtocolInfo=define_ProtocolInfo;
   ADCInfo=define_ADCInfo;
   
 otherwise
   error('unknown or incompatible file signature');
end

% convert headPar to struct
s=cell2struct(headPar,{'name','offs','numType','value'},2);
numOfParams=size(s,1);
clear tmp headPar;

% -------------------------------------------------------------------------
%    PART 2c: read parameters of interest
% -------------------------------------------------------------------------
% convert names in structure to variables and read value from header
for g=1:numOfParams
 if fseek(fid, s(g).offs,'bof')~=0, 
   fclose(fid);
   error(['something went wrong locating ' s(g).name]); 
 end
 sz=length(s(g).value);
 % use dynamic field names 
 [h.(s(g).name),n]=fread(fid,sz,s(g).numType);
 if n~=sz, 
   fclose(fid);    
   error(['something went wrong reading value(s) for ' s(g).name]); 
 end
end
% transpose
h.fFileSignature=h.fFileSignature';
% several header parameters need a fix or version-specific refinement:
if strcmp(h.fFileSignature,'ABF2')
 % h.fFileVersionNumber needs to be converted from an array of integers to
 % a float
 h.fFileVersionNumber=h.fFileVersionNumber(4)+h.fFileVersionNumber(3)*.1...
   +h.fFileVersionNumber(2)*.001+h.fFileVersionNumber(1)*.0001;
 % convert ms to s
 h.lFileStartTime=h.uFileStartTimeMS*.001;
else
 % h.fFileVersionNumber is a float32 the value of which is sometimes a
 % little less than what it should be (e.g. 1.6499999 instead of 1.65)
 h.fFileVersionNumber=.001*round(h.fFileVersionNumber*1000);
 % in abf < 2.0 two parameters are needed to obtain the file start time
 % with millisecond precision - let's integrate both into parameter
 % lFileStartTime (unit: s) so that nFileStartMillisecs will not be needed
 h.lFileStartTime=h.lFileStartTime+h.nFileStartMillisecs*.001;  
end

% *** read file information that has gone elsewhere in ABF version >= 2.0
% and assign values ***
if h.fFileVersionNumber>=2
 % --- read in the Sections
 Sects=cell2struct(Sections,{'name'},2);
 numOfSections=length(Sections);
 offset=76;
 for i=1:numOfSections
   eval([Sects(i).name '=ReadSectionInfo(fid,offset);']);
   offset=offset+4+4+8;
 end
 % --- read in the Strings
 fseek(fid,StringsSection.uBlockIndex*BLOCKSIZE,'bof');
 BigString=fread(fid,StringsSection.uBytes,'char');
 % this is a hack
 goodstart=strfind(lower(char(BigString)'),'clampex');
 %this extends the hack to deal with axoscope files 
 if isempty(goodstart)
      goodstart=strfind(lower(char(BigString)'),'axoscope');
  end
  
 BigString=BigString(goodstart(1):end)';
 stringends=find(BigString==0);
 stringends=[0 stringends];
 for i=1:length(stringends)-1
   Strings{i}=char(BigString(stringends(i)+1:stringends(i+1)-1));
 end
 h.recChNames=[];
 h.recChUnits=[];

 % --- read in the ADCSection
 for i=1:ADCSection.llNumEntries
   ADCsec(i)=ReadSection(fid,ADCSection.uBlockIndex*BLOCKSIZE+ADCSection.uBytes*(i-1),ADCInfo);
   ii=ADCsec(i).nADCNum+1;
   h.nADCSamplingSeq(i)=ADCsec(i).nADCNum;
   h.recChNames=strvcat(h.recChNames, Strings{ADCsec(i).lADCChannelNameIndex});
   h.recChUnits=strvcat(h.recChUnits, Strings{ADCsec(i).lADCUnitsIndex});
   h.nTelegraphEnable(ii)=ADCsec(i).nTelegraphEnable;
   h.fTelegraphAdditGain(ii)=ADCsec(i).fTelegraphAdditGain;
   h.fInstrumentScaleFactor(ii)=ADCsec(i).fInstrumentScaleFactor;
   h.fSignalGain(ii)=ADCsec(i).fSignalGain;
   h.fADCProgrammableGain(ii)=ADCsec(i).fADCProgrammableGain;
   h.fInstrumentOffset(ii)=ADCsec(i).fInstrumentOffset;
   h.fSignalOffset(ii)=ADCsec(i).fSignalOffset;
 end
 % --- read in the protocol section
 ProtocolSec=ReadSection(fid,ProtocolSection.uBlockIndex*BLOCKSIZE,ProtocolInfo);
 % --- 
 h.nOperationMode=ProtocolSec.nOperationMode;
 h.fSynchTimeUnit=ProtocolSec.fSynchTimeUnit;
 h.nADCNumChannels=ADCSection.llNumEntries;
 h.lActualAcqLength=DataSection.llNumEntries;
 h.lDataSectionPtr=DataSection.uBlockIndex;
 h.nNumPointsIgnored=0;
 % in ABF version < 2.0 h.fADCSampleInterval is the sampling interval
 % defined as 
 %     1/(sampling freq*number_of_channels)
 % so divide ProtocolSec.fADCSequenceInterval by the number of
 % channels
 h.fADCSampleInterval=ProtocolSec.fADCSequenceInterval/h.nADCNumChannels;
 h.fADCRange=ProtocolSec.fADCRange;
 h.lADCResolution=ProtocolSec.lADCResolution;
 h.lSynchArrayPtr=SynchArraySection.uBlockIndex;
 h.lSynchArraySize=SynchArraySection.llNumEntries;
else
   TagSection.llNumEntries=h.lNumTagEntries;
    TagSection.uBlockIndex=h.lTagSectionPtr;
    TagSection.uBytes=64;
end
Tagsec=[];
for i=1:TagSection.llNumEntries
        Tagsec(i)=ReadSection(fid,TagSection.uBlockIndex*BLOCKSIZE+TagSection.uBytes*(i-1),TagInfo);
        Tagsec(i).sComment=char(Tagsec(i).sComment)';
end
h.Tags=Tagsec;


% -------------------------------------------------------------------------
%    PART 2d: groom parameters & perform some plausibility checks
% -------------------------------------------------------------------------
if h.lActualAcqLength<h.nADCNumChannels, 
 fclose(fid);
 error('less data points than sampled channels in file'); 
end
% the numerical value of all recorded channels (numbers 0..15)
recChIdx=h.nADCSamplingSeq(1:h.nADCNumChannels);
% the corresponding indices into loaded data d
recChInd=1:length(recChIdx);
if h.fFileVersionNumber<2
 % the channel names, e.g. 'IN 8' (for ABF version 2.0 these have been
 % extracted above at this point)
 h.recChNames=(reshape(char(h.sADCChannelName),10,16))';
 h.recChNames=h.recChNames(recChIdx+1,:);
 % same with signal units
 h.recChUnits=(reshape(char(h.sADCUnits),8,16))';
 h.recChUnits=h.recChUnits(recChIdx+1,:);
end
% convert to cell arrays 
h.recChNames=deblank(cellstr(h.recChNames));
h.recChUnits=deblank(cellstr(h.recChUnits));

% check whether requested channels exist
chInd=[];
eflag=0;
if ischar(channels)
 if strcmp(channels,'a')
   chInd=recChInd;
 else
   fclose(fid);
   error('input parameter ''channels'' must either be a cell array holding channel names or the single character ''a'' (=all channels)');
 end
else
 for i=1:length(channels)
   tmpChInd=strmatch(channels{i},h.recChNames,'exact');
   if ~isempty(tmpChInd)
     chInd=[chInd tmpChInd];
   else
     % set error flag to 1
     eflag=1;
   end
 end
end
if eflag
 fclose(fid);
 disp('**** available channels:');
 disp(h.recChNames);
 disp(' ');
 disp('**** requested channels:');
 disp(channels);
 error('at least one of the requested channels does not exist in data file (see above)');
end
% display available channels if in info mode
if ~doLoadData
 disp('**** available channels:');
 disp(h.recChNames);
end  

% gain of telegraphed instruments, if any
if h.fFileVersionNumber>=1.65
 addGain=h.nTelegraphEnable.*h.fTelegraphAdditGain;
 addGain(addGain==0)=1;
else
 addGain=ones(size(h.fTelegraphAdditGain));
end

% determine offset at which data start
switch h.nDataFormat
 case 0
   dataSz=2;  % bytes/point
   precision='int16';
 case 1
   dataSz=4;  % bytes/point
   precision='float32';
 otherwise
   fclose(fid);
   error('invalid number format');
end
headOffset=h.lDataSectionPtr*BLOCKSIZE+h.nNumPointsIgnored*dataSz;
% h.fADCSampleInterval is the TOTAL sampling interval
h.si=h.fADCSampleInterval*h.nADCNumChannels;
% assign same value to si, which is an output variable
si=h.si;
if ischar(sweeps) && sweeps=='a'
 nSweeps=h.lActualEpisodes;
 sweeps=1:h.lActualEpisodes;
else
 nSweeps=length(sweeps);
end  

% -------------------------------------------------------------------------
%    PART 3: read data (note: from here on code is generic and abf version
%    should not matter)
% -------------------------------------------------------------------------
switch h.nOperationMode
 case 1
   disp('data were acquired in event-driven variable-length mode');
   if h.fFileVersionNumber>=2.0
     errordlg('abfload currently does not work with data acquired in event-driven variable-length mode and ABF version 2.0','ABF version issue');
   else
     if (h.lSynchArrayPtr<=0 || h.lSynchArraySize<=0),
       fclose(fid);
       error('internal variables ''lSynchArraynnn'' are zero or negative');
     end
     switch h.fSynchTimeUnit
       case 0  % time information in synch array section is in terms of ticks
         h.synchArrTimeBase=1;
       otherwise % time information in synch array section is in terms of usec
         h.synchArrTimeBase=h.fSynchTimeUnit;
     end
     % the byte offset at which the SynchArraySection starts
     h.lSynchArrayPtrByte=BLOCKSIZE*h.lSynchArrayPtr;
     % before reading Synch Arr parameters check if file is big enough to hold them
     % 4 bytes/long, 2 values per episode (start and length)
     if h.lSynchArrayPtrByte+2*4*h.lSynchArraySize<fileSz,
       fclose(fid);
       error('file seems not to contain complete Synch Array Section');
     end
     if fseek(fid,h.lSynchArrayPtrByte,'bof')~=0,
       fclose(fid);
       error('something went wrong positioning file pointer to Synch Array Section');
     end
     [synchArr,n]=fread(fid,h.lSynchArraySize*2,'int32');
     if n~=h.lSynchArraySize*2,
       fclose(fid);
       error('something went wrong reading synch array section');
     end
     % make synchArr a h.lSynchArraySize x 2 matrix
     synchArr=permute(reshape(synchArr',2,h.lSynchArraySize),[2 1]);
     % the length of episodes in sample points
     segLengthInPts=synchArr(:,2)/h.synchArrTimeBase;
     % the starting ticks of episodes in sample points WITHIN THE DATA FILE
     segStartInPts=cumsum([0 (segLengthInPts(1:end-1))']*dataSz)+headOffset;
     % start time (synchArr(:,1)) has to be divided by h.nADCNumChannels to get true value
     % go to data portion
     if fseek(fid,headOffset,'bof')~=0,
       fclose(fid);
       error('something went wrong positioning file pointer (too few data points ?)');
     end
     % ** load data if requested
     if doLoadData
       for i=1:nSweeps,
         % if selected sweeps are to be read, seek correct position
         if ~isequal(nSweeps,h.lActualEpisodes),
           fseek(fid,segStartInPts(sweeps(i)),'bof');
         end
         [tmpd,n]=fread(fid,segLengthInPts(sweeps(i)),precision);
         if n~=segLengthInPts(sweeps(i)),
           warning(['something went wrong reading episode ' int2str(sweeps(i)) ': ' segLengthInPts(sweeps(i)) ' points should have been read, ' int2str(n) ' points actually read']);
         end
         h.dataPtsPerChan=n/h.nADCNumChannels;
         if rem(n,h.nADCNumChannels)>0,
           fclose(fid);
           error('number of data points in episode not OK');
         end
         % separate channels..
         tmpd=reshape(tmpd,h.nADCNumChannels,h.dataPtsPerChan);
         % retain only requested channels
         tmpd=tmpd(chInd,:);
         tmpd=tmpd';
         % if data format is integer, scale appropriately; if it's float, tmpd is fine
         if ~h.nDataFormat
           for j=1:length(chInd),
             ch=recChIdx(chInd(j))+1;
             tmpd(:,j)=tmpd(:,j)/(h.fInstrumentScaleFactor(ch)*h.fSignalGain(ch)*h.fADCProgrammableGain(ch)*addGain(ch))...
               *h.fADCRange/h.lADCResolution+h.fInstrumentOffset(ch)-h.fSignalOffset(ch);
           end
         end
         % now place in cell array, an element consisting of one sweep with channels in columns
         d{i}=tmpd;
       end
     end
   end

 case {2,5}
   if h.nOperationMode==2
     disp('data were acquired in event-driven fixed-length mode');
   else
     disp('data were acquired in waveform fixed-length mode (clampex only)');
   end
   % extract timing information on sweeps
   if (h.lSynchArrayPtr<=0 || h.lSynchArraySize<=0),
     fclose(fid);
     error('internal variables ''lSynchArraynnn'' are zero or negative');
   end
   switch h.fSynchTimeUnit
     case 0  % time information in synch array section is in terms of ticks
       h.synchArrTimeBase=1;
     otherwise % time information in synch array section is in terms of usec
       h.synchArrTimeBase=h.fSynchTimeUnit;
   end
   % the byte offset at which the SynchArraySection starts
   h.lSynchArrayPtrByte=BLOCKSIZE*h.lSynchArrayPtr;
   % before reading Synch Arr parameters check if file is big enough to hold them
   % 4 bytes/long, 2 values per episode (start and length)
   if h.lSynchArrayPtrByte+2*4*h.lSynchArraySize>fileSz,
     fclose(fid);
     error('file seems not to contain complete Synch Array Section');
   end
   if fseek(fid,h.lSynchArrayPtrByte,'bof')~=0,
     fclose(fid);
     error('something went wrong positioning file pointer to Synch Array Section');
   end
   [synchArr,n]=fread(fid,h.lSynchArraySize*2,'int32');
   if n~=h.lSynchArraySize*2,
     fclose(fid);
     error('something went wrong reading synch array section');
   end
   % make synchArr a h.lSynchArraySize x 2 matrix
   synchArr=permute(reshape(synchArr',2,h.lSynchArraySize),[2 1]);
   if numel(unique(synchArr(:,2)))>1
     fclose(fid);
     error('sweeps of unequal length in file recorded in fixed-length mode');
   end
   % the length of sweeps in sample points (**note: parameter lLength of
   % the ABF synch section is expressed in samples (ticks) whereas
   % parameter lStart is given in synchArrTimeBase units)
   h.sweepLengthInPts=synchArr(1,2)/h.nADCNumChannels;
   % the starting ticks of episodes in sample points (t0=1=beginning of
   % recording)
   h.sweepStartInPts=synchArr(:,1)*(h.synchArrTimeBase/h.fADCSampleInterval/h.nADCNumChannels);
   % recording start and stop times in seconds from midnight
   h.recTime=h.lFileStartTime;
   h.recTime=h.recTime+[0  (1e-6*(h.sweepStartInPts(end)+h.sweepLengthInPts))*h.fADCSampleInterval*h.nADCNumChannels];
   % determine first point and number of points to be read 
   startPt=0;
   h.dataPts=h.lActualAcqLength;
   h.dataPtsPerChan=h.dataPts/h.nADCNumChannels;
   if rem(h.dataPts,h.nADCNumChannels)>0 || rem(h.dataPtsPerChan,h.lActualEpisodes)>0
     fclose(fid);
     error('number of data points not OK'); 
   end
   % temporary helper var
   dataPtsPerSweep=h.sweepLengthInPts*h.nADCNumChannels;
   if fseek(fid,startPt*dataSz+headOffset,'bof')~=0
     fclose(fid);
     error('something went wrong positioning file pointer (too few data points ?)'); 
   end
   d=zeros(h.sweepLengthInPts,length(chInd),nSweeps);
   % the starting ticks of episodes in sample points WITHIN THE DATA FILE
   selectedSegStartInPts=((sweeps-1)*dataPtsPerSweep)*dataSz+headOffset;
   % ** load data if requested
   if doLoadData
     for i=1:nSweeps,
       fseek(fid,selectedSegStartInPts(i),'bof');
       [tmpd,n]=fread(fid,dataPtsPerSweep,precision);
       if n~=dataPtsPerSweep,
         fclose(fid);
         error(['something went wrong reading episode ' int2str(sweeps(i)) ': ' dataPtsPerSweep ' points should have been read, ' int2str(n) ' points actually read']);
       end
       h.dataPtsPerChan=n/h.nADCNumChannels;
       if rem(n,h.nADCNumChannels)>0
         fclose(fid);
         error('number of data points in episode not OK');
       end
       % separate channels..
       tmpd=reshape(tmpd,h.nADCNumChannels,h.dataPtsPerChan);
       % retain only requested channels
       tmpd=tmpd(chInd,:);
       tmpd=tmpd';
       % if data format is integer, scale appropriately; if it's float, d is fine
       if ~h.nDataFormat
         for j=1:length(chInd),
           ch=recChIdx(chInd(j))+1;
           tmpd(:,j)=tmpd(:,j)/(h.fInstrumentScaleFactor(ch)*h.fSignalGain(ch)*h.fADCProgrammableGain(ch)*addGain(ch))...
             *h.fADCRange/h.lADCResolution+h.fInstrumentOffset(ch)-h.fSignalOffset(ch);
         end
       end
       % now fill 3d array
       d(:,:,i)=tmpd;
     end
   end

 case 3
   disp('data were acquired in gap-free mode');
   % from start, stop, headOffset and h.fADCSampleInterval calculate first point to be read 
   %  and - unless stop is given as 'e' - number of points
   startPt=floor(1e6*start*(1/h.fADCSampleInterval));
   % this corrects undesired shifts in the reading frame due to rounding errors in the previous calculation
   startPt=floor(startPt/h.nADCNumChannels)*h.nADCNumChannels;
   % if stop is a char array, it can only be 'e' at this point (other values would have 
   % been caught above)
   if ischar(stop),
     h.dataPtsPerChan=h.lActualAcqLength/h.nADCNumChannels-floor(1e6*start/h.si);
     h.dataPts=h.dataPtsPerChan*h.nADCNumChannels;
   else
     h.dataPtsPerChan=floor(1e6*(stop-start)*(1/h.si));
     h.dataPts=h.dataPtsPerChan*h.nADCNumChannels;
     if h.dataPts<=0 
       fclose(fid);
       error('start is larger than or equal to stop'); 
     end
   end
   if rem(h.dataPts,h.nADCNumChannels)>0
     fclose(fid);
     error('number of data points not OK'); 
   end
   tmp=1e-6*h.lActualAcqLength*h.fADCSampleInterval;
   if verbose
     disp(['total length of recording: ' num2str(tmp,'%5.1f') ' s ~ ' num2str(tmp/60,'%3.0f') ' min']);
     % 8 bytes per data point expressed in Mb
     disp(['memory requirement for complete upload in matlab: '...
       num2str(round(8*h.lActualAcqLength/2^20)) ' MB']);
   end
   % recording start and stop times in seconds from midnight
   h.recTime=h.lFileStartTime;
   h.recTime=[h.recTime h.recTime+tmp];
   if fseek(fid,startPt*dataSz+headOffset,'bof')~=0, 
     fclose(fid);
     error('something went wrong positioning file pointer (too few data points ?)');
   end
   if doLoadData
     % *** decide on the most efficient way to read data:
     % (i) all (of one or several) channels requested: read, done
     % (ii) one (of several) channels requested: use the 'skip' feature of
     % fread
     % (iii) more than one but not all (of several) channels requested:
     % 'discontinuous' mode of reading data. Read a reasonable chunk of data
     % (all channels), separate channels, discard non-requested ones (if
     % any), place data in preallocated array, repeat until done. This is
     % faster than reading the data in one big lump, separating channels and
     % discarding the ones not requested
     if length(chInd)==1 && h.nADCNumChannels>1
       % --- situation (ii)
       % jump to proper reading frame position in file
       if fseek(fid,(chInd-1)*dataSz,'cof')~=0
         fclose(fid);
         error('something went wrong positioning file pointer (too few data points ?)');
       end
       % read, skipping h.nADCNumChannels-1 data points after each read
       [d,n]=fread(fid,h.dataPtsPerChan,precision,dataSz*(h.nADCNumChannels-1));
       if n~=h.dataPtsPerChan,
         fclose(fid);
         error(['something went wrong reading file (' int2str(h.dataPtsPerChan) ' points should have been read, ' int2str(n) ' points actually read']);
       end
     elseif length(chInd)/h.nADCNumChannels<1
       % --- situation (iii)
       % prepare chunkwise upload:
       % preallocate d
       d=repmat(nan,h.dataPtsPerChan,length(chInd));
       % the number of data points corresponding to the maximal chunk size,
       % rounded off such that from each channel the same number of points is
       % read (do not forget that each data point will by default be made a
       % double of 8 bytes, no matter what the original data format is)
       chunkPtsPerChan=floor(chunk*2^20/8/h.nADCNumChannels);
       chunkPts=chunkPtsPerChan*h.nADCNumChannels;
       % the number of those chunks..
       nChunk=floor(h.dataPts/chunkPts);
       % ..and the remainder
       restPts=h.dataPts-nChunk*chunkPts;
       restPtsPerChan=restPts/h.nADCNumChannels;
       % chunkwise row indices into d
       dix=(1:chunkPtsPerChan:h.dataPtsPerChan)';
       dix(:,2)=dix(:,1)+chunkPtsPerChan-1;
       dix(end,2)=h.dataPtsPerChan;
       if verbose && nChunk
         disp(['reading file in ' int2str(nChunk) ' chunks of ~' num2str(chunk) ' Mb']);
       end
       % do it
       for ci=1:size(dix,1)-1
         [tmpd,n]=fread(fid,chunkPts,precision);
         if n~=chunkPts
           fclose(fid);
           error(['something went wrong reading chunk #' int2str(ci) ' (' ...
             int2str(chunkPts) ' points should have been read, ' int2str(n) ' points actually read']);
         end
         % separate channels..
         tmpd=reshape(tmpd,h.nADCNumChannels,chunkPtsPerChan);
         d(dix(ci,1):dix(ci,2),:)=tmpd(chInd,:)';
       end
       % collect the rest, if any
       if restPts
         [tmpd,n]=fread(fid,restPts,precision);
         if n~=restPts
           fclose(fid);
           error(['something went wrong reading last chunk (' ...
             int2str(restPts) ' points should have been read, ' int2str(n) ' points actually read']);
         end
         % separate channels..
         tmpd=reshape(tmpd,h.nADCNumChannels,restPtsPerChan);
         d(dix(end,1):dix(end,2),:)=tmpd(chInd,:)';
       end
     else
       % --- situation (i)
       [d,n]=fread(fid,h.dataPts,precision);
       if n~=h.dataPts,
         fclose(fid);
         error(['something went wrong reading file (' int2str(h.dataPts) ' points should have been read, ' int2str(n) ' points actually read']);
       end
       % separate channels..
       d=reshape(d,h.nADCNumChannels,h.dataPtsPerChan);
       d=d';
     end
     % if data format is integer, scale appropriately; if it's float, d is fine
     if ~h.nDataFormat
       for j=1:length(chInd),
         ch=recChIdx(chInd(j))+1;
         d(:,j)=d(:,j)/(h.fInstrumentScaleFactor(ch)*h.fSignalGain(ch)*h.fADCProgrammableGain(ch)*addGain(ch))...
           *h.fADCRange/h.lADCResolution+h.fInstrumentOffset(ch)-h.fSignalOffset(ch);
       end
     end
   end
 otherwise
   disp('recording mode is ''high-speed oscilloscope'' which is not implemented -- returning empty matrix');
   d=[];
   h.si=[];
end
fclose(fid);
% h=orderfields(h);

% ########################################################################
%                         LOCAL FUNCTIONS
% ########################################################################

function headPar=define_header(fileSig)
switch fileSig
 case 'ABF ' % ** note the blank
   % ************************
   %     abf version < 2.0
   % ************************
   %
   % temporary initializing var
   tmp=repmat(-1,1,16);
   % define vital header parameters and initialize them with -1: set up a cell
   % array (and convert it to a struct below, which is more convenient)
   % column order is
   %        name, position in header in bytes, type, value)
   headPar={
     'fFileSignature',0,'*char',[-1 -1 -1 -1];
     'fFileVersionNumber',4,'float32',-1;
     'nOperationMode',8,'int16',-1;
     'lActualAcqLength',10,'int32',-1;
     'nNumPointsIgnored',14,'int16',-1;
     'lActualEpisodes',16,'int32',-1;
     'lFileStartTime',24,'int32',-1;
     'lDataSectionPtr',40,'int32',-1;
     'lTagSectionPtr',44,'int32',-1;
     'lNumTagEntries',48,'int32',-1;
     'lSynchArrayPtr',92,'int32',-1;
     'lSynchArraySize',96,'int32',-1;
     'nDataFormat',100,'int16',-1;
     'nADCNumChannels', 120, 'int16', -1;
     'fADCSampleInterval',122,'float', -1;
     'fSynchTimeUnit',130,'float',-1;
     'lNumSamplesPerEpisode',138,'int32',-1;
     'lPreTriggerSamples',142,'int32',-1;
     'lEpisodesPerRun',146,'int32',-1;
     'fADCRange', 244, 'float', -1;
     'lADCResolution', 252, 'int32', -1;
     'nFileStartMillisecs', 366, 'int16', -1;
     'nADCPtoLChannelMap', 378, 'int16', tmp;
     'nADCSamplingSeq', 410, 'int16',  tmp;
     'sADCChannelName',442, 'uchar', repmat(tmp,1,10);
     'sADCUnits',602, 'uchar', repmat(tmp,1,8);
     'fADCProgrammableGain', 730, 'float', tmp;
     'fInstrumentScaleFactor', 922, 'float', tmp;
     'fInstrumentOffset', 986, 'float', tmp;
     'fSignalGain', 1050, 'float', tmp;
     'fSignalOffset', 1114, 'float', tmp;
     'nTelegraphEnable',4512,'int16',tmp;
     'fTelegraphAdditGain',4576,'float',tmp
     };
 case 'ABF2'
   % ************************
   %     abf version >= 2.0
   % ************************
   headPar={
     'fFileSignature',0,'*char',[-1 -1 -1 -1];
     'fFileVersionNumber',4,'bit8=>int',[-1 -1 -1 -1];
     'uFileInfoSize',8,'uint32',-1;
     'lActualEpisodes',12,'uint32',-1;
     'uFileStartDate',16','uint32',-1;
     'uFileStartTimeMS',20,'uint32',-1;
     'uStopwatchTime',24,'uint32',-1;
     'nFileType',28,'int16',-1;
     'nDataFormat',30,'int16',-1;
     'nSimultaneousScan',32,'int16',-1;
     'nCRCEnable',34,'int16',-1;
     'uFileCRC',36,'uint32',-1;
     'FileGUID',40,'uint32',-1;
     'uCreatorVersion',56,'uint32',-1;
     'uCreatorNameIndex',60,'uint32',-1;
     'uModifierVersion',64,'uint32',-1;
     'uModifierNameIndex',68,'uint32',-1;
     'uProtocolPathIndex',72,'uint32',-1;
     };
end

function Sections=define_Sections
Sections={'ProtocolSection';
 'ADCSection';
 'DACSection';
 'EpochSection';
 'ADCPerDACSection';
 'EpochPerDACSection';
 'UserListSection';
 'StatsRegionSection';
 'MathSection';
 'StringsSection';
 'DataSection';
 'TagSection';
 'ScopeSection';
 'DeltaSection';
 'VoiceTagSection';
 'SynchArraySection';
 'AnnotationSection';
 'StatsSection';
 };

function ProtocolInfo=define_ProtocolInfo
ProtocolInfo={
 'nOperationMode','int16',1;
 'fADCSequenceInterval','float',1;
 'bEnableFileCompression','bit1',1;
 'sUnused1','char',3;
 'uFileCompressionRatio','uint32',1;
 'fSynchTimeUnit','float',1;
 'fSecondsPerRun','float',1;
 'lNumSamplesPerEpisode','int32',1;
 'lPreTriggerSamples','int32',1;
 'lEpisodesPerRun','int32',1;
 'lRunsPerTrial','int32',1;
 'lNumberOfTrials','int32',1;
 'nAveragingMode','int16',1;
 'nUndoRunCount','int16',1;
 'nFirstEpisodeInRun','int16',1;
 'fTriggerThreshold','float',1;
 'nTriggerSource','int16',1;
 'nTriggerAction','int16',1;
 'nTriggerPolarity','int16',1;
 'fScopeOutputInterval','float',1;
 'fEpisodeStartToStart','float',1;
 'fRunStartToStart','float',1;
 'lAverageCount','int32',1;
 'fTrialStartToStart','float',1;
 'nAutoTriggerStrategy','int16',1;
 'fFirstRunDelayS','float',1;
 'nChannelStatsStrategy','int16',1;
 'lSamplesPerTrace','int32',1;
 'lStartDisplayNum','int32',1;
 'lFinishDisplayNum','int32',1;
 'nShowPNRawData','int16',1;
 'fStatisticsPeriod','float',1;
 'lStatisticsMeasurements','int32',1;
 'nStatisticsSaveStrategy','int16',1;
 'fADCRange','float',1;
 'fDACRange','float',1;
 'lADCResolution','int32',1;
 'lDACResolution','int32',1;
 'nExperimentType','int16',1;
 'nManualInfoStrategy','int16',1;
 'nCommentsEnable','int16',1;
 'lFileCommentIndex','int32',1;
 'nAutoAnalyseEnable','int16',1;
 'nSignalType','int16',1;
 'nDigitalEnable','int16',1;
 'nActiveDACChannel','int16',1;
 'nDigitalHolding','int16',1;
 'nDigitalInterEpisode','int16',1;
 'nDigitalDACChannel','int16',1;
 'nDigitalTrainActiveLogic','int16',1;
 'nStatsEnable','int16',1;
 'nStatisticsClearStrategy','int16',1;
 'nLevelHysteresis','int16',1;
 'lTimeHysteresis','int32',1;
 'nAllowExternalTags','int16',1;
 'nAverageAlgorithm','int16',1;
 'fAverageWeighting','float',1;
 'nUndoPromptStrategy','int16',1;
 'nTrialTriggerSource','int16',1;
 'nStatisticsDisplayStrategy','int16',1;
 'nExternalTagType','int16',1;
 'nScopeTriggerOut','int16',1;
 'nLTPType','int16',1;
 'nAlternateDACOutputState','int16',1;
 'nAlternateDigitalOutputState','int16',1;
 'fCellID','float',3;
 'nDigitizerADCs','int16',1;
 'nDigitizerDACs','int16',1;
 'nDigitizerTotalDigitalOuts','int16',1;
 'nDigitizerSynchDigitalOuts','int16',1;
 'nDigitizerType','int16',1;
 };

function ADCInfo=define_ADCInfo
ADCInfo={
 'nADCNum','int16',1;
 'nTelegraphEnable','int16',1;
 'nTelegraphInstrument','int16',1;
 'fTelegraphAdditGain','float',1;
 'fTelegraphFilter','float',1;
 'fTelegraphMembraneCap','float',1;
 'nTelegraphMode','int16',1;
 'fTelegraphAccessResistance','float',1;
 'nADCPtoLChannelMap','int16',1;
 'nADCSamplingSeq','int16',1;
 'fADCProgrammableGain','float',1;
 'fADCDisplayAmplification','float',1;
 'fADCDisplayOffset','float',1;
 'fInstrumentScaleFactor','float',1;
 'fInstrumentOffset','float',1;
 'fSignalGain','float',1;
 'fSignalOffset','float',1;
 'fSignalLowpassFilter','float',1;
 'fSignalHighpassFilter','float',1;
 'nLowpassFilterType','char',1;
 'nHighpassFilterType','char',1;
 'fPostProcessLowpassFilter','float',1;
 'nPostProcessLowpassFilterType','char',1;
 'bEnabledDuringPN','bit1',1;
 'nStatsChannelPolarity','int16',1;
 'lADCChannelNameIndex','int32',1;
 'lADCUnitsIndex','int32',1;
 };

function TagInfo=define_TagInfo
TagInfo={
   'lTagTime','int32',1;
   'sComment','char',56;
   'nTagType','int16',1;
   'nVoiceTagNumber_or_AnnotationIndex','int16',1;
};

function Section=ReadSection(fid,offset,Format)
s=cell2struct(Format,{'name','numType','number'},2);
fseek(fid,offset,'bof');
for i=1:length(s)
 eval(['[Section.' s(i).name ',n]=fread(fid,' num2str(s(i).number) ',''' s(i).numType ''');']);
end

function SectionInfo=ReadSectionInfo(fid,offset)
fseek(fid,offset,'bof');
SectionInfo.uBlockIndex=fread(fid,1,'uint32');
fseek(fid,offset+4,'bof');
SectionInfo.uBytes=fread(fid,1,'uint32');
fseek(fid,offset+8,'bof');
SectionInfo.llNumEntries=fread(fid,1,'int64');

function pvpmod(x)
% PVPMOD             - evaluate parameter/value pairs
% pvpmod(x) assigns the value x(i+1) to the parameter defined by the
% string x(i) in the calling workspace. This is useful to evaluate 
% <varargin> contents in an mfile, e.g. to change default settings 
% of any variable initialized before pvpmod(x) is called.
%
% (c) U. Egert 1998

% this loop is assigns the parameter/value pairs in x to the calling
% workspace.
if ~isempty(x)
  for i = 1:2:size(x,2)
     assignin('caller', x{i}, x{i+1});
  end;
end;



% 
% struct ABF_FileInfo
% {
%    UINT  uFileSignature;
%    UINT  uFileVersionNumber;
% 
%    // After this point there is no need to be the same as the ABF 1 equivalent.
%    UINT  uFileInfoSize;
% 
%    UINT  uActualEpisodes;
%    UINT  uFileStartDate;
%    UINT  uFileStartTimeMS;
%    UINT  uStopwatchTime;
%    short nFileType;
%    short nDataFormat;
%    short nSimultaneousScan;
%    short nCRCEnable;
%    UINT  uFileCRC;
%    GUID  FileGUID;
%    UINT  uCreatorVersion;
%    UINT  uCreatorNameIndex;
%    UINT  uModifierVersion;
%    UINT  uModifierNameIndex;
%    UINT  uProtocolPathIndex;   
% 
%    // New sections in ABF 2 - protocol stuff ...
%    ABF_Section ProtocolSection;           // the protocol
%    ABF_Section ADCSection;                // one for each ADC channel
%    ABF_Section DACSection;                // one for each DAC channel
%    ABF_Section EpochSection;              // one for each epoch
%    ABF_Section ADCPerDACSection;          // one for each ADC for each DAC
%    ABF_Section EpochPerDACSection;        // one for each epoch for each DAC
%    ABF_Section UserListSection;           // one for each user list
%    ABF_Section StatsRegionSection;        // one for each stats region
%    ABF_Section MathSection;
%    ABF_Section StringsSection;
% 
%    // ABF 1 sections ...
%    ABF_Section DataSection;            // Data
%    ABF_Section TagSection;             // Tags
%    ABF_Section ScopeSection;           // Scope config
%    ABF_Section DeltaSection;           // Deltas
%    ABF_Section VoiceTagSection;        // Voice Tags
%    ABF_Section SynchArraySection;      // Synch Array
%    ABF_Section AnnotationSection;      // Annotations
%    ABF_Section StatsSection;           // Stats config
%    
%    char  sUnused[148];     // size = 512 bytes
%    
%    ABF_FileInfo() 
%    { 
%       MEMSET_CTOR;
%       STATIC_ASSERT( sizeof( ABF_FileInfo ) == 512 );
% 
%       uFileSignature = ABF_FILESIGNATURE;
%       uFileInfoSize  = sizeof( ABF_FileInfo);
%    }
% 
% };
% 
% struct ABF_ProtocolInfo
% {
%    short nOperationMode;
%    float fADCSequenceInterval;
%    bool  bEnableFileCompression;
%    char  sUnused1[3];
%    UINT  uFileCompressionRatio;
% 
%    float fSynchTimeUnit;
%    float fSecondsPerRun;
%    long  lNumSamplesPerEpisode;
%    long  lPreTriggerSamples;
%    long  lEpisodesPerRun;
%    long  lRunsPerTrial;
%    long  lNumberOfTrials;
%    short nAveragingMode;
%    short nUndoRunCount;
%    short nFirstEpisodeInRun;
%    float fTriggerThreshold;
%    short nTriggerSource;
%    short nTriggerAction;
%    short nTriggerPolarity;
%    float fScopeOutputInterval;
%    float fEpisodeStartToStart;
%    float fRunStartToStart;
%    long  lAverageCount;
%    float fTrialStartToStart;
%    short nAutoTriggerStrategy;
%    float fFirstRunDelayS;
% 
%    short nChannelStatsStrategy;
%    long  lSamplesPerTrace;
%    long  lStartDisplayNum;
%    long  lFinishDisplayNum;
%    short nShowPNRawData;
%    float fStatisticsPeriod;
%    long  lStatisticsMeasurements;
%    short nStatisticsSaveStrategy;
% 
%    float fADCRange;
%    float fDACRange;
%    long  lADCResolution;
%    long  lDACResolution;
%    
%    short nExperimentType;
%    short nManualInfoStrategy;
%    short nCommentsEnable;
%    long  lFileCommentIndex;            
%    short nAutoAnalyseEnable;
%    short nSignalType;
% 
%    short nDigitalEnable;
%    short nActiveDACChannel;
%    short nDigitalHolding;
%    short nDigitalInterEpisode;
%    short nDigitalDACChannel;
%    short nDigitalTrainActiveLogic;
% 
%    short nStatsEnable;
%    short nStatisticsClearStrategy;
% 
%    short nLevelHysteresis;
%    long  lTimeHysteresis;
%    short nAllowExternalTags;
%    short nAverageAlgorithm;
%    float fAverageWeighting;
%    short nUndoPromptStrategy;
%    short nTrialTriggerSource;
%    short nStatisticsDisplayStrategy;
%    short nExternalTagType;
%    short nScopeTriggerOut;
% 
%    short nLTPType;
%    short nAlternateDACOutputState;
%    short nAlternateDigitalOutputState;
% 
%    float fCellID[3];
% 
%    short nDigitizerADCs;
%    short nDigitizerDACs;
%    short nDigitizerTotalDigitalOuts;
%    short nDigitizerSynchDigitalOuts;
%    short nDigitizerType;
% 
%    char  sUnused[304];     // size = 512 bytes
%    
%    ABF_ProtocolInfo() 
%    { 
%       MEMSET_CTOR; 
%       STATIC_ASSERT( sizeof( ABF_ProtocolInfo ) == 512 );
%    }
% };
% 
% struct ABF_MathInfo
% {
%    short nMathEnable;
%    short nMathExpression;
%    UINT  uMathOperatorIndex;     
%    UINT  uMathUnitsIndex;        
%    float fMathUpperLimit;
%    float fMathLowerLimit;
%    short nMathADCNum[2];
%    char  sUnused[16];
%    float fMathK[6];
% 
%    char  sUnused2[64];     // size = 128 bytes
%    
%    ABF_MathInfo()
%    { 
%       MEMSET_CTOR; 
%       STATIC_ASSERT( sizeof( ABF_MathInfo ) == 128 );
%    }
% };
% 
% struct ABF_ADCInfo
% {
%    // The ADC this struct is describing.
%    short nADCNum;
% 
%    short nTelegraphEnable;
%    short nTelegraphInstrument;
%    float fTelegraphAdditGain;
%    float fTelegraphFilter;
%    float fTelegraphMembraneCap;
%    short nTelegraphMode;
%    float fTelegraphAccessResistance;
% 
%    short nADCPtoLChannelMap;
%    short nADCSamplingSeq;
% 
%    float fADCProgrammableGain;
%    float fADCDisplayAmplification;
%    float fADCDisplayOffset;
%    float fInstrumentScaleFactor;
%    float fInstrumentOffset;
%    float fSignalGain;
%    float fSignalOffset;
%    float fSignalLowpassFilter;
%    float fSignalHighpassFilter;
% 
%    char  nLowpassFilterType;
%    char  nHighpassFilterType;
%    float fPostProcessLowpassFilter;
%    char  nPostProcessLowpassFilterType;
%    bool  bEnabledDuringPN;
% 
%    short nStatsChannelPolarity;
% 
%    long  lADCChannelNameIndex;
%    long  lADCUnitsIndex;
% 
%    char  sUnused[46];         // size = 128 bytes
%    
%    ABF_ADCInfo()
%    { 
%       MEMSET_CTOR; 
%       STATIC_ASSERT( sizeof( ABF_ADCInfo ) == 128 );
%    }
% };
% 
% struct ABF_DACInfo
% {
%    // The DAC this struct is describing.
%    short nDACNum;
% 
%    short nTelegraphDACScaleFactorEnable;
%    float fInstrumentHoldingLevel;
% 
%    float fDACScaleFactor;
%    float fDACHoldingLevel;
%    float fDACCalibrationFactor;
%    float fDACCalibrationOffset;
% 
%    long  lDACChannelNameIndex;
%    long  lDACChannelUnitsIndex;
% 
%    long  lDACFilePtr;
%    long  lDACFileNumEpisodes;
% 
%    short nWaveformEnable;
%    short nWaveformSource;
%    short nInterEpisodeLevel;
% 
%    float fDACFileScale;
%    float fDACFileOffset;
%    long  lDACFileEpisodeNum;
%    short nDACFileADCNum;
% 
%    short nConditEnable;
%    long  lConditNumPulses;
%    float fBaselineDuration;
%    float fBaselineLevel;
%    float fStepDuration;
%    float fStepLevel;
%    float fPostTrainPeriod;
%    float fPostTrainLevel;
%    short nMembTestEnable;
% 
%    short nLeakSubtractType;
%    short nPNPolarity;
%    float fPNHoldingLevel;
%    short nPNNumADCChannels;
%    short nPNPosition;
%    short nPNNumPulses;
%    float fPNSettlingTime;
%    float fPNInterpulse;
% 
%    short nLTPUsageOfDAC;
%    short nLTPPresynapticPulses;
% 
%    long  lDACFilePathIndex;
% 
%    float fMembTestPreSettlingTimeMS;
%    float fMembTestPostSettlingTimeMS;
% 
%    short nLeakSubtractADCIndex;
% 
%    char  sUnused[124];     // size = 256 bytes
%    
%    ABF_DACInfo()
%    { 
%       MEMSET_CTOR; 
%       STATIC_ASSERT( sizeof( ABF_DACInfo ) == 256 );
%    }
% };
% 
% struct ABF_EpochInfoPerDAC
% {
%    // The Epoch / DAC this struct is describing.
%    short nEpochNum;
%    short nDACNum;
% 
%    // One full set of epochs (ABF_EPOCHCOUNT) for each DAC channel ...
%    short nEpochType;
%    float fEpochInitLevel;
%    float fEpochLevelInc;
%    long  lEpochInitDuration;  
%    long  lEpochDurationInc;
%    long  lEpochPulsePeriod;
%    long  lEpochPulseWidth;
% 
%    char  sUnused[18];      // size = 48 bytes
%    
%    ABF_EpochInfoPerDAC()
%    { 
%       MEMSET_CTOR; 
%       STATIC_ASSERT( sizeof( ABF_EpochInfoPerDAC ) == 48 );
%    }
% };
% 
% struct ABF_EpochInfo
% {
%    // The Epoch this struct is describing.
%    short nEpochNum;
% 
%    // Describes one epoch
%    short nDigitalValue;
%    short nDigitalTrainValue;
%    short nAlternateDigitalValue;
%    short nAlternateDigitalTrainValue;
%    bool  bEpochCompression;   // Compress the data from this epoch using uFileCompressionRatio
% 
%    char  sUnused[21];      // size = 32 bytes
%    
%    ABF_EpochInfo()
%    { 
%       MEMSET_CTOR; 
%       STATIC_ASSERT( sizeof( ABF_EpochInfo ) == 32 );
%    }
% };
% 
% struct ABF_StatsRegionInfo
% { 
%    // The stats region this struct is describing.
%    short nRegionNum;
%    short nADCNum;
% 
%    short nStatsActiveChannels;
%    short nStatsSearchRegionFlags;
%    short nStatsSelectedRegion;
%    short nStatsSmoothing;
%    short nStatsSmoothingEnable;
%    short nStatsBaseline;
%    long  lStatsBaselineStart;
%    long  lStatsBaselineEnd;
% 
%    // Describes one stats region
%    long  lStatsMeasurements;
%    long  lStatsStart;
%    long  lStatsEnd;
%    short nRiseBottomPercentile;
%    short nRiseTopPercentile;
%    short nDecayBottomPercentile;
%    short nDecayTopPercentile;
%    short nStatsSearchMode;
%    short nStatsSearchDAC;
%    short nStatsBaselineDAC;
% 
%    char  sUnused[78];   // size = 128 bytes
%    
%    ABF_StatsRegionInfo()
%    { 
%       MEMSET_CTOR; 
%       STATIC_ASSERT( sizeof( ABF_StatsRegionInfo ) == 128 );
%    }
% };
% 
% struct ABF_UserListInfo
% {
%    // The user list this struct is describing.
%    short nListNum;
% 
%    // Describes one user list
%    short nULEnable;
%    short nULParamToVary;
%    short nULRepeat;
%    long  lULParamValueListIndex;
% 
%    char  sUnused[52];   // size = 64 bytes
%    
%    ABF_UserListInfo()
%    { 
%       MEMSET_CTOR; 
%       STATIC_ASSERT( sizeof( ABF_UserListInfo ) == 64 );
%    }
% };*/=