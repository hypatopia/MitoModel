function stop = ga_progress(~, optimValues, ~, progressDlg, totalIterations)
%{
Created by: Marzieh Eini Keleshteri, June 2024
==================================================
% Progress update function for GA
%}

    % Check if the progress dialog is cancelled
    if isvalid(progressDlg) && ishandle(progressDlg)
        % Update progress based on current iteration
        iteration = optimValues.iteration;
        progress = iteration / totalIterations;
        estimatedRemaining = totalIterations - iteration;
        if progress > 1
            progress = 1;
        end
        % Update progress dialog
        progressDlg.Value = progress;
        progressDlg.Message = sprintf('Running Genetic Algorithm...\nIteration: %d/%d\nEstimated Remaining: %d', iteration, totalIterations, estimatedRemaining);
        % Check if cancel button is pressed
        stop = progressDlg.CancelRequested;
    else
        % If progress dialog is closed, stop optimization
        stop = true;
    end
end