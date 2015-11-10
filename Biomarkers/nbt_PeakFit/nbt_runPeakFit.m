
function nbt_runPeakFit(Signal, SignalInfo, SaveDir)
FrequencyBandsInput = evalin('base','FrequencyBandsInput');
if isempty(FrequencyBandsInput)
    FrequencyBandsInput = evalin('base','FrequencyBandsInput');
    disp('Delta = [1,4];')
    disp('Theta = [4,8];')
    disp('Alpha = [8,13];')
    disp('Beta = [13,30];')
    disp('Gamma = [30,45];')
    
    temp=input('Declare own frequency bands?[y/n]: ','s');
    if strcmp(temp,'y')
        Delta = (input('Specify Delta [lowF highF]: '));
        Theta = (input('Specify Theta [lowF highF]: '));
        Alpha = (input('Specify Alpha [lowF highF]: '));
        Beta = (input('Specify Beta [lowF highF]: '));
        Gamma = (input('Specify Gamma [lowF highF]: '));
    else
        Delta = [1,4];
        Theta = [4,8];
        Alpha = [8,13];
        Beta = [13,30];
        Gamma = [30,45];
    end
    FrequencyBandsInput=[Delta;Theta;Alpha;Beta;Gamma];
end
assignin('base','FrequencyBandsInput',FrequencyBandsInput);
PeakFit = nbt_doPeakFit(Signal, SignalInfo);
nbt_SaveClearObject('PeakFit', SignalInfo, SaveDir)
SignalInfo.frequencyRange = [1 45];

end