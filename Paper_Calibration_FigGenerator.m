% Model Validation
% First stop at case 'Optimized Model' in function VisualizationDropDown(app, event)

% figure; % Create a new figure
 t_Baseline = (app.data.baseline_times - app.data.baseline_times(1))/60;
 Real_O2_BS = Real_O2(1:numel(t_Baseline));
 o2_BS = o2(1:numel(t_Baseline));
 t_first = app.data.baseline_times(1);
figure(1)
hold on
% t_first = t(1);
%  t_full  = (t - t_first) / 60;

% legend('Experimental Data - Chamber A', 'Experimental Data - Chamber B', 'Model Output', 'In Silico Prediction', 'FontWeight', 'bold', 'FontSize', 24);

% Plot Real_O2 vs t on the left y-axis
plot(t_Baseline , Real_O2_BS, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 3, 'LineStyle', '-'); % Blue solid line
ylabel('O_2 (nmol/mL)', 'FontWeight', 'bold', 'FontSize', 24);  % Bold label with font size 18
xlabel('Time (min)', 'FontWeight', 'bold', 'FontSize', 24);  % Bold label with font size 18
title('Baseline Model Validation Versus Experimental Oxygen concentration', 'FontSize', 22); % Title with font size 18
hold on;
plot(t_Baseline , o2_BS, 'Color', [0.4660, 0.6740, 0.1880], 'LineWidth', 3);  % Red solid line

legend('Experimental Data - Chamber B', 'In Silico Prediction', 'FontWeight', 'bold', 'FontSize', 24);  % Bold legend text with font size 18

% Set the font and line properties for the axes
ax = gca; % Get current axes
ax.FontWeight = 'bold'; % Make axis numbers bold
ax.FontSize = 24; % Set font size of the numbers on the axes
ax.LineWidth = 2; % Set line width of axes to make ticks bold

% Set x-axis limits to go a bit beyond the last value of t
xlim([t_full(1) t_full(end)]); % Extend by 5% of the total range
app.data.Injection_Times = (app.data.Injection_Times - t_first) / 60;

% Add vertical lines for injection times
if ~isempty(app.data.Injection_Times) && ~isempty(app.data.Injection_Types)
    for i = 1:length(app.data.Injection_Times)
        xlineHandle = xline(ax, app.data.Injection_Times(i), '--', app.data.Injection_Types{i}, ...
                            'color', [.4, .4, .4], 'LineWidth', 2, 'LabelVerticalAlignment', 'bottom');
        xlineHandle.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
end



% % % % First stop at case 'Optimized Model' in function VisualizationDropDown(app, event)
% % % 
% % % 
% % % figure; % Create a new figure
% % % t_first = t(1);
% % % t = (t - t_first) / 60;
% % % O2 = o2(1:numel(t));
% % % 
% % % % Plot Real_O2 vs t on the left y-axis
% % % plot(t, Real_O2, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 3, 'LineStyle', '--'); % Blue solid line
% % % ylabel('O_2 (nmol/mL)', 'FontWeight', 'bold', 'FontSize', 24);  % Bold label with font size 18
% % % xlabel('Time (min)', 'FontWeight', 'bold', 'FontSize', 24);  % Bold label with font size 18
% % % title('Full Model Calibration to Experimental Oxygen concentration', 'FontSize', 24); % Title with font size 18
% % % hold on;
% % % plot(t, O2, 'Color', [0 0.4470 0.7410], 'LineWidth', 3);  % Red solid line
% % % legend('Experimental Data', 'Model Output', 'FontWeight', 'bold', 'FontSize', 24);  % Bold legend text with font size 18
% % % 
% % % % Set the font and line properties for the axes
% % % ax = gca; % Get current axes
% % % ax.FontWeight = 'bold'; % Make axis numbers bold
% % % ax.FontSize = 24; % Set font size of the numbers on the axes
% % % ax.LineWidth = 2; % Set line width of axes to make ticks bold
% % % 
% % % % Set x-axis limits to go a bit beyond the last value of t
% % % xlim([t(1) t(end)]); % Extend by 5% of the total range
% % % app.data.Injection_Times = (app.data.Injection_Times - t_first) / 60;
% % % 
% % % % Add vertical lines for injection times
% % % if ~isempty(app.data.Injection_Times) && ~isempty(app.data.Injection_Types)
% % %     for i = 1:length(app.data.Injection_Times)
% % %         xlineHandle = xline(ax, app.data.Injection_Times(i), '--', app.data.Injection_Types{i}, ...
% % %                             'color', [.4, .4, .4], 'LineWidth', 2, 'LabelVerticalAlignment', 'bottom');
% % %         xlineHandle.Annotation.LegendInformation.IconDisplayStyle = 'off';
% % %     end
% % % end


% % % % % 
% % % % % % First stop at case 'Optimized Model' in function VisualizationDropDown(app, event)
% % % % % 
% % % % % 
% % % % % figure; % Create a new figure
% % % % % t = (app.data.baseline_times - app.data.baseline_times(1))/60;
% % % % % Real_O2_Baseline = Real_O2(1:numel(t));
% % % % % O2_Baseline = app.results.O2(1:numel(t));
% % % % % % Plot Real_O2 vs t on the left y-axis
% % % % % 
% % % % % plot(t, Real_O2_Baseline, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 3, 'LineStyle', '--'); % Blue solid line
% % % % % ylabel('Real O_2 (nmol/mL)', 'FontWeight', 'bold', 'FontSize', 24);  % Bold label with font size 16
% % % % % xlabel('Time (min)', 'FontWeight', 'bold', 'FontSize', 24);  % Bold label with font size 16
% % % % % title('Baseline Model Calibration to Experimental Oxygen concentration', 'FontSize', 24); % Title with font size 16
% % % % % hold on;
% % % % % plot(t, O2_Baseline, 'Color', [0 0.4470 0.7410], 'LineWidth', 3);  % Red solid line
% % % % % legend('Experimental Data', 'Model Output', 'FontWeight', 'bold', 'FontSize', 24);  % Bold legend text with font size 16
% % % % % 
% % % % % % Set the font for the axes numbers to bold and font size to 16
% % % % % ax = gca; % Get current axes
% % % % % ax.FontWeight = 'bold'; % Make axis numbers bold
% % % % % ax.FontSize = 18; % Set font size of the numbers on the axes
% % % % % 
% % % % % % Set x-axis limits to go a bit beyond the last value of t
% % % % % xlim([t(1) t(end)]); % Extend by 5% of the total range
% % % % % 
% % % % % % Add vertical lines for injection times
% % % % % if ~isempty(app.data.Injection_Times) && ~isempty(app.data.Injection_Types)
% % % % %     for i = 1:length(app.data.Injection_Times)
% % % % %         xlineHandle = xline(ax, app.data.Injection_Times(i), '--', app.data.Injection_Types{i}, ...
% % % % %                             'color', [.4, .4, .4], 'LineWidth', 2, 'LabelVerticalAlignment', 'bottom');
% % % % %         xlineHandle.Annotation.LegendInformation.IconDisplayStyle = 'off';
% % % % %     end
% % % % % end






% % % % First stop at case 'Optimized Model' in function VisualizationDropDown(app, event)
% % % 
% % % 
% % % figure; % Create a new figure
% % % t = (app.data.baseline_times - app.data.baseline_times(1))/60;
% % % Real_O2_Baseline = Real_O2(1:numel(t));
% % % O2_Baseline = app.results.O2(1:numel(t));
% % % % Plot Real_O2 vs t on the left y-axis
% % % 
% % % plot(t, Real_O2_Baseline, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 3, 'LineStyle', '--'); % Blue solid line
% % % ylabel('Real O_2 (nmol/mL)', 'FontWeight', 'bold', 'FontSize', 18);  % Bold label with font size 16
% % % xlabel('Time (min)', 'FontWeight', 'bold', 'FontSize', 18);  % Bold label with font size 16
% % % title('Baseline Model Calibration to Experimental Oxygen concentration', 'FontSize', 18); % Title with font size 16
% % % hold on;
% % % plot(t, O2_Baseline, 'Color', [0 0.4470 0.7410], 'LineWidth', 3);  % Red solid line
% % % legend('Experimental Data', 'Model Output', 'FontWeight', 'bold', 'FontSize', 18);  % Bold legend text with font size 16
% % % 
% % % % Set the font for the axes numbers to bold and font size to 16
% % % ax = gca; % Get current axes
% % % ax.FontWeight = 'bold'; % Make axis numbers bold
% % % ax.FontSize = 18; % Set font size of the numbers on the axes
% % % 
% % % % Set x-axis limits to go a bit beyond the last value of t
% % % xlim([t(1) t(end)]); % Extend by 5% of the total range
% % % 
% % % % Add vertical lines for injection times
% % % if ~isempty(app.data.Injection_Times) && ~isempty(app.data.Injection_Types)
% % %     for i = 1:length(app.data.Injection_Times)
% % %         xlineHandle = xline(ax, app.data.Injection_Times(i), '--', app.data.Injection_Types{i}, ...
% % %                             'color', [.4, .4, .4], 'LineWidth', 2, 'LabelVerticalAlignment', 'bottom');
% % %         xlineHandle.Annotation.LegendInformation.IconDisplayStyle = 'off';
% % %     end
% % % end
