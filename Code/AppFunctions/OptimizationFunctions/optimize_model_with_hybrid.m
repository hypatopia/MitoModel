function [optParams, fval, gaInfo] = optimize_model_with_hybrid(params, data, Model, models, max_gen, progressDlg)
%{
Created by: Marzieh Eini Keleshteri, June 2024
==================================================
Hybrid Optimization Function
==================================================
This function optimizes model parameters using a Genetic Algorithm
followed by a local optimization method and returns the best parameters
and their objective function value.

Inputs:
- params: Initial parameters for optimization
- data: Data used for model fitting
- Model.Type: Type of the model to optimize
- models: Available model options
- max_iter: Maximum number of iterations for the GA

Outputs:
- optParams: Optimized parameters
- fval: Objective function value of the optimized parameters
%}

% curdir = fileparts(which(mfilename));
curdir = fileparts(fileparts(fileparts(which(mfilename))));
saveDir = fullfile(curdir, 'OptimizedSolutions');

% Ensure directory exists for saving results
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end


% Define the objective function
Model_obj_Func = @(params_to_Opt) mse_error(params_to_Opt, params, data, Model, models);

% Set bounds for the parameters
rangeLow = params.rangeLow;
rangeUp = params.rangeUp;

% Set the number of variables (parameters to optimize)
nvars = numel(rangeLow);

% Initialize GA info structure
gaInfo = struct('numIterations', 0, ...
    'PopulationSize', 0, ...
    'MaxGenerations', 0, ...
    'CrossoverFraction', 0.8, ...
    'gaError', inf);

% Record start time
startTime = tic;

% Set GA options
options = optimoptions('ga', ...
    'PopulationSize', 100, ...
    'MaxGenerations', max_gen, ...
    'CrossoverFraction', 0.8, ...
    'MutationFcn', @mutationadaptfeasible, ...
    'Display', 'iter', ...
    'UseParallel', true, ...
    'PlotFcn', {@gaplotbestf, @gaplotstopping, @gaplotgenealogy}, ...
    'OutputFcn', @(options, state, flag) GAOutputFunction(options, state, flag, progressDlg, [], [],[], []),...
    'HybridFcn', @fmincon);

% Run GA optimization followed by a local optimization
[x, fval, exitFlag, output] = ga(Model_obj_Func, nvars, [], [], [], [], rangeLow, rangeUp, [], options);

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
gaInfo.numIterations = gaInfo.numIterations + 1;
gaInfo.numGenerations = output.generations;
gaInfo.PopulationSize = options.PopulationSize;
gaInfo.MaxGenerations = options.MaxGenerations;
gaInfo.gaError = fval;

% Record the end time and calculate duration
gaInfo.Duration = toc(startTime);

% Save the final optimized parameters
save('optimized_params_hybrid.mat', 'x');

optParams = x;

% Convert bestFval to string and replace '.' with '_' for file naming
bestFval_str = strrep(num2str(fval, '%.4f'), '.', '_');


% Prepare the filename
fileName = sprintf('OptSln_HybridGA_%s_Date_%s_Time_%s_Error_%s_Gens_%d.mat', ...
    getenv('COMPUTERNAME'), ...
    datetime('now','Format','dd-MM-yy'), ...
    datetime('now', 'Format','HH_mm_ss'), ...
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
