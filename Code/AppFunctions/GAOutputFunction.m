function [state, options, optchanged] = GAOutputFunction(options, state, flag, progressDlg, Current_iter_no, No_Iter, progressHandle, bootstrap_sample)
%{
Created by: Marzieh Eini Keleshteri, June 2024
==================================================
Output function for Genetic Algorithm to update progress dialog.
==================================================
Inputs:
- options: GA options
- state: Current GA state
- flag: Current GA flag
- progressDlg: Handle to progress dialog
- iter_no: Number of iterations for GA

Outputs:
- state: Updated GA state
- options: Updated GA options
- optchanged: Flag indicating if options changed
%}

% Check if iteration number is passed in varargin
if ~isempty(Current_iter_no) && ~isempty(No_Iter)
    state.iter_max = No_Iter;
    state.iter_no = Current_iter_no;
else
    state.iter_max = 'Not Iterated';  % Default message when no No_iter is passed
end

persistent max_iter populationSize;
optchanged = false;

switch flag
    case 'init'
        % Initialize the progress dialog
        if isempty(progressDlg) || ~isvalid(progressDlg)
            progressDlg = uiprogressdlg(uifigure, 'Title', 'GA Progress', ...
                'Message', 'Starting...', 'Indeterminate', 'on');
        end
        max_iter = options.MaxGenerations;
        populationSize = options.PopulationSize;
        progressDlg.Indeterminate = 'off';
        disp('Starting the algorithm');

    case 'iter'
        % Update the progress dialog with iteration information
        if isvalid(progressDlg) 
            if ~isempty(Current_iter_no) && ~isempty(No_Iter)
            progressDlg.Value = state.Generation / max_iter;
            progressDlg.Message = sprintf(['Generation: %d out of %d\n'...
                'Population Size: %d\n' ...
                'Best score: %g\n' ...
                'Iteration: %d out of %d\n'], ...
                state.Generation, max_iter, populationSize, ...
                min(state.Score), state.iter_no, state.iter_max);
            drawnow;
            elseif isempty(Current_iter_no) && isempty(No_Iter) && isempty(bootstrap_sample)
            progressDlg.Value = state.Generation / max_iter;
            progressDlg.Message = sprintf(['Generation: %d out of %d\n'...
                   'Population Size: %d\n' ...
                   'Best score: %g\n' ...
                   'Iteration: %s\n'], ...
                   state.Generation, max_iter, populationSize, ...
                   min(state.Score), state.iter_max);
            drawnow;
            elseif ~isempty(bootstrap_sample)
                progressDlg.Value = state.Generation / max_iter;
                progressDlg.Message = sprintf(['Bootstrap Sample: %d out of %d\n' ...
                    'Generation:  %d out of %d\n'...
                    'Best score: %g\n' ...
                    'Population Size: %d\n' ...
                    'Iteration: %s\n'], ...
                    progressHandle.counter, bootstrap_sample, state.Generation, max_iter, min(state.Score), ...
                    populationSize, state.iter_max);
                drawnow;
            end
        end
        disp(['Iteration: ', num2str(state.Generation), ...
            ' Best score: ', num2str(min(state.Score)), ...
            ' Population Size: ', num2str(populationSize)]);

    case 'done'
        % Close the progress dialog when optimization is finished
        if state.Generation >= options.MaxGenerations
            progressDlg.Message = sprintf('GA stopped because it exceeded options.MaxGenerations.');
            if isfield(options, 'HybridFcn') && ~isempty(options.HybridFcn)
                progressDlg.Message = sprintf(['GA stopped because it exceeded options.MaxGenerations.\n' ...
                    'Switching to the hybrid optimization algorithm (FMINCON).']);
            end
        end
end
end