function myProtEvs = generate_block_events(prot, protHdr, data, dataHdr)

import physioset.import.pupillator;

isStatus = cellfun(@(x) strcmp(x, 'status'), dataHdr);
isTime   = cellfun(@(x) ~isempty(strfind(x, 'time [s]')), dataHdr);
time = data(:, isTime);
status = data(:, isStatus);

isRed    = cellfun(@(x) ~isempty(regexp(x, 'red', 'once')), protHdr);
isGreen  = cellfun(@(x) ~isempty(regexp(x, 'green', 'once')), protHdr);
isBlue   = cellfun(@(x) ~isempty(regexp(x, 'blue', 'once')), protHdr);
isPVT    = cellfun(@(x) ~isempty(regexp(x, 'pvt', 'once')), protHdr);
[~, transitionSampl] = unique(status, 'first');

isPVTBlock = prot(:,isPVT) > 0; 

if any(isGreen)
    % pupillator 2.0: has a green channel and the three (RGB) channels can
    % have any intensity. We encode each block using an event of type
    % RxGyBz with x, y, z being the R, G and B values for a given block
    red    = find(cellfun(@(x) ~isempty(regexp(x, 'red', 'once')), dataHdr));
    green  = find(cellfun(@(x) ~isempty(regexp(x, 'green', 'once')), dataHdr));
    blue   = find(cellfun(@(x) ~isempty(regexp(x, 'blue', 'once')), dataHdr));
    myProtEvs = physioset.event.new(transitionSampl);

    blockDur = diff([transitionSampl;size(data,1)])-1;
    for i = 1:numel(myProtEvs)
        myProtEvs(i).Type = sprintf('R%.3dG%.3dB%.3d', ...
            data(transitionSampl(i), [red green blue]));
        myProtEvs(i).Value = i;
        myProtEvs(i).Duration = blockDur(i);
    end

else
    % Old pupillator did not have a green channel
    transitionSampl = [transitionSampl(:); numel(time)];
    transitionTime = time(transitionSampl);
    
    prot2 = prot(1:3:end,:);
    seq = repmat('D', size(prot2,1), 1);
    seq(prot2(:,isRed)>0)  = 'R';
    seq(prot2(:,isBlue)>0) = 'B';
    
    myProtEvs = pupillator.block_events(transitionSampl, transitionTime, ...
        seq, isPVTBlock);
end