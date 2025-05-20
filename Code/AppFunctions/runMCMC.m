function runMCMC(app, mccount, skip, initialStepSize, confidenceLevel)
    % Use optimized parameters as initial values
    initialParams = app.OptimOutput.Params;

    % Define parameter bounds
    % rangeLow = app.params.rangeLow;
    % rangeUp = 0.1*app.params.rangeUp;
    rangeLow = max(0.1 * initialParams, app.params.rangeLow);
    rangeUp = min(10 * initialParams, app.params.rangeUp);

    % Normalize the parameters
    scaleFactor = rangeUp - rangeLow;
    scaledInitialParams = (initialParams - rangeLow) ./ scaleFactor;

    % Define the likelihood function (scale theta back to original space)
    loglikelihood = @(scaledTheta) calce_log_likelihood_negateMSE( ...
        scaledTheta .* scaleFactor + rangeLow, app.params, app.data, app.Model, app.modeleqns);

    % Define the log-prior distribution
    variance = max(scaleFactor / 10, 1e-5); % Adjust variance based on scale
    penalty = 1e3; % Stricter penalty for bounds violations
    logmodelprior = @(scaledTheta) sum((scaledTheta >= 0 & scaledTheta <= 1) .* ...
        -((scaledTheta - scaledInitialParams).^2 ./ (2 * (variance ./ scaleFactor).^2))) ...
        - penalty * sum(scaledTheta < 0 | scaledTheta > 1); % Add penalty for out-of-bounds

    % Define base proposal step function
    baseStepFunction = @(theta) randn(size(theta)) * initialStepSize;

    % Define adaptive step size function
    adaptiveStepFunction = @(theta, currentStepSize) adaptStepFunction( ...
        theta, baseStepFunction, logmodelprior, currentStepSize, 0.25, 0.05);

    % Run the adaptive MCMC sampling
    [samples, logP, acceptanceRate, overallAcceptanceRate, avgLogPrior, avgLogLikelihood, reject] = ...
        mcmc(scaledInitialParams, loglikelihood, logmodelprior, ...
        @(theta) adaptiveStepFunction(theta, initialStepSize), mccount, skip);

    % Store results in app property (scale samples back to original space)
    app.MCMCResults.samples = samples .* scaleFactor + rangeLow;

    % Derived Parameter: params.cytcred
    cytcred_samples = app.MCMCResults.samples(:, 2) .*(1 - app.MCMCResults.samples(:, 11)) ;
    % Update parameter name in LaTeX
    app.results.parameterNames_LaTeX{11} = '$r(0)$';

    % Replace parameter 11 with params.cytcred
    app.MCMCResults.samples(:, 11) = cytcred_samples;

    app.MCMCResults.logP = logP;
    app.MCMCResults.acceptanceRate = acceptanceRate;
    app.MCMCResults.overallAcceptanceRate = overallAcceptanceRate;
    app.MCMCResults.avgLogPrior = avgLogPrior;
    app.MCMCResults.avgLogLikelihood = avgLogLikelihood;
    app.MCMCResults.reject = reject;

    % Compute mean, median, and confidence intervals
    numParams = size(app.MCMCResults.samples, 2);
    meanParams = mean(app.MCMCResults.samples, 1);
    medianParams = median(app.MCMCResults.samples, 1);
    confidenceIntervals = zeros(numParams, 2);
    lowerPercentile = (1 - confidenceLevel) / 2;
    upperPercentile = 1 - lowerPercentile;

    for i = 1:numParams
        sortedSamples = sort(app.MCMCResults.samples(:, i));
        numSamples = length(sortedSamples);

        % Indices for confidence intervals
        lowerIndex = max(round(numSamples * lowerPercentile), 1);
        upperIndex = min(round(numSamples * upperPercentile), numSamples);
        confidenceIntervals(i, :) = [sortedSamples(lowerIndex), sortedSamples(upperIndex)];
    end

    % Store statistics
    app.MCMCResults.meanParams = meanParams;
    app.MCMCResults.medianParams = medianParams;
    app.MCMCResults.confidenceIntervals = confidenceIntervals;

    % Diagnostics and Plots
    % diagnoseMCMC(app, samples .* scaleFactor + rangeLow);
    
end


% % function runMCMC(app, mccount, skip, stepSize, confidenceLevel)
% %     % Use optimized parameters as initial values
% %     initialParams = app.OptimOutput.Params';
% %
% %     % Define parameter bounds
% %     % rangeLow = app.params.rangeLow;
% %     % rangeUp = app.params.rangeUp;
% %     rangeLow = max(0 * initialParams, app.params.rangeLow);
% %     rangeUp = min(1e1 * initialParams, app.params.rangeUp);
% %
% %     % Normalize the parameters
% %     scaleFactor = rangeUp - rangeLow;
% %     scaledInitialParams = (initialParams - rangeLow)./ scaleFactor;
% %
% %     % Define the likelihood function (scale theta back to original space)
% %     loglikelihood = @(scaledTheta) calce_log_likelihood_negateMSE( ...
% %         scaledTheta .* scaleFactor + rangeLow, app.params, app.data, app.Model, app.modeleqns);
% %
% %     % Define the log-prior distribution
% %     variance = max(scaleFactor / 10, 1e-4); % Adjust variance based on scale
% %     penalty = 1e5; % Lower penalty for boundary violations
% %     logmodelprior = @(scaledTheta) sum((scaledTheta >= 0 & scaledTheta <= 1) .* ...
% %         -((scaledTheta - scaledInitialParams).^2 ./ (2 * (variance ./ scaleFactor).^2))) ...
% %         - penalty * sum(scaledTheta < 0 | scaledTheta > 1);
% %
% %     % Define the proposal distribution (in scaled space)
% %     stepFunction = @(scaledTheta) randn(size(scaledTheta)) * stepSize;
% %     % stepFunction = @(theta) randn(size(theta)) * stepSize;
% %
% %     % Run the MCMC sampling
% %     [samples, logP, acceptanceRate, overallAcceptanceRate, avgLogPrior, avgLogLikelihood, reject] = ...
% %         mcmc(scaledInitialParams, loglikelihood, logmodelprior, stepFunction, mccount, skip);
% %
% %     % Store results in app property (scale samples back to original space)
% %     app.MCMCResults.samples = samples .* scaleFactor + rangeLow;
% %     app.MCMCResults.logP = logP;
% %     app.MCMCResults.acceptanceRate = acceptanceRate;
% %     app.MCMCResults.overallAcceptanceRate = overallAcceptanceRate;
% %     app.MCMCResults.avgLogPrior = avgLogPrior;
% %     app.MCMCResults.avgLogLikelihood = avgLogLikelihood;
% %     app.MCMCResults.reject = reject;
% %
% %     % Compute mean, median, and confidence intervals
% %     numParams = size(samples, 2);
% %     meanParams = mean(app.MCMCResults.samples, 1);
% %     medianParams = median(app.MCMCResults.samples, 1);
% %     confidenceIntervals = zeros(numParams, 2);
% %     lowerPercentile = (1 - confidenceLevel) / 2;
% %     upperPercentile = 1 - lowerPercentile;
% %
% %     for i = 1:numParams
% %         sortedSamples = sort(app.MCMCResults.samples(:, i));
% %         numSamples = length(sortedSamples);
% %
% %         % Compute indices for percentiles
% %         lowerIndex = max(round(numSamples * lowerPercentile), 1); % Ensure index is at least 1
% %         upperIndex = min(round(numSamples * upperPercentile), numSamples); % Ensure index does not exceed the number of samples
% %
% %         % Get confidence interval values
% %         confidenceIntervals(i, :) = [sortedSamples(lowerIndex), sortedSamples(upperIndex)];
% %     end
% %
% %     % Store statistics
% %     app.MCMCResults.meanParams = meanParams;
% %     app.MCMCResults.medianParams = medianParams;
% %     app.MCMCResults.confidenceIntervals = confidenceIntervals;
% %
% %     % Diagnostics and Plots
% %     diagnoseMCMC(app, samples .* scaleFactor + rangeLow);
% % end



% % % % function runMCMC(app, mccount, skip, stepSize, confidenceLevel)
% % % % % Use optimized parameters as initial values
% % % % initialParams = app.OptimOutput.Params';
% % % %
% % % % % Define parameter bounds
% % % % rangeLow = app.params.rangeLow;
% % % % rangeUp = app.params.rangeUp;
% % % %
% % % % % Define the likelihood and prior functions
% % % % loglikelihood = @(theta) calce_log_likelihood_negateMSE(theta, app.params, app.data, app.Model, app.modeleqns)/1000;
% % % %
% % % % % rangeDiff = rangeUp - rangeLow;
% % % % % variance = rangeDiff ./ ((initialParams > 1e3) * 1e3 + (initialParams <= 100) * 10);
% % % % % variance = (rangeUp - rangeLow) ./ ((initialParams > 1e3) * 1e2 + (initialParams <= 100) * 10 + 1);
% % % % % variance = (0.1 * initialParams).^1;
% % % % % variance = max((rangeUp - rangeLow) / 100, 1e-6);
% % % %
% % % % % variance = (rangeUp - rangeLow) ./ (10 * (initialParams < 1) + 1); % Adjust based on parameter scale
% % % % variance = max((rangeUp - rangeLow) / 5, 1e-4); % Smaller variance for tighter constraints
% % % % penalty = 10^3; % Lower penalty
% % % % logmodelprior = @(theta) sum((theta >= rangeLow & theta <= rangeUp) .* ...
% % % %     -((theta - initialParams).^2 ./ (2 * variance.^2))) ...
% % % %     - penalty * sum(theta < rangeLow | theta > rangeUp);
% % % %
% % % %
% % % %
% % % % % Define the proposal distribution
% % % %     % paramBounds = rangeUp - rangeLow;
% % % %     % paramBounds = initialParams + variance;
% % % %     % paramBounds = rangeUp - rangeLow;
% % % %     % covMatrix = diag((paramBounds / 10).^2); % Reduce variance for more gradual steps
% % % %     % [T, err] = chol(covMatrix);
% % % %     % if err ~= 0
% % % %     %     error('Covariance matrix not positive definite. Adjust parameter bounds.');
% % % %     % end
% % % %     % stepFunction = @(theta) max(min(randn(size(theta)) * T * stepSize + theta, rangeUp), rangeLow);
% % % %
% % % % % % Define the proposal distribution
% % % % stepFunction = @(theta) randn(size(theta)) * stepSize;
% % % %
% % % %
% % % %
% % % % % logmodelprior = @(theta) sum((theta >= rangeLow & theta <= rangeUp) .* ...
% % % % %     -((theta - initialParams).^2) ./ ((theta - initialParams).^2))...
% % % % %      - 0*1e5 * sum(theta < 1*rangeLow | theta > 1*rangeUp);
% % % %
% % % % % logmodelprior = @(theta) sum((theta >= rangeLow & theta <= rangeUp) .* ...
% % % % %     -(((theta - initialParams).^2) / 12))...
% % % % %      - 1*1e6 * sum(theta < rangeLow | theta > rangeUp/2);
% % % %
% % % % % logmodelprior = @(theta) sum((theta >= rangeLow & theta <= rangeUp) .* ...
% % % % %     -(((theta - initialParams).^2) ./ (2 * (rangeUp - rangeLow))).^2)...
% % % % %      - 1*1e5 * sum(theta < 1.5*rangeLow | theta > 1*rangeUp);
% % % %
% % % % % logmodelprior = @(theta) sum((theta >= rangeLow & theta <= rangeUp) .* ...
% % % % %     -((theta - initialParams) ./ (0.1 * (rangeUp - rangeLow))).^2) ...
% % % % %     - 1e6 * sum(theta < rangeLow | theta > rangeUp);
% % % %
% % % %
% % % % % logmodelprior = @(theta) -sum(((theta - initialParams).^2) ./ (0.1 * (rangeUp - rangeLow)) ...
% % % % %     - 1e6 * sum(theta < rangeLow | theta > rangeUp));
% % % % % logmodelprior = @(theta) -sum(theta.^2 / 10);  % Weak normal prior
% % % % % logmodelprior = @(theta) sum((theta >= rangeLow & theta <= rangeUp) .* ...
% % % % %     -((theta - initialParams) ./ (0.1 *(rangeUp - rangeLow)).^2))...
% % % % %      - 1*1e2 * sum(theta < rangeLow | theta > rangeUp); % over-constraining
% % % % % variance = (rangeUp - rangeLow).^2 / 12; % As an initial guess
% % % % % logmodelprior = @(theta) sum((theta >= rangeLow & theta <= rangeUp) .* ...
% % % % %                              -((theta - initialParams).^2 ./ (2 * variance))) ...
% % % % %                 - 1e6 * sum(theta < rangeLow | theta > rangeUp);
% % % %
% % % % % Prior with penalties outside bounds
% % % % % logmodelprior = @(theta) sum((theta >= rangeLow & theta <= rangeUp) .* ...
% % % % %     -((theta - mean([rangeLow; rangeUp], 1)) ./ (rangeUp - rangeLow)).^2) ...
% % % % %     - 1e6 * sum(theta < rangeLow | theta > rangeUp);  % Heavy penalty for out-of-bounds values
% % % %
% % % % % % Step function with bounds
% % % % % paramBounds = rangeUp - rangeLow;
% % % % % covMatrix = diag((paramBounds / 8).^2);  % Variance scaled to 1/8 of the parameter range
% % % % % [T, err] = chol(covMatrix);  % Cholesky decomposition
% % % % % if err ~= 0
% % % % %     error('Covariance matrix is not positive definite. Check parameter bounds.');
% % % % % end
% % % % % stepFunction = @(theta) max(min(randn(size(theta)) * T * stepSize + theta, rangeUp), rangeLow);
% % % %
% % % % % Define the proposal distribution
% % % % % stepFunction = @(theta) randn(size(theta)) * stepSize;
% % % %
% % % %
% % % % % Run the MCMC sampling
% % % % [samples, logP, acceptanceRate, overallAcceptanceRate, avgLogPrior, avgLogLikelihood, reject] = mcmc(initialParams, loglikelihood, logmodelprior, stepFunction, mccount, skip);
% % % %
% % % %
% % % % % Store MCMC results in app property
% % % % app.MCMCResults.samples = samples; % Store all MCMC samples
% % % % app.MCMCResults.logP = logP; % Store logP
% % % % app.MCMCResults.acceptanceRate = acceptanceRate;
% % % % app.MCMCResults.overallAcceptanceRate= overallAcceptanceRate;
% % % % app.MCMCResults.avgLogPrior = avgLogPrior;
% % % % app.MCMCResults.avgLogLikelihood = avgLogLikelihood;
% % % % app.MCMCResults.reject = reject;
% % % %
% % % % % Compute mean, median, and confidence intervals
% % % % numParams = size(samples, 2);
% % % % app.MCMCResults.meanParams = mean(samples, 1); % Mean of the samples
% % % % app.MCMCResults.medianParams = median(samples, 1); % Median of the samples
% % % %
% % % % % Compute confidence intervals (using percentiles for MCMC)
% % % % lowerPercentile = (1 - confidenceLevel) / 2;
% % % % upperPercentile = 1 - lowerPercentile;
% % % % confidenceIntervals = zeros(numParams, 2);
% % % %
% % % % for i = 1:numParams
% % % %     sortedSamples = sort(samples(:, i));
% % % %     numSamples = length(sortedSamples);
% % % %
% % % %     % Compute indices for percentiles
% % % %     lowerIndex = max(round(numSamples * lowerPercentile), 1); % Ensure index is at least 1
% % % %     upperIndex = min(round(numSamples * upperPercentile), numSamples); % Ensure index does not exceed the number of samples
% % % %
% % % %     % Get confidence interval values
% % % %     lowerCI = sortedSamples(lowerIndex);
% % % %     upperCI = sortedSamples(upperIndex);
% % % %     confidenceIntervals(i, :) = [lowerCI, upperCI];
% % % % end
% % % % app.MCMCResults.confidenceIntervals = confidenceIntervals; % Confidence intervals
% % % %
% % % % % Diagnostics and Plots
% % % %     diagnoseMCMC(app, samples);
% % % % end




% function runMCMC(app, mccount, skip, stepSize, confidenceLevel)
%     % Use optimized parameters as initial values
%     initialParams = app.OptimOutput.Params';
%
%     % Define parameter bounds
%     rangeLow = app.params.rangeLow;
%     rangeUp = app.params.rangeUp;
%     stepSizes = (rangeUp - rangeLow) / 10; % Example step sizes based on bounds
%
%     % Define the likelihood and prior functions
%     loglikelihood = @(theta) calce_log_likelihood_negateMSE(theta, app.params, app.data, app.Model, app.modeleqns);
% logmodelprior = @(theta) -sum(((theta - mean(rangeLow + rangeUp) / 2) ./ (rangeUp - rangeLow)).^2);
%
%     % Define the proposal distribution with reflective bounds
%     stepFunction = @(theta) max(min(theta + randn(size(theta)) .* stepSizes, rangeUp), rangeLow);
%
%     % Run the MCMC sampling
%     [samples, logP, acceptanceRate, overallAcceptanceRate, avgLogPrior, avgLogLikelihood, reject] = ...
%         mcmc(initialParams, loglikelihood, logmodelprior, stepFunction, mccount, skip);
%
%     % Store MCMC results in app property
%     app.MCMCResults.samples = samples;
%     app.MCMCResults.logP = logP;
%     app.MCMCResults.acceptanceRate = acceptanceRate;
%     app.MCMCResults.overallAcceptanceRate = overallAcceptanceRate;
%     app.MCMCResults.avgLogPrior = avgLogPrior;
%     app.MCMCResults.avgLogLikelihood = avgLogLikelihood;
%     app.MCMCResults.reject = reject;
%
%     % Compute mean, median, and confidence intervals
%     numParams = size(samples, 2);
%     app.MCMCResults.meanParams = mean(samples, 1);
%     app.MCMCResults.medianParams = median(samples, 1);
%
%     % Compute confidence intervals
%     lowerPercentile = (1 - confidenceLevel) / 2;
%     upperPercentile = 1 - lowerPercentile;
%     confidenceIntervals = prctile(samples, [lowerPercentile * 100, upperPercentile * 100]);
%     app.MCMCResults.confidenceIntervals = confidenceIntervals;
% end







