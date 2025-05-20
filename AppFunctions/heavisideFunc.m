function H = heavisideFunc(x)
% HEAVISIDEFUNCTION Calculate the Heaviside step function
% H = heavisideFunction(x) returns the value of the Heaviside function at x
% Preallocate the output array
H = zeros(size(x));
% Apply the conditions
H(x > 0) = 1;
H(x == 0) = 1;
H(x < 0) = 0;

% % % % Define epsilon
% % % epsilon = 0.5;
% % % 
% % % % Sigmoid function approximation
% % % H = 0.5 * (1 + tanh(x / epsilon));

end





% % Define x range
% x = linspace(-5, 5, 100);
% 
% % Define epsilon
% epsilon = 0.5;
% 
% % Sigmoid function approximation
% H_sigmoid = 0.5 * (1 + tanh(x / epsilon));
% 
% % Error function approximation
% H_erf = 0.5 * (1 + erf(x / epsilon));
% 
% % Logistic function approximation
% H_logistic = 1 ./ (1 + exp(-x / epsilon));
% 
% % Smoothstep function approximation (normalized to range 0 to 1)
% H_smoothstep = 0.5 * (3 * (x / epsilon).^2 - 2 * (x / epsilon).^3) .* (x > 0 & x < epsilon) + (x >= epsilon);
% 
% % Plot the approximations
% figure;
% plot(x, H_sigmoid, 'r', 'LineWidth', 2); hold on;
% plot(x, H_erf, 'g', 'LineWidth', 2);
% plot(x, H_logistic, 'b', 'LineWidth', 2);
% plot(x, H_smoothstep, 'k', 'LineWidth', 2);
% legend('Sigmoid', 'Error Function', 'Logistic', 'Smoothstep');
% title('Smooth Approximations of Heaviside Function');
% xlabel('x');
% ylabel('H_{approx}(x)');
% grid on;
