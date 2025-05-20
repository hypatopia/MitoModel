function colormap = createCustomColormap()
% Define custom colors for the gradient
darkBlue = [0, 0, 0.5];  % Dark blue
lightBlue = [0.5, 0.5, 1];  % Light blue
white = [1, 1, 1];  % White
lightRed = [1, 0.7, 0.7];  % Light red
darkRed = [0.5, 0, 0];  % Dark red

% Interpolate between the colors to create a smooth gradient
customColormap = [darkBlue; lightBlue; white; lightRed; darkRed];
nColors = 1024; % Number of colors for smooth gradient
colormap = interp1([1, nColors/4, nColors/2, 3*nColors/4, nColors], customColormap, linspace(1, nColors, nColors));

end