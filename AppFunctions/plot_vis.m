function plot_vis(ax, t, y_vec, Injection_Times, Injection_Types, lineWidth, r1, g1, b1, r2, g2, b2, lineStyle, varargin)
% Create by: Marzieh Eini Keleshteri - May 2024

% Plot data on the specified axes and return the handle
hold(ax, 'on');

y = y_vec(:, 1);
[m, n] = size(y_vec);

% Plot y
h1 = plot(ax, t, y, 'color', [r1, g1, b1], 'LineWidth', lineWidth, 'DisplayName', varargin{1});
if n == 2
    y_real = y_vec(:, 2);
    h2 = plot(ax, t, y_real,'LineWidth', lineWidth, 'DisplayName', varargin{2});
end


% Validate and set y-limits
y_limits = get(ax, 'YLim'); % Get current y-limits
if numel(y_limits) == 2 && y_limits(1) < y_limits(2)
    ylim(ax, y_limits); % Apply y-limits
else
    % If y_limits are not valid, set default limits based on data
    y_min = min(y(:));
    y_max = max(y(:));
    if y_min == y_max
        y_min = y_min - 1; % Avoid zero range error
        y_max = y_max + 1;
    end
    ylim(ax, [y_min, y_max]); 
    xlim(ax, [t(1), t(end)]); 
end

% Set the legend only for the plot objects
if n == 2
    legend(ax, [h1, h2], 'Location', 'best');
else
    legend(ax, h1, 'Location', 'best');
end

% Add vertical lines for injection times if provided
if ~isempty(Injection_Times) && ~isempty(Injection_Types)
    for i = 1:length(Injection_Times)
        xlineHandle = xline(ax, Injection_Times(i), lineStyle, Injection_Types{i}, 'color', [r2 g2 b2], 'LabelVerticalAlignment', 'bottom');
        xlineHandle.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
end

hold(ax, 'off');
end
