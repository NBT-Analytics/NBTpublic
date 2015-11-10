function myNode = sleep_scores()
% SLEEP_SCORES - Generates sleep-scores events


myNode = meegpipe.node.ev_gen.new(...
    'EventGenerator', physioset.event.sleep_scores_generator, ...
    'Plotter', []);


end