function setPrompt(newPrompt)
%setPrompt Sets the Command Window prompt
%
% Syntax:
%    setPrompt(newPrompt)
%
% Description:
%    setPrompt(newPrompt) sets the Command Window prompt to the specified
%    NEWPROMPT. NEWPROMPT can be one of the following:
%
%      - a static string:        setPrompt('>> ')
%             => this is the default prompt string ('>> ')
%
%      - an evaluable string:    setPrompt('datestr(now)')
%             => the new prompt will look like: '25-Jan-2010 01:00:51'
%             Note: the evaluable string is expected to return a string
%
%      - an evaluable function:  setPrompt(@()(['[',datestr(now),'] ']))
%             => the new prompt will look like: '[25-Jan-2010 01:00:51] '
%             Note: the evaluable function is expected to return a string
%
%      - the static string 'timestamp' will continuously update the last
%        (current) prompt with the current time: '[25-Jan-2010 01:00:51] '
%        This has the effect of displaying desktop command execution times.
%        The 'timestamp' string can be used with other static text to
%        customize its appearance. For example: setPrompt('<timestamp!> ').
%
%      - an empty value or no input argument restores the default prompt
%
% Examples:
%    setPrompt('[-]')                   % Replaces '>> ' prompt with '[-]'
%    setPrompt('%')                     % => '%  ' (space-padded)
%    setPrompt('sprintf(''<%f>'',now)') % => '<734163.056262>'
%    setPrompt('datestr(now)')          % => '25-Jan-2010 01:00:51' (unchanging)
%    setPrompt('[''['',datestr(now),''] '']') % => '[25-Jan-2010 01:00:51] '
%    setPrompt(@()(['[',datestr(now),'] ']))  % => '[25-Jan-2010 01:00:51] '
%        (note that these are the same: the first uses an evaluable string,
%         while the second uses an evaluable function)
%    setPrompt('timestamp')             % => '[25-Jan-2010 01:00:51] ' (continuously-updated)
%    setPrompt('<timestamp> ')          % => '<25-Jan-2010 01:00:51> ' (continuously-updated)
%    setPrompt('>> ')                   % restores the default prompt
%    setPrompt('')                      % restores the default prompt
%    setPrompt                          % restores the default prompt
%
% Known issues/limitations:
%    - Prompts shorter than the default prompt are space-padded
%    - When selecting desktop text and pasting to the Editor, the prompt
%      is not stripped as it would be with the default prompt ('>> ')
%    - Continuously-updated prompts sometimes interfere with tab popups
%      and text selection
%    - Problems with Macs (Desktop becomes unresponsive)
%
% Warning:
%    This code heavily relies on undocumented and unsupported Matlab functionality.
%    It works on Matlab 7+, but use at your own risk!
%
% Technical explanation:
%    A technical explanation of the code in this utility can be found on
%    <a href="http://undocumentedmatlab.com/blog/setprompt-setting-matlab-desktop-prompt/">http://undocumentedmatlab.com/blog/setprompt-setting-matlab-desktop-prompt/</a>
%
% Bugs and suggestions:
%    Please send to Yair Altman (altmany at gmail dot com)
%
% Change log:
%    2010-01-29: Fixed a few edge-cases with (some reported by J.G. Dalissier) '>> ' terminated prompts; fixed a few problem with continuous timestamps; enabled customizing continuous timestamp prompts; added Mac warning
%    2010-01-26: Fixed a few edge cases (some inspired by J. Raymond); added continuously-updated timestamp option
%    2010-01-25: First version posted on the <a href="http://www.mathworks.com/matlabcentral/fileexchange/authors/27420">MathWorks File Exchange</a>
%
% See also:
%    fprintf, cprintf (on the File Exchange)

% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.03 $  $Date: 2010/01/29 16:12:43 $

% TODO: Mac problems: try PostSet listener; check pre-existing CaretUpdateCallback

    % Generate a warning to Mac users
    if ismac
        warningStr = sprintf('The setPrompt utility was reported to cause Matlab Desktop unresponsiveness,\nso please use with care and report any problems to Yair Altman (altmany@gmail.com).');
        warning('YMA:setPrompt:Mac',warningStr);  %#ok sprintf format (compatibility)
    end

    % Get the reference handle to the Command Window text area
    jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
    try
        cmdWin = jDesktop.getClient('Command Window');
        jTextArea = cmdWin.getComponent(0).getViewport.getComponent(0);
    catch
        commandwindow;
        jTextArea = jDesktop.getMainFrame.getFocusOwner;
    end
    
    % Special case - continuously-updated prompt
    stopPromptTimers;
    if nargin && ischar(newPrompt)
        pos = strfind(lower(newPrompt),'timestamp');
        if ~isempty(pos)
            % Update the initial prompt
            if strcmpi(newPrompt,'timestamp')
                newPrompt = @()(['[',datestr(now),'] ']);
            else
                newPrompt = @()([newPrompt(1:pos-1),datestr(now),newPrompt(pos+9:end)]);
            end

            % Prepare a timer to continuously update the prompt
            start(timer('Tag','setPromptTimer', 'Name','setPromptTimer', 'ExecutionMode','fixedDelay', 'ObjectVisibility','off', 'Period',0.99, 'StartDelay',0.5, 'TimerFcn',{@setPromptTimerFcn,jTextArea,newPrompt}));
        end
    end
        
    % Instrument the text area's callback
    if nargin && ~isempty(newPrompt) && ~strcmp(newPrompt,'>> ')
        set(jTextArea,'CaretUpdateCallback',{@setPromptFcn,newPrompt});
    else
        set(jTextArea,'CaretUpdateCallback',[]);
    end
end  % setPrompt

% Internal callback function to set the Command Window's prompt
function setPromptFcn(jTextArea,eventData,newPrompt)

    % Prevent overlapping reentry due to prompt replacement
    persistent inProgress
    if isempty(inProgress)
        inProgress = 1;  %#ok unused
    else
        return;
    end

    % preserve the last-modified prompt string
    persistent lastPrompt

    try
        % Get the string value of the requested prompt
        newPrompt = getStringPrompt(newPrompt);

        % Ensure we have the relevant Java reference handle
        if isnumeric(jTextArea) || isempty(jTextArea)
            jTextArea = get(eventData,'Source');
        end
        try jTextArea = jTextArea.java;  catch,  end  %#ok
        cwText = get(jTextArea,'Text');

        % If the prompt already appears modified, leave it as-is
        if isempty(strfind(cwText(max(1,end-length(newPrompt)-1):end), lastPrompt))
            % Replace the default prompt
            defaultPrompt = getDefaultPrompt(cwText);
            if ~isempty(defaultPrompt)
                % Short prompts need to be space-padded
                %newLen = jTextArea.getCaretPosition % No good: caret can be at text middle, not end!
                newLen = length(cwText);
                defLen = length(defaultPrompt);
                if length(newPrompt) < defLen
                    newPrompt(end+1:defLen) = ' ';
                elseif length(newPrompt) > defLen
                    fprintfStr = newPrompt(1:end-defLen);
                    fprintf(fprintfStr);
                    % Update the prompt start position for continuously-updated (timer) prompts
                    setappdata(jTextArea,'setPromptPos',newLen-defLen);
                    newLen = newLen + length(fprintfStr);
                end
                %pause(0.02);  % force the prompt-change callback to fizzle-out...

                % For debugging...
                %beep;
                %assignin('base','newLen',newLen);
                %assignin('base','cwText',cwText);

                % The Command-Window text should be modified on the EDT
                awtinvoke(jTextArea,'replaceRange(Ljava.lang.String;II)',newPrompt(end-defLen+1:end),newLen-defLen,newLen);
                awtinvoke(jTextArea,'repaint()');
                pause(0.02);  % force the prompt-change callback to fizzle-out...

                % Update the last-modified prompt string
                lastPrompt = newPrompt;
            else
                debug = 1;  %#ok
            end  % if text ends in default prompt
        else
            debug = 2;  %#ok
        end  % if text ends in non-modified prompt
    catch
        % Never mind - ignore...
        debug = 3;  %#ok
    end

    % Enable new callbacks now that the prompt has been modified
    inProgress = [];
end  % setPromptFcn

% Search for the default prompt at the end of the currently-displayed text
function defaultPrompt = getDefaultPrompt(cwText)

    % Get the list of possible default prompts
    persistent defaultPrompts
    if isempty(defaultPrompts)
        try
            % Try to get the list from the system (convert to row-wise string cell-array
            defaultPrompts = javaArray2cells(com.mathworks.mde.cmdwin.Prompt.getAllPromptStrings)';
            defaultPrompts = defaultPrompts([2:end,1]);  % move '>> ' to the end since it's already a substring of the others
        catch
            defaultPrompts = {'K>> ', 'EDU>> ', 'Trial>> ', '[Please exit and restart MATLAB]>>', '>> '};
        end
    end

    defaultPrompt = '';
    try
        pos = [];
        for promptIdx = 1 : length(defaultPrompts)
            defaultPrompt = defaultPrompts{promptIdx};
            pos = strfind(cwText(max(1,end-length(defaultPrompt)):end),defaultPrompt);  % catch a possible trailing newline
            if ~isempty(pos)
                break;
            end
        end
        if isempty(pos)
            defaultPrompt = '';
        end
    catch
        % Never mind - ignore...
        debug = 4;  %#ok
    end
end  % getDefaultPrompt

% Get the string value of the requested prompt
function newPrompt = getStringPrompt(newPrompt)
    % Try to evaluate the new prompt as a function
    try
        origNewPrompt = newPrompt;
        newPrompt = feval(newPrompt);
    catch
        try
            newPrompt = eval(newPrompt);
        catch
            % Never mind - probably a string...
        end
    end

    % Ensure that the returned newPrompt is a string
    if ~ischar(newPrompt) && ischar(origNewPrompt)
        % Nope... - possibly a string that was eval'ed to a number or a non-string function
        newPrompt = origNewPrompt;
    end
end  % getStringPrompt

% Stop & delete any existing prompt timer(s)
function stopPromptTimers
    try
        timers = timerfindall('tag','setPromptTimer');
        if ~isempty(timers)
            stop(timers);
            delete(timers);
        end
    catch
        % Never mind...
    end
end  % stopPromptTimers

% Internal timer callback function to update the latest prompt with an updated timestamp
function setPromptTimerFcn(timerObj,eventData,jTextArea,newPrompt)  %#ok
    try
        try jTextArea = jTextArea.java;  catch,  end  %#ok
        newPrompt = getStringPrompt(newPrompt);
        pos = getappdata(jTextArea,'setPromptPos');
        selectionStart = jTextArea.getSelectionStart;
        selectionEnd   = jTextArea.getSelectionEnd;
        awtinvoke(jTextArea,'replaceRange(Ljava.lang.String;II)',newPrompt,pos,pos+length(newPrompt));
        awtinvoke(jTextArea,'setSelectionStart(I)',selectionStart);
        awtinvoke(jTextArea,'setSelectionEnd(I)',  selectionEnd);
        awtinvoke(jTextArea,'repaint()');
    catch
        % Never mind...
        debug = 1;  %#ok
    end
end  % setPromptTimerFcn