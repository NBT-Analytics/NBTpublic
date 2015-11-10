function hc = clone(h)
% THIS IS NOT A PROPER CLONE, JUST A CONFIG COPIER! FIX THIS AT SOME POINT

hc = plotter.eegplot.eegplot(get_config(h));

end