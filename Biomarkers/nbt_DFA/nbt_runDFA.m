function nbt_runDFA(Signal, SignalInfo, SaveDir,varinput)
[hp, lp, filter_order, FitInterval, CalcInterval, DFA_Overlap, DFA_Plot, ChannelToPlot, res_logbin] = nbt_vararginHandler(varinput);
[Signal, SignalInfo] = nbt_GetAmplitudeEnvelope(Signal, SignalInfo, hp, lp, filter_order);
tic
name = genvarname (['DFA' num2str(hp) '_' num2str(lp) 'Hz']);
%DFAObject = nbt_doDFA(Signal,SignalInfo,FitInterval, CalcInterval, DFA_Overlap, DFA_Plot, ChannelToPlot, res_logbin);
 eval([name '= nbt_doDFA(Signal,SignalInfo,FitInterval, CalcInterval, DFA_Overlap, DFA_Plot, ChannelToPlot, res_logbin)']);%i added
toc
nbt_SaveClearObject(name,SignalInfo,SaveDir);

end