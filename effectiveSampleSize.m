function ess = effectiveSampleSize(samples)
    % Calculate the Effective Sample Size (ESS) for an MCMC chain
    % samples: Vector of MCMC samples for a single parameter

    N = length(samples); % Total number of samples
    autoCorr = autocorr(samples, 'NumLags', N-1); % Autocorrelation for all lags
    positiveCorr = autoCorr(autoCorr > 0); % Include only positive autocorrelations

    % ESS formula: N / (1 + 2 * sum(positive autocorrelations))
    ess = N / (1 + 2 * sum(positiveCorr));
end