function myProtEvs = block_events(transitionSampl, transitionTime, seq, isPVTBlock)


blockDur = diff(transitionSampl)-1;
isPre = true;
isPost = false;
myProtEvs = physioset.event.event(transitionSampl(1:end-1));

blockMetaProp = sprintf('Block_1_%d', numel(seq));

for i = 1:numel(myProtEvs)
   
   thisType = 'block_';
   if strcmp(seq(ceil(i/3)), 'R'),       
       thisType = [thisType 'red']; %#ok<*AGROW>
       isPre = false;
   elseif strcmp(seq(ceil(i/3)), 'B'),
       thisType = [thisType 'blue'];
       isPost = true;
   elseif isPre,
       thisType = [thisType 'dark-pre'];
   elseif isPost
       thisType = [thisType 'dark-post'];
   else
       thisType = [thisType 'dark'];
   end
   if isPVTBlock(i),
       thisType = [thisType, '-pvt'];
   end
   
   myProtEvs(i) = set(myProtEvs(i), ...
       'Time',      transitionTime(i), ...
       'Value',     i, ...
       'Duration',  blockDur(i), ...
       'Type',      thisType ...
       );
   
   myProtEvs(i) = set_meta(myProtEvs(i), blockMetaProp, ceil(i/3));
   
end

% The only blocks that are always there are the dark-pre, the red, the
% dark, the blue and the dark-post. Any block before the dark-pre will be
% labeled as dark-pre-1, dark-pre-2, etc. Any block after the dark-post
% will be labeled as dark-post-1, dark-post-2, etc.
evTypes = get(myProtEvs, 'Type');

firstBlock = find(ismember(evTypes, 'block_dark-pre-pvt'), 1, 'last');

for i = 1:firstBlock-1
    thisType = get(myProtEvs(i), 'Type');
    newType  = [thisType '-' num2str(firstBlock-i)];
    myProtEvs(i) = set(myProtEvs(i), 'Type', newType);
end

lastBlock = find(ismember(evTypes, 'block_dark-post-pvt'), 1, 'first');

for i = 1:(numel(myProtEvs)-lastBlock)
    thisType = get(myProtEvs(lastBlock+i), 'Type');
    newType  = [thisType '-' num2str(i)];
    myProtEvs(lastBlock+i) = set(myProtEvs(lastBlock+i), 'Type', newType);
end

end