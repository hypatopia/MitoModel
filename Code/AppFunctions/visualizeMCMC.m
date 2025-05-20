function visualizeMCMC(samples, results)
    numParams = size(samples, 2);
    
    % Trace Plot
    % figure;
    for i = 1:numParams
        % subplot(numParams, 1, i);
        figure(i);
        plot(samples(:, i));
        xlabel('Iteration');
        ylabel(['Parameter ' num2str(i)]);
        title(['Trace Plot for Parameter ' num2str(i)]);
    end

    % Histogram with KDE
    % figure;
    for i = 1:numParams
        % subplot(numParams, 1, i);
        figure(i);
        histogram(samples(:, i), 'Normalization', 'pdf');
        hold on;
        [f, xi] = ksdensity(samples(:, i));
        plot(xi, f, 'LineWidth', 2);
        xlabel(['Parameter ' num2str(i)]);
        ylabel('Density');
        title(['Density Plot for Parameter ' num2str(i)]);
        hold off;
    end

    % Autocorrelation Plot
    % figure;
    for i = 1:numParams
        % subplot(numParams, 1, i);
        figure(i);
        autocorr(samples(:, i), 'NumLags', 50);
        xlabel('Lag');
        ylabel('Autocorrelation');
        title(['Autocorrelation for Parameter ' num2str(i)]);
    end

    % Pairwise Scatter Plots
    % figure;
    for i = 1:numParams
        for j = i+1:numParams
            % subplot(numParams, numParams, (i-1)*numParams + j);
            figure((i-1)*numParams + j);
            scatter(samples(:, i), samples(:, j), '.');
            xlabel(['Param ' num2str(i)]);
            ylabel(['Param ' num2str(j)]);
            title(['Pairwise: Param ' num2str(i) ' vs ' num2str(j)]);
        end
    end

    % Display Summary Statistics
    disp('Parameter Summary Statistics:');
    for i = 1:numParams
        fprintf('Parameter %d: Mean = %.4f, Median = %.4f, 95%% CI = [%.4f, %.4f]\n', ...
            i, results.meanParams(i), results.medianParams(i), ...
            results.confidenceIntervals(1, i), results.confidenceIntervals(2, i));
    end
end
