% % ------------------- Visualization --------------------
% 1. Sample Value vs Iteration (Trace Plot)
% Shows how the sampled values for each parameter evolve over the MCMC iterations.
% This is helpful to visualize whether the chain has stabilized and is exploring the parameter space effectively.
figure;
for i = 1:numParams
    subplot(4, 4, i);
    plot(1:mccount, samples(:, i));
    xlabel('Iteration');
    ylabel(['Parameter ' num2str(i)]);
    title(['Sample Value vs Iteration for Parameter ' num2str(i)]);
end

figure;
for i = 1:size(app.MCMCResults.samples, 2)
    subplot(4, 4, i); % Adjust grid size for 16 parameters
    plot(app.MCMCResults.samples(:, i));
    title(['Trace Plot for Param ', num2str(i)]);
    xlabel('Iteration');
    ylabel('Parameter Value');
end




% 2. Sample Value vs Density (Histogram with KDE)
% Displays the posterior distribution of each parameter based on the MCMC samples.
% The histogram is normalized to represent the probability density function, and the kernel density estimate (KDE) smooths the histogram to visualize the underlying distribution.
figure;
for i = 1:numParams
    subplot(4, 4, i);
    histogram(samples(:, i), 'Normalization', 'pdf');
    hold on;
    [f, xi] = ksdensity(samples(:, i)); % Kernel Density Estimate
    plot(xi, f, 'LineWidth', 2);
    xlabel(['Parameter ' num2str(i)]);
    ylabel('Density');
    title(['Sample Value vs Density for Parameter ' num2str(i)]);
end


% 3. Lag vs Autocorrelation
% Visualizes the autocorrelation function of the samples, which helps to diagnose whether
% the samples are independent. Ideally, autocorrelation should decay as the lag increases,
% indicating that the chain is mixing well and the samples are not correlated over time.
figure;
for i = 1:numParams
    subplot(4, 4, i);
    autocorr(samples(:, i), 'NumLags', 50); % Adjust the number of lags as needed
    xlabel('Lag');
    ylabel('Autocorrelation');
    title(['Lag vs Autocorrelation for Parameter ' num2str(i)]);
end


% 4. Pairwise Scatter Plots

numParams = size(app.MCMCResults.samples, 2);
for i = 1:numParams
    figure;
    for j = i+1:numParams
        subplot(numParams, numParams, (i-1)*numParams + j);
        scatter(app.MCMCResults.samples(:, i), app.MCMCResults.samples(:, j));
        title(['Param ' num2str(i) ' vs Param ' num2str(j)]);
    end
end

% 5. Summary Statistics
meanParams = app.MCMCResults.meanParams;
medianParams = app.MCMCResults.medianParams;
confidenceIntervals = app.MCMCResults.confidenceIntervals;

% Display the results
disp('Parameter Summary Statistics:');
for i = 1:length(meanParams)
    fprintf('Parameter %d: Mean = %f, Median = %f, 95%% CI = [%f, %f]\n', ...
        i, meanParams(i), medianParams(i), confidenceIntervals(i, 1), confidenceIntervals(i, 2));
end

% Specify the filename
filename = 'mcmcSampleMatrix.xlsx';

% Write the matrix to the Excel file
writematrix(samples, filename);