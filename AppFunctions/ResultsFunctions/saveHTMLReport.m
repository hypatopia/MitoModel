function saveHTMLReport(app, folderName)

% Define the current time and date for file naming
curr_time = datestr(now, 'HH_MM_SS');
curr_date = datestr(now, 'yyyy-mm-dd');
COMPUTERNAME = getenv('COMPUTERNAME');
htmlFileName = sprintf('Results_%s_%s_%s.html', curr_date, curr_time, COMPUTERNAME);

% Create the folder if it does not exist
if ~exist(folderName, 'dir')
    mkdir(folderName);
end

% Full path for the HTML file
fullFileName = fullfile(folderName, htmlFileName);

% Open the HTML file
fileID = fopen(fullFileName, 'w');

% Write the header and title to the HTML file
fprintf(fileID, '<html><head><title>Model Optimization Results</title></head><body>\n');
fprintf(fileID, '<h1>Model Optimization Results</h1>\n');

% Add optimized parameters
fprintf(fileID, '<h2>Optimized Parameters:</h2>\n');
fprintf(fileID, '<table border="1"><tr><th>Parameter</th><th>Optimized Value</th></tr>\n');
for i = 1:size(app.ResultsTable.Data, 1)
    fprintf(fileID, '<tr><td>%s</td><td>%s</td></tr>\n', ...
        app.ResultsTable.Data{i, 1}, num2str(app.ResultsTable.Data{i, 2}));
end
fprintf(fileID, '</table>\n');

% Add MCMC results if the appropriate columns are present
if size(app.ResultsTable.Data, 2) >= 4
    fprintf(fileID, '<h2>MCMC Analysis Results:</h2>\n');
    fprintf(fileID, '<table border="1"><tr><th>Parameter</th><th>Optimized Value</th><th>Mean Value</th><th>Confidence Interval (CI)</th></tr>\n');
    for i = 1:size(app.ResultsTable.Data, 1)
        fprintf(fileID, '<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n', ...
            app.ResultsTable.Data{i, 1}, num2str(app.ResultsTable.Data{i, 2}), ...
            num2str(app.ResultsTable.Data{i, 3}), num2str(app.ResultsTable.Data{i, 4}));
    end
    fprintf(fileID, '</table>\n');
end


% Add bootstrap confidence intervals if available
if size(app.ResultsTable.Data, 2) == 5
    fprintf(fileID, '<h2>Bootstrap Confidence Intervals:</h2>\n');
    fprintf(fileID, '<table border="1"><tr><th>Parameter</th><th>Optimized Value</th><th>Mean Value</th><th>Confidence Interval (CI)</th><th>CI by Bootstrap Samples</th></tr>\n');
    for i = 1:size(app.ResultsTable.Data, 1)
        fprintf(fileID, '<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n', ...
            app.ResultsTable.Data{i, 1}, num2str(app.ResultsTable.Data{i, 2}), ...
            num2str(app.ResultsTable.Data{i, 3}), app.ResultsTable.Data{i, 4}, ...
            app.ResultsTable.Data{i, 5});
    end
    fprintf(fileID, '</table>\n');
end


% Add GA information
if ~isempty(app.GAInfoTable.Data)
    fprintf(fileID, '<h2>Genetic Algorithm (GA) Information:</h2>\n');
    fprintf(fileID, '<table border="1"><tr><th>Generation</th><th>Best Score</th></tr>\n');
    for i = 1:size(app.GAInfoTable.Data, 1)
        fprintf(fileID, '<tr><td>%s</td><td>%s</td></tr>\n', ...
            num2str(app.GAInfoTable.Data{i, 1}), num2str(app.GAInfoTable.Data{i, 2}));
    end
    fprintf(fileID, '</table>\n');
end


% Define the path for saving the figures
resultsFolder = 'Results';
figuresFolder = fullfile(resultsFolder, 'Figures');

% Create the Results and Figures folders if they don't exist
if ~exist(resultsFolder, 'dir')
    mkdir(resultsFolder);
end
if ~exist(figuresFolder, 'dir')
    mkdir(figuresFolder);
end

parameterNames =   app.results.parameterNames;
numParams = numel(parameterNames);
samples = app.MCMCResults.samples;
logP = app.MCMCResults.logP; % Access logP values
logLikelihood = logP(:, 2); % Extract the log-likelihood values

% Add correlation matrix
fprintf(fileID, '<h2>Correlation Matrix:</h2>\n');
fprintf(fileID, '<table border="1">\n');

% Print header row with parameter names
fprintf(fileID, '<tr><th>Parameter</th>'); % Top-left cell with "Parameter"
for i = 1: numParams
    fprintf(fileID, '<th>%s</th>', parameterNames{i});
end
fprintf(fileID, '</tr>\n');

% Print each row of the correlation matrix
for i = 1: numParams
    fprintf(fileID, '<tr><th>%s</th>', parameterNames{i}); % Row header
    for j = 1: numParams
        fprintf(fileID, '<td>%s</td>', num2str(app.CorrMatrixTable.Data{i+1, j+1}, '%.4f'));
    end
    fprintf(fileID, '</tr>\n');
end

fprintf(fileID, '</table>\n');


% Find the indices of the selected parameters
paramIndices = [];

for i = 1:numParams
    if ismember(app.results.parameterNames_LaTeX{i}, app.SelectedParameters)
        paramIndices = [paramIndices, i];
    end
end


% Create and save the dynamic subplots figure
dynamicFig = figure('Visible', 'off', 'Position', [100, 100, 1200, 1000]); 
numRows = size(app.DynamicAxes, 1);
numCols = size(app.DynamicAxes, 2);

% Define subplot parameters with spacing between them
axWidth = 0.9 / numCols; % Adjust width to leave space between subplots
axHeight = 0.85 / numRows; % Adjust height to leave space between subplots
verticalSpacing = 0.043; % Adjust this value to increase space between rows
horizontalSpacing = 0.05; % Optional: Adjust horizontal space as well if needed
tabHeight = numRows * (axHeight + verticalSpacing)+0.03;

parameterNames = app.results.parameterNames_LaTeX;

for i = 1:numRows
    for j = 1:numCols
        if i >= j
            % Calculate position for each subplot with additional spacing
            axPosition = [(j-1) * axWidth + horizontalSpacing, ...
                tabHeight - i * (axHeight + verticalSpacing-0.008), ... % Adjust for vertical spacing
                axWidth - horizontalSpacing, ...
                axHeight - verticalSpacing];
            ax = axes('Parent', dynamicFig, 'Position', axPosition); % Create axes on the new figure

            % Plot data on the axes
            if i == j
                % Diagonal axes for histograms
                histogram(ax, samples(:, paramIndices(i)), 'FaceColor', [0 0.4470 0.7410], 'EdgeColor', 'k', 'FaceAlpha', 0.7, 'LineWidth', 0.8);
                xlabel(ax, parameterNames{paramIndices(i)}, 'Interpreter', 'latex', 'FontSize', 12, 'FontWeight', 'bold');
                ylabel(ax, 'Frequency', 'FontSize', 12, 'FontWeight', 'bold');
                title(ax, sprintf('Histogram of %s', parameterNames{paramIndices(i)}), 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
            elseif i > j
                % Lower triangular part for scatter plots with log-likelihood as color
                scatter(ax, samples(:, paramIndices(j)), samples(:, paramIndices(i)), 50, logLikelihood, 'filled');
                xlabel(ax, parameterNames{paramIndices(j)}, 'Interpreter', 'latex', 'FontSize', 12, 'FontWeight', 'bold');
                ylabel(ax, parameterNames{paramIndices(i)}, 'Interpreter', 'latex', 'FontSize', 12, 'FontWeight', 'bold');
                title(ax, sprintf('Scatter of %s vs %s', parameterNames{paramIndices(j)}, parameterNames{paramIndices(i)}), 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
                % Add colorbar to indicate log-likelihood values
                cb = colorbar(ax);
                cb.Label.String = 'Log-Likelihood';
            end

            % Customize axis appearance
            ax.XTick = linspace(min(samples(:, paramIndices(j))), max(samples(:, paramIndices(j))), 5);
            % ax.YTick = linspace(min(samples(:, paramIndices(i))), max(samples(:, paramIndices(i))), 5);
            grid(ax, 'on');
        end
    end
end

% Create an array to store the figure file names
numRows = size(app.DynamicAxes, 1);
numCols = size(app.DynamicAxes, 2);

% % Include dynamic subplots figures
% fprintf(fileID, '<h2>Dynamic Subplots:</h2>\n');
% for i = 1:numRows
%     for j = 1:numCols
%         % Create the filename for each subplot
%         figFileName = sprintf('Plot_%d_%d.png', i, j);
%         figFullPath = fullfile(figuresFolder, figFileName);
%         fprintf(fileID, '<h3>Plot %d, %d:</h3>\n', i, j);
%         fprintf(fileID, '<img src="%s" alt="Plot %d, %d">\n', fullfile('Figures', figFileName), i, j);
%     end
% end


% Save the dynamic subplots figure
dynamicFigureFileName = fullfile(figuresFolder, 'DynamicSubplots.png');
saveas(dynamicFig, dynamicFigureFileName);
close(dynamicFig);

% Include the dynamic subplots figure in the HTML report
fprintf(fileID, '<h2>Dynamic Subplots:</h2>\n');
fprintf(fileID, '<img src="%s" alt="Dynamic Subplots">\n', fullfile('Figures', 'DynamicSubplots.png'));


% Include heatmap image in the report
heatmapFileName = fullfile(figuresFolder, 'heatmap.png');
fprintf(fileID, '<h2>Heatmap:</h2>\n');
fprintf(fileID, '<img src="%s" alt="Heatmap" style="max-width:100%%;height:auto;">\n', fullfile('Figures', 'heatmap.png'));

% Close the HTML file
fprintf(fileID, '</body></html>\n');
fclose(fileID);

% Notify the user
msgbox(sprintf('HTML report has been created: %s', fullFileName), 'HTML Generated');

end
