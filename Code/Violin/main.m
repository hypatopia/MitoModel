% Assume 'data' is a matrix where rows = runs, columns = parameters
[numRuns, numParams] = size(data);


    % Define parameter names in LaTeX
    paramNames = {...
        '$V_{max_{c_0}}$', ...
        '$Cyt c_{tot}$', ...
        '$K_{m_{c_0}}$', ...
        '$V_{max_{c_{IV}}}$', ...
        '$K_{m_{c_{IV}}}$', ...
        '$K_{c_{IV}}$', ...
        '$V_{max_{c_V}}$', ...
        '$K_{c_V}$', ...
        '$K_{m_{c_V}}$', ...
        '$P_{leak}$', ...
        '$Cyt c_{red_{Prop}}$',...
        '$\alpha_1$',...
        '$\alpha_2$',...
        '$\alpha_3$',...
        '$\alpha_4$',...
        '$r_{attenuate}$'
        };

    % Loop through each parameter to create separate violin plots
    for paramIdx = 1:numParams
        % Extract data for the current parameter as a column vector
        paramData = data(:, paramIdx);

        % Ensure there are at least two unique values for plotting
        if numel(unique(paramData)) < 2
            fprintf('Skipping Parameter %d: Not enough unique values for a violin plot.\n', paramIdx);
            continue;
        end

        % Create a new figure for the parameter
        figure;
        % Create the violin plot
        violinplot(paramData, {' '}, ...
            'ViolinAlpha', 0.4, ...              % Set transparency for violins
            'EdgeColor', [0.1, 0.1, 0.1], ...    % Outline color of violin area
            'BoxColor', [0.3, 0.3, 0.3], ...     % Color of box and whiskers
            'MedianColor', [1, 1, 1], ...        % Color for median marker
            'ShowData', true, ...                % Show data points
            'ShowNotches', true, ...             % Show notch indicators for medians
            'ShowMean', true, ...                % Show mean indicator
            'ShowBox', true, ...                 % Show box plot elements
            'ShowMedian', true, ...              % Show median marker
            'ShowWhiskers', true);

 % Hold the current figure to overlay scatter points
    hold on;

    % Scatter plot with colors mapped to 'Errors'
    scatter(repmat(1, numRuns, 1), paramData, 50, Error, 'filled', 'MarkerEdgeColor', 'k');

    % Add a color bar
    colormap(jet); % Use 'jet' colormap or choose your preferred colormap
    c = colorbar;
    c.Label.String = 'Error';
    c.Label.FontSize = 12;
    c.Label.FontWeight = 'bold';
    c.Label.Interpreter = 'latex';

    % Customize the figure
    title(sprintf('Violin Plot for %s', paramNames{paramIdx}), 'Interpreter', 'latex', ...
        'FontSize', 14, 'FontWeight', 'bold');
    ylabel('Value', 'Interpreter', 'latex', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel(paramNames{paramIdx}, 'Interpreter', 'latex', 'FontSize', 12, 'FontWeight', 'bold');

    % Enhance plot appearance
    set(gca, 'FontWeight', 'bold', 'FontSize', 12);
    hold off;
end

