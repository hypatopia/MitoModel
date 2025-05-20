function updatedStep = adaptStepFunction(theta, baseStepFunction, logmodelprior, currentStepSize, targetAcceptanceRate, adaptationRate)
    % Adaptive step size function for MCMC
    persistent acceptCount totalCount stepSize

    % Initialize persistent counters and step size
    if isempty(acceptCount) || isempty(totalCount) || isempty(stepSize)
        acceptCount = 0;
        totalCount = 0;
        stepSize = currentStepSize;
    end

    % Generate candidate step
    candidate = theta + baseStepFunction(theta) * stepSize;

    % Update acceptance metrics
    totalCount = totalCount + 1;
    if log(rand) < logmodelprior(candidate) - logmodelprior(theta)
        acceptCount = acceptCount + 1;
    end

    % Adapt step size based on acceptance rate
    if totalCount >= 100 % Adjust step size every 100 iterations
        currentAcceptanceRate = acceptCount / totalCount;
        stepSize = stepSize * exp(adaptationRate * (currentAcceptanceRate - targetAcceptanceRate));
        acceptCount = 0; % Reset counters after adaptation
        totalCount = 0;
    end

    % Constrain step size to avoid extreme values
    stepSize = max(min(stepSize, 10), 1e-5);

    % Return updated step
    updatedStep = candidate;
end
