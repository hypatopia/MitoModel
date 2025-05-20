% First stop at case 'Raw Data' in function VisualizationDropDown(app, event)

% Assuming t, Real_O2, and Real_OCR are already defined
Real_OCR = [0; Real_OCR];
t_first = t(1);
t = (t - t_first)/60;
figure; % Create a new figure

% Plot Real_O2 vs t on the left y-axis
yyaxis left
dark_brown = [0.4, 0.2, 0.1];  % Dark brown color
plot(t, Real_O2, 'Color', dark_brown, 'LineWidth', 3); % Dark brown solid line
ylabel('Real O_2 (nmol/mL)', 'Color', dark_brown, 'FontWeight', 'bold', 'FontSize', 24);  % Bold label with font size 24
xlabel('Time (min)', 'FontWeight', 'bold', 'FontSize', 24);  % Bold label with font size 24
title('Oxygen concentration and OCR measured by Oroboros Oxygraph-2k', 'FontSize', 18); % Title with font size 22
grid on;

% Set tick color for left axis (Real_O2)
ax = gca; % Get current axes
ax.YColor = dark_brown; % Set the color of the left axis ticks to dark brown
ax.YAxis(1).TickLength = [0.02 0.025]; % Optional: Adjust tick length for better visibility

% Plot Real_OCR vs t on the right y-axis
yyaxis right
plot(t, Real_OCR, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 3);  % Red solid line
ylabel('Real OCR (pmol/(mL*sec))', 'FontWeight', 'bold', 'FontSize', 24);  % Bold label with font size 24
legend('Real O_2', 'Real OCR', 'FontWeight', 'bold', 'FontSize', 24);  % Bold legend text with font size 24

% Set font for the axes numbers to bold and font size to 24
ax.FontWeight = 'bold'; % Make axis numbers bold
ax.FontSize = 24; % Set font size of the numbers on the axes

% Set x-axis limits to go a bit beyond the last value of t
xlim([t(1), t(end)]); % Extend by 5% of the total range

% Add vertical lines for injection times
if ~isempty(app.data.Injection_Times) && ~isempty(app.data.Injection_Types)
    t_grid = (app.data.Injection_Times - t_first)/60;
    for i = 1:length(t_grid)
        xlineHandle = xline(ax, t_grid(i), '--', app.data.Injection_Types{i}, ...
                            'color', [.4, .4, .4], 'LineWidth', 2, 'LabelVerticalAlignment', 'bottom');
        xlineHandle.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
end