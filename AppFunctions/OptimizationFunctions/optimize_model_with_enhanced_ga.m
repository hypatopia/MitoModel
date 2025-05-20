function [optParams, fval, gaInfo, confIntervals] = optimize_model_with_enhanced_ga(params, data, Model, modeleqns, bootstrap_samples, progressHandle, options, progressDlg)
%{
Created by: Marzieh Eini Keleshteri, June 2024
==================================================
Enhanced Genetic Algorithm Optimization with Bootstrap
==================================================
This function optimizes model parameters using an Enhanced Genetic Algorithm (GA)
with Bootstrap and returns the best parameters and their objective function value.

Inputs:
- params: Initial parameters for optimization
- data: Data used for model fitting
- Model.Type: Type of the model to optimize
- models: Available model options
- MAX_ITER: Maximum number of iterations to run the GA
- bootstrap_samples: Number of bootstrap samples to use

Outputs:
- optParams: Optimized parameters
- fval: Objective function value of the optimized parameters
- confIntervals: Confidence intervals for each optimized parameter
%}

% curdir = fileparts(which(mfilename));
curdir = fileparts(fileparts(fileparts(which(mfilename))));
saveDir = fullfile(curdir, 'OptimizedSolutions');

% Ensure directory exists for saving results
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end


% Define the objective function
Model_obj_Func = @(params_to_Opt, data) mse_error(params_to_Opt, params, data, Model, modeleqns);

% Set bounds for the parameters
rangeLow = params.rangeLow;
rangeUp = params.rangeUp;

% Set the number of variables (parameters to optimize)
nvars = numel(rangeLow);

% Preallocate arrays to store results from each bootstrap sample
bootstrapParams = zeros(bootstrap_samples, nvars);
bootstrapFvals = zeros(bootstrap_samples, 1);

% Initialize GA info structure
gaInfo = struct('numIterations', 0, ...
    'PopulationSize', 0, ...
    'MaxGenerations', 0, ...
    'CrossoverFraction', 0.8, ...
    'gaError', inf);

% Record start time
startTime = tic;

% Run GA optimization for each bootstrap sample
for i_bootstrap = 1:bootstrap_samples
    % Resample the data with replacement
    resampleIdx = randi(size(data, 1), size(data, 1), 1);
    resampledData = data(resampleIdx, :);

    % Update the options with the current counter value
    progressHandle.counter = i_bootstrap;

    options = optimoptions(options, ...
        'OutputFcn', @(options, state, flag) GAOutputFunction(options, state, flag, progressDlg, [], [], progressHandle, bootstrap_samples));
    % Run the GA optimization on the resampled data
    [params_opt, fval, exitFlag, output] = ga(@(params_to_Opt, data) Model_obj_Func(params_to_Opt, resampledData), ...
        nvars, [], [], [], [], rangeLow, rangeUp, [], options);

    % Store the results
    bootstrapParams(i_bootstrap, :) = params_opt;
    bootstrapFvals(i_bootstrap) = fval;

    % Capture success information for each run
    switch exitFlag
        case 1
            gaInfo.successInfo = 'Optimization terminated successfully.';
        case 0
            gaInfo.successInfo = 'Maximum number of generations exceeded.';
        case -1
            gaInfo.successInfo = 'Optimization terminated by user.';
        case -2
            gaInfo.successInfo = 'No feasible solution found.';
        otherwise
            gaInfo.successInfo = 'Optimization terminated with unknown status.';
    end
end

% Aggregate results: Use the mean of the optimized parameters as the final result
optParams = mean(bootstrapParams, 1);
fval = mean(bootstrapFvals);

% Compute confidence intervals using bootci
confIntervals = bootci(bootstrap_samples, {@mean, bootstrapParams});
% Here, @mean is the function applied to the bootstrap samples, and bootstrapParams is the array of bootstrap samples.

% Update GA info
gaInfo.numIterations = bootstrap_samples;
gaInfo.PopulationSize = options.PopulationSize;
gaInfo.MaxGenerations = options.MaxGenerations;
gaInfo.gaError = fval;
gaInfo.bootstrapSamples = bootstrap_samples;

% Record the end time and calculate duration
gaInfo.Duration = toc(startTime);


% Convert bestFval to string and replace '.' with '_' for file naming
bestFval_str = strrep(num2str(fval, '%.4f'), '.', '_');

% Ensure ii is formatted as an integer
bootstrap_samples_str = num2str(bootstrap_samples);

% Prepare the filename
fileName = sprintf('OptSln_%s_Date_%s_Time_%s_nBootStrps_%s_Error_%s_MaxGens_%d.mat', ...
    getenv('COMPUTERNAME'), ...
    datetime('now','Format','dd-MM-yy'), ...
    datetime('now', 'Format','HH_mm_ss'), ...
    bootstrap_samples_str, ...
    bestFval_str, ...
    gaInfo.MaxGenerations);


% Save GA results
save(fullfile(saveDir, fileName), 'optParams', 'fval', 'gaInfo');

% Create table for Excel export
paramNames = arrayfun(@(n) sprintf('Param_%d', n), 1:length(bestParams), 'UniformOutput', false);
T = table(paramNames', bestParams', 'VariableNames', {'Parameter', 'OptimizedValue'});

% Prepare the filename for the Excel file
fileName = sprintf('OptSln_GA_%s_Date_%s_Time_%s_Iter_%s_Error_%s_Gens_%d.xlsx', ...
    getenv('COMPUTERNAME'), ...
    datetime('now','Format','dd-MM-yy'), ...
    datetime('now', 'Format','HH_mm_ss'), ...
    ii_str, ...
    bestFval_str, ...
    gaInfo.numGenerations);

% Export table to Excel
excelFileName = fullfile(saveDir, fileName);
writetable(T, excelFileName);

end