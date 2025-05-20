% First stop at case 'Optimized Model' in function VisualizationDropDown(app, event)


figure; % Create a new figure
t_first = t(1);
t = (t - t_first) / 60;
% plot(t(2:end), calcOCR(2:end), 'Color', [0.4660, 0.6740, 0.1880], 'LineWidth', 3, 'LineStyle', '-');

plot(t(2:end), calcOCR(2:end), 'Color', [0, 0.4470, 0.7410], 'LineWidth', 3, 'LineStyle', '-'); % Blue solid line
ylabel('OCR (nmol/mL)', 'FontWeight', 'bold', 'FontSize', 24);  % Bold label with font size 16
xlabel('Time (min)', 'FontWeight', 'bold', 'FontSize', 24);  % Bold label with font size 16
title('Full Model Predction for the OCR', 'FontSize', 24); % Title with font size 16
hold on;
plot(t(2:end), Real_OCR, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 3, 'LineStyle', '-'); % Blue solid line
legend('Model Output', 'Calculated OCR', 'FontWeight', 'bold', 'FontSize', 24);  % Bold legend text with font size 16

% Set the font for the axes numbers to bold and font size to 16
ax = gca; % Get current axes
ax.FontWeight = 'bold'; % Make axis numbers bold
ax.FontSize = 18; % Set font size of the numbers on the axes

% Set x-axis limits to go a bit beyond the last value of t
xlim([t(1) , t(end)]); % Extend by 5% of the total range
app.data.Injection_Times = (app.data.Injection_Times - t_first) / 60;
% Add vertical lines for injection times
if ~isempty(app.data.Injection_Times) && ~isempty(app.data.Injection_Types)
    for i = 1:length(app.data.Injection_Times)
        xlineHandle = xline(ax, app.data.Injection_Times(i), '--', app.data.Injection_Types{i}, ...
                            'color', [.4, .4, .4], 'LineWidth', 2, 'LabelVerticalAlignment', 'bottom');
        xlineHandle.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
end




% % % First stop at case 'Optimized Model' in function VisualizationDropDown(app, event)
% % 
% % 
% % figure; % Create a new figure
% % t_Baseline = (app.data.baseline_times(2:end) - app.data.baseline_times(2))/60;
% % calcOCR_Baseline = calcOCR(2:numel(app.data.baseline_times));
% % Real_OCR_Baseline = Real_OCR(2:numel(app.data.baseline_times));
% % % Plot Real_O2 vs t on the left y-axis
% % % plot(t_Baseline, calcOCR_Baseline, 'Color', [0.4660, 0.6740, 0.1880], 'LineWidth', 3, 'LineStyle', '-');
% % 
% % plot(t_Baseline, calcOCR_Baseline, 'Color', [0, 0.4470, 0.7410], 'LineWidth', 3, 'LineStyle', '-'); % Blue solid line
% % ylabel('Simulated OCR (nmol/mL)', 'FontWeight', 'bold', 'FontSize', 24);  % Bold label with font size 16
% % xlabel('Time (min)', 'FontWeight', 'bold', 'FontSize', 24);  % Bold label with font size 16
% % title('Simulation of the OCR using the Baseline Model', 'FontSize', 24); % Title with font size 16
% % hold on;
% % plot(t_Baseline, Real_OCR_Baseline, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 3, 'LineStyle', '-'); % Blue solid line
% % legend('Model Output', 'Calculated OCR', 'FontWeight', 'bold', 'FontSize', 24);  % Bold legend text with font size 16
% % 
% % % Set the font for the axes numbers to bold and font size to 16
% % ax = gca; % Get current axes
% % ax.FontWeight = 'bold'; % Make axis numbers bold
% % ax.FontSize = 18; % Set font size of the numbers on the axes
% % 
% % % Set x-axis limits to go a bit beyond the last value of t
% % xlim([t_Baseline(1) t_Baseline(end)]); % Extend by 5% of the total range
% % 
% % % Add vertical lines for injection times
% % if ~isempty(app.data.Injection_Times) && ~isempty(app.data.Injection_Types)
% %     for i = 1:length(app.data.Injection_Times)
% %         xlineHandle = xline(ax, app.data.Injection_Times(i), '--', app.data.Injection_Types{i}, ...
% %                             'color', [.4, .4, .4], 'LineWidth', 2, 'LabelVerticalAlignment', 'bottom');
% %         xlineHandle.Annotation.LegendInformation.IconDisplayStyle = 'off';
% %     end
% % end
