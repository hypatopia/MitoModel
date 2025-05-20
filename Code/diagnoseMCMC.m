function diagnoseMCMC(app, samples)
    % Number of parameters
    numParams = size(app.MCMCResults.samples, 2);

    % Ensure parameter names are defined
    if ~isfield(app.results, 'parameterNames_LaTeX') || isempty(app.results.parameterNames_LaTeX)
        error('Parameter names are not defined in the app results.');
    end

    % Set global formatting options
    titleFontSize = 16;
    labelFontSize = 16;
    tickFontSize = 12;



    %% Trace Plots
    figure('Name', 'Trace Plots');
    for i = 1:numParams
        subplot(ceil(sqrt(numParams)), ceil(sqrt(numParams)), i); % Dynamic layout
        plot(app.MCMCResults.samples(:, i), 'LineWidth', 0.6, 'Color', [0 0.5 0.8]);
        grid on;
        set(gca, 'FontWeight', 'bold', 'FontSize', tickFontSize);
        xlabel('Iteration', 'FontSize', labelFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
        ylabel(app.results.parameterNames_LaTeX{i}, 'FontSize', labelFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
        title(['Trace Plot for ', app.results.parameterNames_LaTeX{i}], ...
            'FontSize', titleFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
    end

    %% Autocorrelation Plots
    figure('Name', 'Autocorrelation');
    for i = 1:numParams
        subplot(ceil(sqrt(numParams)), ceil(sqrt(numParams)), i);
        autocorr(app.MCMCResults.samples(:, i), 'NumLags', 50);
        grid on;
        xlabel('Lag', 'FontSize', labelFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
        ylabel('Autocorrelation', 'FontSize', labelFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
        title(['Autocorrelation for ', app.results.parameterNames_LaTeX{i}], ...
            'FontSize', titleFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
    end

    %% Histograms with KDE and Statistics
    figure('Name', 'Histogram with KDE');
    for i = 1:numParams
        subplot(ceil(sqrt(numParams)), ceil(sqrt(numParams)), i);

        % Histogram
        histogram(app.MCMCResults.samples(:, i), 'Normalization', 'pdf', ...
            'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'k');
        hold on;

        % KDE
        [f, xi] = ksdensity(app.MCMCResults.samples(:, i));
        plot(xi, f, 'LineWidth', 2.5, 'Color', [0 0.5 0.8]);

        % Annotations: Mean and 95% CI
        mean_val = mean(app.MCMCResults.samples(:, i));
        ci = quantile(app.MCMCResults.samples(:, i), [0.025, 0.975]);
        xline(mean_val, '-.', 'Color', [0.6350 0.0780 0.1840], 'LineWidth', 2.5);
        xline(ci(1), '-.', 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 2.5);
        xline(ci(2), '-.', 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 2.5);

        legend({'Histogram', 'KDE', 'Mean', '95% CI'}, 'Location', 'best', 'FontSize', 14);
        grid on;
        set(gca, 'FontWeight', 'bold', 'FontSize', tickFontSize);
        xlabel(app.results.parameterNames_LaTeX{i}, 'FontSize', labelFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
        ylabel('Density', 'FontSize', labelFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
        title(['Density Plot for ', app.results.parameterNames_LaTeX{i}], ...
            'FontSize', titleFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
        hold off;
    end

    %% Summary Statistics
    disp('Parameter Summary Statistics:');
    for i = 1:numParams
        mean_val = mean(app.MCMCResults.samples(:, i));
        median_val = median(app.MCMCResults.samples(:, i));
        ci = quantile(app.MCMCResults.samples(:, i), [0.025, 0.975]);
        fprintf('Parameter %s: Mean = %.4f, Median = %.4f, 95%% CI = [%.4f, %.4f]\n', ...
            app.results.parameterNames_LaTeX{i}, mean_val, median_val, ci(1), ci(2));
    end

    %% Effective Sample Size
    ess = zeros(1, numParams);
    for i = 1:numParams
        ess(i) = effectiveSampleSize(app.MCMCResults.samples(:, i));
    end
    disp('Effective Sample Sizes:');
    disp(array2table(ess, 'VariableNames', app.results.parameterNames_LaTeX));
end


% % function diagnoseMCMC(app, samples)
% %     % Number of parameters
% %     numParams = size(app.MCMCResults.samples, 2);
% % 
% %     % Ensure parameter names are defined
% %     if ~isfield(app.results, 'parameterNames_LaTeX') || isempty(app.results.parameterNames_LaTeX)
% %         error('Parameter names are not defined in the app results.');
% %     end
% % 
% %     % Set global formatting options
% %     titleFontSize = 16;
% %     labelFontSize = 16;
% %     tickFontSize = 12;
% % 
% %     % Derived Parameter: params.cytcred
% %     cytctot_samples = app.MCMCResults.samples(:, 2);     % Posterior samples for theta(2)
% %     cytcPrep_samples = app.MCMCResults.samples(:, 11);   % Posterior samples for theta(11)
% %     cytcox_samples = cytctot_samples .* cytcPrep_samples;
% %     cytcred_samples = app.params.cytctot - cytcox_samples;
% % 
% %     % Replace parameter 11 with params.cytcred
% %     app.MCMCResults.samples(:, 11) = cytcred_samples;
% % 
% %     % Update parameter name in LaTeX
% %     app.results.parameterNames_LaTeX{11} = '$r(0)$';
% % 
% %    % Reordering of parameters based on the table in the paper
% %    SMPLS = zeros(size(app.MCMCResults.samples));
% %    SMPLS(:,1) = app.MCMCResults.samples(:, 1); 
% %    SMPLS(:,2) = app.MCMCResults.samples(:, 3);
% %    SMPLS(:,3) = app.MCMCResults.samples(:, 4);
% %    SMPLS(:,4) = app.MCMCResults.samples(:, 5);
% %    SMPLS(:,5) = app.MCMCResults.samples(:, 6);
% %    SMPLS(:,6) = app.MCMCResults.samples(:, 7);
% %    SMPLS(:,7) = app.MCMCResults.samples(:, 9);
% %    SMPLS(:,8) = app.MCMCResults.samples(:, 8);
% %    SMPLS(:,9) = app.MCMCResults.samples(:, 11);
% %    SMPLS(:,10) = app.MCMCResults.samples(:, 2);
% %    SMPLS(:,11) = app.MCMCResults.samples(:, 10);
% % 
% % 
% % 
% %     % Map parameter names to their labels (LaTeX-style for figures)
% %                 app.results.parameterNames_LaTeX(1:11) = {
% %                 '$V_{max_{c_0}}$', ...
% %                 '$K_{m_{c_0}}$', ...
% %                 '$V_{max_{c_{IV}}}$', ...
% %                 '$K_{m_{c_{IV}}}$', ...
% %                 '$K_{c_{IV}}$', ...
% %                 '$V_{max_{c_V}}$', ...
% %                 '$K_{m_{c_V}}$', ...
% %                 '$K_{c_V}$', ...
% %                 '$r(0)$',...
% %                 '$c_0$', ...
% %                 '$P_{leak}$', ...
% %                                 };
% % 
% %               % Dynamically append alpha parameters if the model type is FullModelGlobal
% %             if strcmp(app.Model.Type, 'FullModelGlobal')
% %                 % Get the number of alphas dynamically
% %                 num_alphas = app.params.alphas.num_alphas;
% % 
% %                 % Generate alpha parameter names
% %                 alphaNamesHTML = arrayfun(@(i) sprintf('<div style="padding: 30px 0;"><i>&#x0251<sub>%d</sub></i></div>', i), 1:num_alphas, 'UniformOutput', false);
% %                 alphaNamesLaTeX = arrayfun(@(i) sprintf('$\\alpha_%d$', i), 1:num_alphas, 'UniformOutput', false);
% % 
% %                 % Add alpha parameter names to the results lists
% %                 app.results.parameterNames = [app.results.parameterNames, alphaNamesHTML];
% %                 app.results.parameterNames_LaTeX = [app.results.parameterNames_LaTeX, alphaNamesLaTeX];
% % 
% %                 % Add the attenuateProp parameter
% %                 app.results.parameterNames{end+1} = '<div style="padding: 30px 0;"><i>r<sub>attenuate</sub></i></div>';
% %                 app.results.parameterNames_LaTeX{end+1} = '$r_{attenuate}$';
% %             end
% % 
% %     %% Trace Plots
% %     figure('Name', 'Trace Plots');
% %     for i = 1:numParams
% %         subplot(ceil(sqrt(numParams)), ceil(sqrt(numParams)), i); % Dynamic layout
% %         plot(SMPLS(:, i), 'LineWidth', 0.6, 'Color', [0 0.5 0.8]);
% %         grid on;
% %         set(gca, 'FontWeight', 'bold', 'FontSize', tickFontSize);
% %         xlabel('Iteration', 'FontSize', labelFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
% %         ylabel(app.results.parameterNames_LaTeX{i}, 'FontSize', labelFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
% %         title(['Trace Plot for ', app.results.parameterNames_LaTeX{i}], ...
% %             'FontSize', titleFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
% %     end
% % 
% %     %% Autocorrelation Plots
% %     figure('Name', 'Autocorrelation');
% %     for i = 1:numParams
% %         subplot(ceil(sqrt(numParams)), ceil(sqrt(numParams)), i);
% %         autocorr(SMPLS(:, i), 'NumLags', 50);
% %         grid on;
% %         xlabel('Lag', 'FontSize', labelFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
% %         ylabel('Autocorrelation', 'FontSize', labelFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
% %         title(['Autocorrelation for ', app.results.parameterNames_LaTeX{i}], ...
% %             'FontSize', titleFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
% %     end
% % 
% %     %% Histograms with KDE and Statistics
% %     figure('Name', 'Histogram with KDE');
% %     for i = 1:numParams
% %         subplot(ceil(sqrt(numParams)), ceil(sqrt(numParams)), i);
% % 
% %         % Histogram
% %         histogram(SMPLS(:, i), 'Normalization', 'pdf', ...
% %             'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'k');
% %         hold on;
% % 
% %         % KDE
% %         [f, xi] = ksdensity(SMPLS(:, i));
% %         plot(xi, f, 'LineWidth', 2.5, 'Color', [0 0.5 0.8]);
% % 
% %         % Annotations: Mean and 95% CI
% %         mean_val = mean(SMPLS(:, i));
% %         ci = quantile(SMPLS(:, i), [0.025, 0.975]);
% %         xline(mean_val, '-.', 'Color', [0.6350 0.0780 0.1840], 'LineWidth', 2.5);
% %         xline(ci(1), '-.', 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 2.5);
% %         xline(ci(2), '-.', 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 2.5);
% % 
% %         legend({'Histogram', 'KDE', 'Mean', '95% CI'}, 'Location', 'best', 'FontSize', 14);
% %         grid on;
% %         set(gca, 'FontWeight', 'bold', 'FontSize', tickFontSize);
% %         xlabel(app.results.parameterNames_LaTeX{i}, 'FontSize', labelFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
% %         ylabel('Density', 'FontSize', labelFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
% %         title(['Density Plot for ', app.results.parameterNames_LaTeX{i}], ...
% %             'FontSize', titleFontSize, 'FontWeight', 'bold', 'Interpreter', 'latex');
% %         hold off;
% %     end
% % 
% %     %% Summary Statistics
% %     disp('Parameter Summary Statistics:');
% %     for i = 1:numParams
% %         mean_val = mean(SMPLS(:, i));
% %         median_val = median(SMPLS(:, i));
% %         ci = quantile(SMPLS(:, i), [0.025, 0.975]);
% %         fprintf('Parameter %s: Mean = %.4f, Median = %.4f, 95%% CI = [%.4f, %.4f]\n', ...
% %             app.results.parameterNames_LaTeX{i}, mean_val, median_val, ci(1), ci(2));
% %     end
% % 
% %     %% Effective Sample Size
% %     ess = zeros(1, numParams);
% %     for i = 1:numParams
% %         ess(i) = effectiveSampleSize(SMPLS(:, i));
% %     end
% %     disp('Effective Sample Sizes:');
% %     disp(array2table(ess, 'VariableNames', app.results.parameterNames_LaTeX));
% % end





% % % function diagnoseMCMC(app, samples)
% % %     numParams = size(app.MCMCResults.samples, 2);
% % % 
% % %     % Ensure parameter names are defined
% % %     if ~isfield(app.results, 'parameterNames_LaTeX') || isempty(app.results.parameterNames_LaTeX)
% % %         error('Parameter names are not defined in the app results.');
% % %     end
% % % 
% % %     % Trace Plots
% % %     figure('Name', 'Trace Plots');
% % %     for i = 1:numParams
% % %         subplot(4, 4, i);
% % %         plot(app.MCMCResults.samples(:, i));
% % %         xlabel('Iteration', 'Interpreter', 'latex');
% % %         ylabel(app.results.parameterNames_LaTeX{i}, 'Interpreter', 'latex');
% % %         title(['Trace Plot for ', app.results.parameterNames_LaTeX{i}], 'Interpreter', 'latex');
% % %     end
% % % 
% % %     % Autocorrelation
% % %     figure('Name', 'Autocorrelation');
% % %     for i = 1:numParams
% % %         subplot(4, 4, i);
% % %         autocorr(app.MCMCResults.samples(:, i), 'NumLags', 50);
% % %         xlabel('Lag', 'Interpreter', 'latex');
% % %         ylabel('Autocorrelation', 'Interpreter', 'latex');
% % %         title(['Autocorrelation for ', app.results.parameterNames_LaTeX{i}], 'Interpreter', 'latex');
% % %     end
% % % 
% % %     % Histogram with KDE
% % %     figure('Name', 'Histogram with KDE');
% % %     for i = 1:numParams
% % %         subplot(4, 4, i);
% % %         histogram(app.MCMCResults.samples(:, i), 'Normalization', 'pdf');
% % %         hold on;
% % %         [f, xi] = ksdensity(app.MCMCResults.samples(:, i));
% % %         plot(xi, f, 'LineWidth', 2);
% % %         xlabel(app.results.parameterNames_LaTeX{i}, 'Interpreter', 'latex');
% % %         ylabel('Density', 'Interpreter', 'latex');
% % %         title(['Density Plot for ', app.results.parameterNames_LaTeX{i}], 'Interpreter', 'latex');
% % %         hold off;
% % %     end
% % % 
% % % 
% % % % % Pairwise Scatter Plots
% % % % figure('Name', 'Pairwise Scatter Plots');
% % % % for i = 1:numParams
% % % %     for j = i+1:numParams
% % % %         subplot(numParams, numParams, (i-1)*numParams + j);
% % % %         scatter(samples(:, i), samples(:, j));
% % % %         xlabel(['Param ' num2str(i)]);
% % % %         ylabel(['Param ' num2str(j)]);
% % % %         title(['Param ' num2str(i) ' vs Param ' num2str(j)]);
% % % %     end
% % % % end
% % % 
% % % % % for ii = 1:numParams
% % % % %     figure;
% % % % %     for j = 1:numParams
% % % % %         subplot(4, 4, j);
% % % % %         scatter(samples(:, ii), samples(:, j));
% % % % %         xlabel(['Param ' num2str(ii)]);
% % % % %         ylabel(['Param ' num2str(j)]);
% % % % %         title(['Pairwise Scatter Plots for Parameter ' num2str(ii) ' vs Param ' num2str(j)]);
% % % % %     end
% % % % % end
% % % 
% % % 
% % % % Display Summary Statistics
% % % disp('Parameter Summary Statistics:');
% % % for i = 1:numParams
% % %     fprintf('Parameter %d: Mean = %.4f, Median = %.4f, 95%% CI = [%.4f, %.4f]\n', ...
% % %         i, app.MCMCResults.meanParams(i), app.MCMCResults.medianParams(i), ...
% % %         app.MCMCResults.confidenceIntervals(i, 1), app.MCMCResults.confidenceIntervals(i, 2));
% % % end
% % % 
% % % 
% % % % Effective Sample Size
% % % ess = zeros(1, numParams);
% % % for i = 1:numParams
% % %     ess(i) = effectiveSampleSize(app.MCMCResults.samples(:, i));
% % % end
% % % disp('Effective Sample Sizes:');
% % % disp(ess);
% % % 
% % % theta2_samples = app.MCMCResults.samples(:, 2);     % Posterior samples for theta(2)
% % % theta11_samples = app.MCMCResults.samples(:, 11);   % Posterior samples for theta(11)
% % % 
% % % % Compute params.cytcred samples
% % % params_cytcred_samples = theta2_samples .* (1 - theta11_samples);
% % % 
% % % % Calculate mean, median, and 95% CI for params.cytcred
% % % mean_cytcred = mean(params_cytcred_samples);
% % % median_cytcred = median(params_cytcred_samples);
% % % CI_cytcred = quantile(params_cytcred_samples, [0.025, 0.975]);
% % % 
% % % % Display results
% % % fprintf('Mean of params.cytcred: %.4f\n', mean_cytcred);
% % % fprintf('Median of params.cytcred: %.4f\n', median_cytcred);
% % % fprintf('95%% CI of params.cytcred: [%.4f, %.4f]\n', CI_cytcred(1), CI_cytcred(2));
% % % 
% % % end
