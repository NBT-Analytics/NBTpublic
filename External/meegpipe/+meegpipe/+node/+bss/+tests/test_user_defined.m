function [status, MEh] = test_user_defined()
% TEST_USER_DEFINED - Tests user-defined component selections

import mperl.file.spec.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import spt.bss.jade;
import mperl.config.inifiles.inifile;
import meegpipe.node.*;

MEh     = [];

initialize(5);

%% Create a new session
try
    
    name = 'create new session';
    warning('off', 'session:NewSession');
    session.instance;
    warning('on', 'session:NewSession');
    hashStr = DataHash(randn(1,100));
    session.subsession(hashStr(1:5));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end
%% user-defined component rejection
try
    
    name = 'user-defined component rejection';
    
    X = rand(3, 5000);
    
    warning('off', 'sensors:InvalidLabel');
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    warning('on', 'sensors:InvalidLabel');
    
    eegSensors = subset(eegSensors, 1:3);
    
    importer = physioset.import.matrix(250, 'Sensors', eegSensors);
    
    data = import(importer, X);
    
    myFeat = spt.feature.tkurtosis;
    myCrit = spt.criterion.threshold(myFeat, 'MaxCard', 0, 'MinCard', 0);
    myNode = bss.new(...
        'Reject',           true, ...
        'Criterion',        myCrit, ...
        'GenerateReport',   false);
    
    run(myNode, data);
    
    condition = max(var(data, [], 2)) > 1e-2;
    
    if condition,
        cfgFile = catfile(get_full_dir(myNode, data), [get_name(myNode) '.ini']);
        cfg = inifile(cfgFile);
        newSelection = num2cell([1 2]);
        setval(cfg, 'bss', 'selection', newSelection{:});
        
        % Run the node again: it should remember the manual selection
        clear myNode ans;
        myNode = bss.new(...
            'Reject',           true, ...
            'GenerateReport',   false, ...
            'Criterion',        myCrit);
        data = data + rand(size(data));
        run(myNode, data);
        
        cfg = inifile(cfgFile);
        icSelection = val(cfg, 'bss', 'selection', true);
        icSelection = cellfun(@(x) str2double(x), icSelection);
        condition = condition & ...
            isempty(setdiff([1 2], icSelection));
        
        if condition,
            % Run the node again: it should still remember!
            clear myNode ans;
            myNode = bss.new(...
                'Reject',           true, ...
                'GenerateReport',   true, ...
                'Criterion',        myCrit);
            data = data + rand(size(data));
            run(myNode, data);
            
            cfg = inifile(cfgFile);
            icSelection = val(cfg, 'bss', 'selection', true);
            icSelection = cellfun(@(x) str2double(x), icSelection);
            condition = condition & ...
                isempty(setdiff([1 2], icSelection));   
        end
        
    end
    
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% user-defined component rejection
try
    
    name = 'user-defined component rejection';
    
    X = rand(3, 5000);
    
    warning('off', 'sensors:InvalidLabel');
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    warning('on', 'sensors:InvalidLabel');
    
    eegSensors = subset(eegSensors, 1:3);
    
    importer = physioset.import.matrix(250, 'Sensors', eegSensors);
    
    data = import(importer, X);
    
    myNode = bss.new(...
        'Reject',           true, ...
        'Criterion',        ~spt.criterion.dummy, ...
        'GenerateReport',   false);
    
    run(myNode, data);
    
    condition = max(var(data, [], 2)) < 1e-2;
    
    if condition,
        cfgFile = catfile(get_full_dir(myNode, data), [get_name(myNode) '.ini']);
        cfg = inifile(cfgFile);
        newSelection = num2cell([1 2]);
        setval(cfg, 'bss', 'selection', newSelection{:});
        
        % Run the node again: it should remember the manual selection
        clear myNode ans;
        myNode = bss.new(...
            'Reject',           true, ...
            'GenerateReport',   false, ...
            'Criterion',        ~spt.criterion.dummy);
        data = data + rand(size(data));
        run(myNode, data);
        
        cfg = inifile(cfgFile);
        icSelection = val(cfg, 'bss', 'selection', true);
        icSelection = cellfun(@(x) str2double(x), icSelection);
        condition = condition & ...
            isempty(setdiff([1 2], icSelection));
        
        if condition,
            % Run the node again: it should still remember!
            clear myNode ans;
            myNode = bss.new(...
                'Reject',           true, ...
                'GenerateReport',   false, ...
                'Criterion',        ~spt.criterion.dummy);
            data = data + rand(size(data));
            run(myNode, data);
            
            cfg = inifile(cfgFile);
            icSelection = val(cfg, 'bss', 'selection', true);
            icSelection = cellfun(@(x) str2double(x), icSelection);
            condition = condition & ...
                isempty(setdiff([1 2], icSelection));   
        end
        
    end
    
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% user-defined component selection
try
    
    name = 'user-defined component selection';
    
    X = rand(3, 5000);
    
    warning('off', 'sensors:InvalidLabel');
    eegSensors = sensors.eeg.from_template('egi256', 'PhysDim', 'uV');
    warning('on', 'sensors:InvalidLabel');
    
    eegSensors   = subset(eegSensors, 1:3);
    
    importer = physioset.import.matrix(250, 'Sensors', eegSensors);
    
    data = import(importer, X);
    
    myNode = bss.new(...
        'Reject',           false, ...
        'Criterion',        ~spt.criterion.dummy, ...
        'GenerateReport',   false);
    run(myNode, data);
    
    X = X - repmat(mean(X,2), 1, size(X,2));
    condition = max(abs(data(:)-X(:))) < 1e-2;
    
    if condition,
        cfgFile = catfile(get_full_dir(myNode, data), [get_name(myNode) '.ini']);
        cfg = inifile(cfgFile);
        newSelection = num2cell([1 3]);
        setval(cfg, 'bss', 'selection', newSelection{:});
        
        % Run the node again: it should remember the manual selection
        clear myNode ans;
        myNode = bss.new(...
            'Reject',           false, ...
            'Criterion',        ~spt.criterion.dummy, ...
            'GenerateReport',   false);
        run(myNode, data);
        
        cfg = inifile(cfgFile);
        icSelection = val(cfg, 'bss', 'selection', true);
        icSelection = cellfun(@(x) str2double(x), icSelection);
        condition = condition & ...
            isempty(setdiff([1 3], icSelection));
        
        if condition,
            % Empty selection
            setval(cfg, 'bss', 'selection', '');
            % Run the node again: it should remember the manual selection
            clear myNode ans;
            myNode = bss.new(...
                'Reject',           false, ...
                'Criterion',        ~spt.criterion.dummy, ...
                'GenerateReport',   false);
            
            % This should select no component: output should be zero
            run(myNode, data);
            condition = condition & ...
                max(var(data, [], 2)) < 0.01;

            if condition
                % Ignore user-selection
                delval(cfg, 'bss', 'selection');
                % Run the node again: it should reset to the automatic sel.
                clear myNode ans;
                myNode = bss.new(...
                    'Reject',           false, ...
                    'Criterion',        ~spt.criterion.dummy, ...
                    'GenerateReport',   false);
                data = data+randn(size(data));
                run(myNode, data);
                
                cfg = inifile(cfgFile);
                icSelection = val(cfg, 'bss', 'selection', true);
                icSelection = cellfun(@(x) str2double(x), icSelection);
                condition = condition & ...
                    isempty(setdiff([1 2 3], icSelection));
            end
            
        end
      
    end
    
    
    ok(condition, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end



%% Cleanup
try
    
    name = 'cleanup';
    clear data dataCopy;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();