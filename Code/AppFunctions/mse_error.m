function e = mse_error(GA_params, params, data, Model, modeleqns)
%{
    Created by: Marzieh Eini Keleshteri June 2024
    =====================================================
    Objective Function for Genetic Algorithm Optimization
    =====================================================
    This function computes the mean squared error (MSE) between the model 
    output and real data based on the given GA_params and model parameters.

    Inputs:
    - GA_params: Parameters optimized by Genetic Algorithm
    - params: Model parameters structure
    - data: Experimental data used for comparison
    - ModelType: Type of the model used
    - models: Available model options

    Outputs:
    - mse_error: Mean squared error between model output and real data

    Usage:
    mse_error = objectiveFunction(GA_params, params, data, 'linear', models);
%}

% Initialize the pH penalty
pH_penalty = 0;

% Update the model parameters with GA-suggested values
paramNames = {'f0_Vmax', 'cytctot', 'f0_Km', 'fIV_Vmax', 'fIV_Km', ...
    'fIV_K', 'fV_Vmax', 'fV_K', 'fV_Km', 'p_alpha', 'cytcredProp'};

              
for i = 1:length(paramNames)
    params.(paramNames{i}) = GA_params(i);
end


% Dynamically update FCCP-related parameters
if strcmp(Model.Type, 'FullModelGlobal')
    % Get the number of FCCP injections from app.params.alphas.num_alphas
    num_alphas = params.alphas.num_alphas;

    % Update the FCCP injection parameters in app.params.alphas
    for i = 1:num_alphas
        amp_field = sprintf('amp_%d', i);
        params.alphas.(amp_field) = GA_params(11 + i); % Adjusting indices for FCCP params
    end

    % Set the attenuateProp parameter, following the FCCP params
    params.attenuateProp = GA_params(12 + num_alphas);
end

% Initial condition for the ODE system: cytcox at t_0
params.cytcox = GA_params(2) * GA_params(11);
params.cytcred = params.cytctot - params.cytcox;

try
    % Solve the model with the updated parameters
    [t, y] = solver_mito(params, data, Model, modeleqns);

    % Ensure the solver output is as expected
    if isempty(y)
        error('Solver returned empty output.');
    end

    % Extract model output (e.g., oxygen level)
    model_O2 = y(:, 2);
    Hn = y(:, 3);
    Hp = y(:, 4);

    % Ensure RealO2Data field exists in params
    if ~isfield(params, 'RealO2Data')
        error('params.RealO2Data field is missing.');
    end

    % Calculate pH values
    Cal_pH_Hn = -log10(Hn * 1E-6);
    Cal_pH_Hp = -log10(Hp * 1E-6);

    % Apply pH penalty if out of range
    if any(Cal_pH_Hn < 2 | Cal_pH_Hn > 12) || any(Cal_pH_Hp < 2 | Cal_pH_Hp > 12) || any(Hp < Hn)
        pH_penalty = pH_penalty + 1e6;
    end

    % Calculate the error between the model and real data
    times = [1, data.oligo_i, data.f_1_i, data.f_2_i, data.f_3_i, data.f_4_i, data.inhibit_i];
    times = times(~cellfun(@isempty, num2cell(times)));  % Remove empty elements
    % inj_weight = ones(size(times));  % Define weights for each time point
    % inj_weight(2) = 1e2;

    % Compute weighted MSE with pH penalty
    error_O2 = sum(arrayfun(@(i) Model.Weight(i) * mean((model_O2(times(i):times(i+1)) - params.RealO2Data(times(i):times(i+1))).^2), 1:length(times) - 1));

    % Mean squared error
    % display('Mean squared error:')
    e = error_O2 + 0*pH_penalty;
catch ME
    % Handle errors gracefully and return a large error value
    disp(['Error in mse_error function: ', ME.message]);
    e = inf;
end
end
