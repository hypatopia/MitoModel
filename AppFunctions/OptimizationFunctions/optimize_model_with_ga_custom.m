function [optParams, fval, gaInfo] = optimize_model_with_ga_custom(params, data, Model, modeleqns, No_Iter, options, progressDlg)
%{
Created by: Marzieh Eini Keleshteri, June 2024
==================================================
Custom Genetic Algorithm Optimization of Model Parameters
==================================================
This function optimizes model parameters using the Genetic Algorithm (GA)
with custom options specified by the user, and returns the optimized parameters
and their objective function value.

Inputs:
- params: Initial parameters for optimization
- data: Data used for model fitting
- Model.Type: Type of the model to optimize
- modeleqns: Available model options
- No_Iter: Number of iterations to run the GA
- options: GA options
- progressDlg: Progress dialog handle

Outputs:
- optParams: Optimized parameters
- fval: Objective function value of the optimized parameters
- gaInfo: Struct containing GA optimization information
%}

% Define base directory for saving optimized solutions
curdir = fileparts(fileparts(fileparts(which(mfilename))));
saveDir = fullfile(curdir, 'OptimizedSolutions');
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end


% Define the objective function
Model_obj_Func = @(params_to_Opt) mse_error(params_to_Opt, params, data, Model, modeleqns);

% Set bounds for the parameters
rangeLow = params.rangeLow;
rangeUp = params.rangeUp;

% Set the number of variables (parameters to optimize)
nvars = numel(rangeLow);

% Initialize variables to store the best parameters and their objective function value
bestParams = [];
bestFval = inf;

% Initialize GA info structure
gaInfo = struct('numIterations', 0, 'PopulationSize', options.PopulationSize, ...
    'MaxGenerations', options.MaxGenerations, 'CrossoverFraction', options.CrossoverFraction, ...
    'gaError', inf, 'successInfo', '', 'numGenerations', 0, 'Duration', 0);

% Get the node number from environment variables (example: SLURM_NODEID)
node_number = getenv('SLURM_NODEID'); % Change this according to your scheduler
if isempty(node_number)
    node_number = 'unknown';
end

% Ensure directory exists for saving results
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

% Record start time
startTime = tic;

% Run GA multiple iterations
for ii = 1:No_Iter
    % Update progress dialog
    options = optimoptions(options, 'OutputFcn', ...
        @(options, state, flag) GAOutputFunction(options, state, flag, progressDlg, ii, No_Iter, [], []));

    % Run GA optimization
    [x, fval, exitFlag, output] = ga(Model_obj_Func, nvars, [], [], [], [], rangeLow, rangeUp, [], options);

    % Update best parameters if the current solution is better
    if fval < bestFval
        bestFval = fval;
        bestParams = x;
    end

    % Update gaError with the best found objective function value
    gaInfo.gaError = bestFval;

    % Capture success information
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

    % Get current time for filename
    curr_time = datestr(now, 'HH_MM_SS');
    fileName = sprintf('Solution_%s_%s_%s_node_%s_iter_%d.mat', ...
        datestr(now, 'yyyy-mm-dd'), ...
        curr_time, ...
        getenv('COMPUTERNAME'), ...
        node_number, ...
        ii);

    % % Save GA results
    % save(fullfile(saveDir, fileName), 'x', 'fval');

    % Update GA info
    gaInfo.numGenerations = gaInfo.numGenerations + output.generations;
    gaInfo.PopulationSize = options.PopulationSize;
    gaInfo.MaxGenerations = options.MaxGenerations;
end

% Update the number of iterations
gaInfo.numIterations = No_Iter;

% Record the end time and calculate duration
gaInfo.Duration = toc(startTime);

% % Display optimized parameters
% disp('Optimized Parameters:');
% disp(bestParams);

% Save the optimized parameters
save(fullfile(saveDir, 'optimized_params.mat'), 'bestParams');

% Return the best parameters and their objective function value
optParams = bestParams;
fval = bestFval;

% Convert bestFval to string and replace '.' with '_' for file naming
bestFval_str = strrep(num2str(bestFval, '%.4f'), '.', '_');

% Ensure ii is formatted as an integer
ii_str = num2str(ii);

% Prepare the filename
fileName = sprintf('OptSln_GA_%s_Date_%s_Time_%s_Iter_%s_Error_%s_Gens_%d.mat', ...
    getenv('COMPUTERNAME'), ...
    datetime('now','Format','dd-MM-yy'), ...
    datetime('now', 'Format','HH_mm_ss'), ...
    ii_str, ...
    bestFval_str, ...
    gaInfo.numGenerations);

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
