function [optParams, fval, gaInfo] = optimize_ga_batch(params, data, Model, modeleqns, options)
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

% Ensure directory exists for saving results
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

% Record start time
startTime = tic;

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

% Update GA info
gaInfo.numGenerations = output.generations;

% Update the number of iterations and record duration
gaInfo.numIterations = 1;
gaInfo.Duration = toc(startTime);

% Save the optimized parameters
save(fullfile(saveDir, 'optimized_params.mat'), 'bestParams');

% Return the best parameters and their objective function value
optParams = bestParams;
fval = bestFval;

% % Create table for Excel export
% paramNames = arrayfun(@(n) sprintf('Param_%d', n), 1:length(bestParams), 'UniformOutput', false);
% T = table(paramNames', bestParams', 'VariableNames', {'Parameter', 'OptimizedValue'});
% 
% % Prepare the filename for the Excel file
% fileName = sprintf('OptSln_GA_%s_Date_%s_Time_%s_Error_%.4f_Gens_%d.xlsx', ...
%     getenv('COMPUTERNAME'), ...
%     datestr(now, 'dd-MM-yy'), ...
%     datestr(now, 'HH_mm_ss'), ...
%     bestFval, ...
%     gaInfo.numGenerations);
% 
% % Export table to Excel
% excelFileName = fullfile(saveDir, fileName);
% writetable(T, excelFileName);

% Finalize progress dialog
progressDlg.Message = 'GA Optimization Complete';
progressDlg.Value = 1.0;
end
