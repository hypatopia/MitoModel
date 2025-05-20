function setupGA(app)
% Add the Optimization Toolbox if not already added
if ~license('test', 'Optimization_Toolbox')
    waitfor(msgbox('Optimization Toolbox is required for using GA.'));
    return
% else
%     msgbox('Optimization Toolbox for using GA loaded');

end
end