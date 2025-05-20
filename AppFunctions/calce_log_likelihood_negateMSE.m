function logL = calce_log_likelihood_negateMSE(theta, params, data, Model, modeleqns)
% Update model parameters with current MCMC sample
paramNames = {'f0_Vmax', 'cytctot', 'f0_Km', 'fIV_Vmax', 'fIV_Km', ...
    'fIV_K', 'fV_Vmax', 'fV_K', 'fV_Km', 'p_alpha', 'cytcredProp'};
for i = 1:length(paramNames)
    params.(paramNames{i}) = theta(i);
end

% Dynamically update FCCP-related parameters
if strcmp(Model.Type, 'FullModelGlobal')
    % Get the number of FCCP injections from app.params.alphas.num_alphas
    num_alphas = params.alphas.num_alphas;

    % Update the FCCP injection parameters in app.params.alphas
    for i = 1:num_alphas
        amp_field = sprintf('amp_%d', i);
        params.alphas.(amp_field) = theta(11 + i); % Adjusting indices for FCCP params
    end

    % Set the attenuateProp parameter, following the FCCP params
    params.attenuateProp = theta(12 + num_alphas);
end


% Initial condition for the ODE system: cytcox at t_0
params.cytcox = theta(2) * theta(11);
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
    pH_penalty = 0;
    if any(Cal_pH_Hn < 2 | Cal_pH_Hn > 12) || any(Cal_pH_Hp < 2 | Cal_pH_Hp > 12) || any(Hp < Hn)
        pH_penalty = 1e6;  % High penalty to discourage invalid solutions
    end

    % Calculate MSE
    times = [1, data.oligo_i, data.f_1_i, data.f_2_i, data.f_3_i, data.f_4_i, data.inhibit_i];
    times = times(~cellfun(@isempty, num2cell(times)));  % Remove empty elements
    error_O2 = sum(arrayfun(@(i) Model.Weight(i) * mean((model_O2(times(i):times(i+1)) - params.RealO2Data(times(i):times(i+1))).^2), 1:length(times) - 1));

    % Mean squared error with pH penalty
    mse = error_O2 + pH_penalty;

    % Convert MSE to log-likelihood (negative MSE for maximization)
    logL = -0.5 * log(mse);

catch ME
    % Handle errors gracefully and return a large negative value for log-likelihood
    disp(['Error in calce_log_likelihood_negateMSE function: ', ME.message]);
    logL = -1e6;  % Large negative value to indicate a poor fit
end
end


% I used the below function for tuning the mcmc but it did not work:
% function logL = calce_log_likelihood_negateMSE(theta, params, data, Model, modeleqns)
%     % Enforce parameter bounds to avoid unphysical values
%     if any(theta < params.rangeLow | theta > params.rangeUp)
%         logL = -1e6;  % Heavy penalty for out-of-bounds parameters
%         return;
%     end
% 
%     % Update model parameters with current MCMC sample
%     paramNames = {'f0_Vmax', 'cytctot', 'f0_Km', 'fIV_Vmax', 'fIV_Km', ...
%         'fIV_K', 'fV_Vmax', 'fV_K', 'fV_Km', 'p_alpha', 'cytcredProp'};
%     for i = 1:length(paramNames)
%         params.(paramNames{i}) = theta(i);
%     end
% 
%     % Dynamically update FCCP-related parameters
%     if strcmp(Model.Type, 'FullModelGlobal')
%         num_alphas = params.alphas.num_alphas;
%         for i = 1:num_alphas
%             amp_field = sprintf('amp_%d', i);
%             params.alphas.(amp_field) = theta(11 + i);
%         end
%         params.attenuateProp = theta(12 + num_alphas);
%     end
% 
%     % Initial condition for the ODE system: cytcox at t_0
%     params.cytcox = theta(2) * theta(11);
%     params.cytcred = params.cytctot - params.cytcox;
% 
%     try
%         % Solve the model with the updated parameters
%         [t, y] = solver_mito(params, data, Model, modeleqns);
% 
%         % Ensure the solver output is as expected
%         if isempty(y)
%             error('Solver returned empty output.');
%         end
% 
%         % Extract model output
%         model_O2 = y(:, 2);
%         Hn = y(:, 3);
%         Hp = y(:, 4);
% 
%         % Calculate pH values
%         Cal_pH_Hn = -log10(Hn * 1E-6);
%         Cal_pH_Hp = -log10(Hp * 1E-6);
% 
%         % Penalize invalid pH values or negative concentrations
%         if any(Cal_pH_Hn < 2 | Cal_pH_Hn > 12 | Cal_pH_Hp < 2 | Cal_pH_Hp > 12 | Hp < Hn)
%             logL = -1e6;
%             return;
%         end
% 
%         % Calculate MSE
%         times = [1, data.oligo_i, data.f_1_i, data.f_2_i, data.f_3_i, data.f_4_i, data.inhibit_i];
%         times = times(~cellfun(@isempty, num2cell(times))); % Remove empty elements
%         error_O2 = sum(arrayfun(@(i) Model.Weight(i) * ...
%             mean((model_O2(times(i):times(i+1)) - params.RealO2Data(times(i):times(i+1))).^2), ...
%             1:length(times) - 1));
% 
%         % Mean squared error to log-likelihood
%         mse = error_O2;
%         logL = -0.5 * mse; % Negative for maximization
%     catch ME
%         % Return a large negative value for log-likelihood on error
%         disp(['Error in calce_log_likelihood_negateMSE function: ', ME.message]);
%         logL = -1e6;
%     end
% end

