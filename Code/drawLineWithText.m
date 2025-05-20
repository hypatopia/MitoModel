function drawLineWithText(panel, time, ylim, text)
    line(panel, [time, time], ylim, 'Color', 'b');
    text(panel, time, ylim(2) * 0.98, text, 'FontSize', 6, 'HorizontalAlignment', 'center', 'Color', 'b');
end