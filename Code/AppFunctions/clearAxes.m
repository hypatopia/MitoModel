function clearAxes(ax)
    if isvalid(ax)
        % Clear the specified axes
        cla(ax);
        legend(ax, 'off');
        xlim(ax, 'auto');
        ylim(ax, 'auto');
        set(ax, 'XScale', 'linear', 'YScale', 'linear');
    end
end
