function [models, logP, acceptanceRate, overallAcceptanceRate, avgLogPrior, avgLogLikelihood, reject] = mcmc(m, loglikelihood, logmodelprior, stepfunction, mccount, skip)
    % Initialization
    m = m(:)';
    M = length(m);
    if nargin < 6 || isempty(skip), skip = 10; end
    Nkeep = floor(mccount / skip);
    mccount = (Nkeep - 1) * skip + 1;

    reject = [0 0];
    accept = [0 0];
    models = nan(Nkeep, M);
    logP = nan(Nkeep, 2);
    logprior = logmodelprior(m);
    logL = loglikelihood(m);
    models(1, :) = m;
    logP(1, :) = [logprior logL];

    % Waitbar initialization
    hwait = waitbar(0, 'Markov Chain Monte Carlo', 'name', 'MCMC');
    pos = get(hwait, 'pos');
    set(hwait, 'pos', pos + [0 0 0 min(M, 10) * 12]);  % Adjust size based on M
    ctime = cputime;
    starttime = cputime;

    % Adaptive MCMC loop
    for ii = 2:mccount
        proposedm = stepfunction(m);
        proposed_logprior = logmodelprior(proposedm);

        if log(rand) < proposed_logprior - logprior
            proposed_logL = loglikelihood(proposedm);
            accept(1) = accept(1) + 1;
            if log(rand) < proposed_logL - logL
                m = proposedm;
                logL = proposed_logL;
                logprior = proposed_logprior;
                accept(2) = accept(2) + 1;
            else
                reject(2) = reject(2) + 1;
            end
        else
            reject(1) = reject(1) + 1;
        end

        % Store model and logP every 'skip' iterations
        if mod(ii - 1, skip) == 0
            row = ceil(ii / skip);
            models(row, :) = m;
            logP(row, :) = [logprior logL];
        end

        % Update waitbar display
        if cputime - ctime > 0.3
            rejectpct = sum(reject) / ii;
            Lrejectpct = reject(2) / accept(1);
            waitbar(ii / mccount, hwait, sprintf('Rejection: %3.0f%% (L_{reject}=%3.0f%%), ETA: %s', ...
                rejectpct * 100, Lrejectpct * 100, datestr((cputime - starttime) * (mccount - ii) / (ii * 60 * 60 * 24), 13)));

            % Check if the waitbar is still open (not closed)
            if ~ishandle(hwait)
                error('MCMC interrupted...');
            end

            ctime = cputime;
            drawnow;
        end
    end
    close(hwait);  % Close the waitbar when done

    % Compute acceptance rates
    acceptanceRate = accept(2) / (accept(2) + reject(2));
    overallAcceptanceRate = sum(accept) / (sum(accept) + sum(reject));
    avgLogPrior = mean(logP(:, 1));
    avgLogLikelihood = mean(logP(:, 2));
end


% % % function [models, logP, acceptanceRate, overallAcceptanceRate, avgLogPrior, avgLogLikelihood, reject] = mcmc(m, loglikelihood, logmodelprior, stepfunction, mccount, skip)
% % % if nargin == 0
% % %     logapriori = @(m) log((m > -2) .* (m < 2));
% % %     loglikelihood = @(m) 0; % log(normpdf(m, 1, .3));
% % %     m = mcmc(0, loglikelihood, logapriori, @(theta) randn(size(theta)), 50000, 3);
% % %     close all;
% % %     hist(m(:, 1), 30);
% % %     title('MCMC.m debug fig. should be flat - w. no edge effects!');
% % %     return;
% % % end
% % % 
% % % m = m(:)';
% % % M = length(m);
% % % if nargin < 6 || isempty(skip), skip = 10; end
% % % Nkeep = floor(mccount / skip);
% % % mccount = (Nkeep - 1) * skip + 1;
% % % 
% % % reject = [0 0];
% % % accept = [0 0];
% % % models = nan(Nkeep, M);
% % % logP = nan(Nkeep, 2);
% % % logprior = logmodelprior(m);
% % % logL = loglikelihood(m);
% % % models(1, :) = m;
% % % logP(1, :) = [logprior logL];
% % % 
% % % % Waitbar initialization
% % % hwait = waitbar(0, 'Markov Chain Monte Carlo', 'name', 'MCMC');
% % % ctime = cputime;
% % % starttime = cputime;
% % % 
% % % % Adaptive MCMC initialization
% % % targetAcceptanceRate = 0.234; % Target acceptance rate
% % % adaptFactor = 0.01;           % Adaptation speed
% % % currentStepSize = 1;          % Initialize step size
% % % 
% % % for ii = 2:mccount
% % %     % Adaptive step size logic
% % %     if mod(ii, 100) == 0 % Adjust every 100 iterations
% % %         currentAcceptanceRate = accept(2) / (accept(2) + reject(2));
% % %         if currentAcceptanceRate > targetAcceptanceRate
% % %             currentStepSize = currentStepSize * (1 + adaptFactor);
% % %         else
% % %             currentStepSize = currentStepSize * (1 - adaptFactor);
% % %         end
% % %         % Constrain step size to avoid extreme values
% % %         currentStepSize = max(currentStepSize, 1e-5);
% % %         currentStepSize = min(currentStepSize, 10);
% % %     end
% % % 
% % %     % Generate candidate sample using step function
% % %     proposedm = m + currentStepSize * stepfunction(m);
% % %     proposed_logprior = logmodelprior(proposedm);
% % % 
% % %     % Metropolis-Hastings acceptance criterion
% % %     if log(rand) < proposed_logprior - logprior
% % %         proposed_logL = loglikelihood(proposedm);
% % %         accept(1) = accept(1) + 1;
% % %         if log(rand) < proposed_logL - logL
% % %             m = proposedm;
% % %             logL = proposed_logL;
% % %             logprior = proposed_logprior;
% % %             accept(2) = accept(2) + 1;
% % %         else
% % %             reject(2) = reject(2) + 1;
% % %         end
% % %     else
% % %         reject(1) = reject(1) + 1;
% % %     end
% % % 
% % %     % Store model and logP every 'skip' iterations
% % %     if mod(ii - 1, skip) == 0
% % %         row = ceil(ii / skip);
% % %         models(row, :) = m;
% % %         logP(row, :) = [logprior logL];
% % %     end
% % % 
% % %     % Update waitbar display
% % %     if cputime - ctime > 0.3
% % %         rejectpct = sum(reject) / ii;
% % %         Lrejectpct = reject(2) / accept(1);
% % %         waitbar(ii / mccount, hwait, sprintf('Rejection: %3.0f%% (L_{reject}=%3.0f%%), ETA: %s', ...
% % %             rejectpct * 100, Lrejectpct * 100, datestr((cputime - starttime) * (mccount - ii) / (ii * 60 * 60 * 24), 13)));
% % %         if ~ishandle(hwait)
% % %             error('MCMC interrupted...');
% % %         end
% % %         ctime = cputime;
% % %         drawnow;
% % %     end
% % % end
% % % close(hwait); % Close the waitbar when done
% % % 
% % % % Compute acceptance rates
% % % acceptanceRate = accept(2) / (accept(2) + reject(2));
% % % overallAcceptanceRate = sum(accept) / (sum(accept) + sum(reject));
% % % avgLogPrior = mean(logP(:, 1));
% % % avgLogLikelihood = mean(logP(:, 2));
% % % end


% % % function [models, logP, acceptanceRate, overallAcceptanceRate, avgLogPrior, avgLogLikelihood, reject] = mcmc(m, loglikelihood, logmodelprior, stepfunction, mccount, skip)
% % % % Markov Chain Monte Carlo sampling of posterior distribution
% % % %
% % % % [mmc,logP]=mcmc(initialm,loglikelihood,logmodelprior,stepfunction,mccount,skip)
% % % % ---------
% % % %   initialm: starting point fopr random walk
% % % %   loglikelihood: function handle to likelihood function: logL(m)
% % % %   logprior: function handle to the log model priori probability: logPapriori(m)
% % % %   stepfunction: function handle with no inputs which returns a random
% % % %                 step in the random walk. (note stepfunction can also be a
% % % %                 matrix describing the size of a normally distributed
% % % %                 step.)
% % % %   mccount: How long should the markov chain be?
% % % %   skip: Thin the chain by only storing every N'th step [default=10]
% % % %
% % % %
% % % % Note on how to design a stepfunction from the model-covariance matrix:
% % % % Np=size(mmc,2);
% % % % [T,err]=cholcov(cov(mmc)); %see mvnrnd code
% % % % steplength=1; %adjustable parameter
% % % % stepfun=@()randn(1,Np) * T * steplength;
% % % %
% % % % EXAMPLE USAGE: fit a normal distribution to data
% % % % -------------------------------------------
% % % % data=randn(100,1)*2+3;
% % % % logmodelprior=@(m)0; %use a flat prior.
% % % % loglike=@(m)sum(log(normpdf(data,m(1),m(2))));
% % % % minit=[0 1];
% % % % m=mcmc(minit,loglike,logmodelprior,[.2 .5],10000);
% % % % m(1:100,:)=[]; %crop drift
% % % % plotmatrix(m);
% % % %
% % % %
% % % % --- Aslak Grinsted 2010-2014
% % % if nargin==0
% % %         logapriori=@(m)log((m>-2).*(m<2));
% % %         loglikelihood=@(m)0; % log(normpdf(m,1,.3));
% % % 
% % %         m=mcmc(0,loglikelihood,logapriori,1 ,50000,3);
% % % 
% % %         close all
% % %         hist(m(:,1),30)
% % %         title('MCMC.m debug fig. should be flat - w. no edge effects!')
% % % 
% % %         return
% % %     end
% % %     m=m(:)';
% % %     M=length(m);
% % % 
% % %     if (nargin<4)||isempty(stepfunction)
% % %         error('TODO: autodetermine stepsize')
% % %     end
% % %     if (nargin<6)||isempty(skip)
% % %         skip=10;
% % %     end
% % %     Nkeep=floor(mccount/skip);
% % %     mccount=(Nkeep-1)*skip+1;
% % % 
% % %     if ~isa(stepfunction,'function_handle')
% % %         stepsize=stepfunction;
% % %         if size(stepsize,1)==size(stepsize,2)
% % %             stepfunction=@()(randn(size(m)))*stepsize;
% % %         else
% % %             stepsize=stepsize(:)';
% % %             stepfunction=@()(randn(size(m))).*stepsize;
% % %         end
% % %     end
% % % 
% % %     reject=[0 0];
% % %     accept=[0 0];
% % %     hwait = waitbar(0, 'Markov Chain Monte Carlo','name','MCMC');
% % %     pos=get(hwait,'pos');
% % %     set(hwait,'pos',pos+[0 0 0 min(M,10)*12])
% % %     ctime=cputime;
% % %     starttime=cputime;
% % %     models=nan(Nkeep,M);
% % %     logP=nan(Nkeep,2);
% % %     logprior=logmodelprior(m);
% % %     logL=loglikelihood(m);
% % %     models(1,:)=m; logP(1,:)=[logprior loglikelihood(m)];
% % %     for ii=2:mccount
% % %         proposedm=m+stepfunction(m);
% % %         proposed_logprior=logmodelprior(proposedm);
% % %         if log(rand)<proposed_logprior-logprior
% % %             proposed_logL=loglikelihood(proposedm);
% % %             accept(1)=accept(1)+1;
% % %             if log(rand)<proposed_logL-logL
% % %                 m=proposedm;
% % %                 logL=proposed_logL;
% % %                 logprior=proposed_logprior;
% % %                 accept(2)=accept(2)+1;
% % %             else
% % %                 reject(2)=reject(2)+1;
% % %             end
% % %         else
% % %             reject(1)=reject(1)+1;
% % %         end
% % % 
% % %         if mod(ii-1,skip)==0
% % %             row=ceil(ii/skip);
% % %             models(row,:)=m;
% % %             logP(row,1)=logprior;
% % %             logP(row,2)=logL;
% % %         end
% % % 
% % %         if cputime-ctime>.3
% % %             rejectpct=sum(reject)/ii;
% % %             Lrejectpct=reject(2)/accept(1);
% % %             waitbar(ii/mccount,hwait,sprintf('Rejection: %3.0f%% (L_{reject}=%3.0f%%), ETA: %s',rejectpct*100,Lrejectpct*100,datestr((cputime-starttime)*(mccount-ii)/(ii*60*60*24),13)))
% % %             if ~ishandle(hwait)
% % %                 error('MCMC interrupted...')
% % %             end
% % %             ctime=cputime;
% % %             drawnow;
% % %         end
% % %     end
% % %     close(hwait);
% % % 
% % %     acceptanceRate = accept(2) / (accept(2) + reject(2));
% % %     overallAcceptanceRate = sum(accept) / (sum(accept) + sum(reject));
% % %     avgLogPrior = mean(logP(:, 1));
% % %     avgLogLikelihood = mean(logP(:, 2));
% % % end

% If needed, you could also return the rejection counts or more statistics
% based on your specific requirements.

% TODO: make standard diagnostics to give warnings...
% TODO: cut away initial drift.(?)
% TODO: make some diagnostic plots if nargout==0



% function [models, logP] = mcmc(m, loglikelihood, logmodelprior, stepfunction, mccount, skip)
%     % Markov Chain Monte Carlo sampling of posterior distribution
%     % [models, logP] = mcmc(initialm, loglikelihood, logmodelprior, stepfunction, mccount, skip)
% 
%     % Default values
%     if nargin < 6 || isempty(skip)
%         skip = 10;
%     end
% 
%     % Convert initial parameters to a row vector
%     m = m(:)';
%     M = length(m);
% 
%     % Handle stepfunction
%     if nargin < 4 || isempty(stepfunction)
%         error('Step function or covariance matrix must be provided.');
%     end
%     if ~isa(stepfunction, 'function_handle')
%         stepsize = stepfunction;
%         if size(stepsize, 1) == size(stepsize, 2)
%             stepfunction = @() randn(size(m)) * stepsize;
%         else
%             stepsize = stepsize(:)';
%             stepfunction = @() randn(size(m)) .* stepsize;
%         end
%     end
% 
%     % Initialize storage for samples and log probabilities
%     Nkeep = floor(mccount / skip);
%     models = nan(Nkeep, M);
%     logP = nan(Nkeep, 2);
% 
%     % Initial values
%     logprior = logmodelprior(m);
%     logL = loglikelihood(m);
%     models(1, :) = m;
%     logP(1, :) = [logprior, logL];
% 
%     % MCMC sampling
%     reject = [0, 0];
%     accept = [0, 0];
%     hwait = waitbar(0, 'Markov Chain Monte Carlo', 'Name', 'MCMC');
%     starttime = cputime;
%     ctime = starttime;
% 
%     for ii = 2:mccount
%         % Propose a new parameter vector
%         proposedm = m + stepfunction(m);
%         proposed_logprior = logmodelprior(proposedm);
% 
%         if log(rand) < proposed_logprior - logprior
%             proposed_logL = loglikelihood(proposedm);
%             accept(1) = accept(1) + 1;
%             if log(rand) < proposed_logL - logL
%                 m = proposedm;
%                 logL = proposed_logL;
%                 logprior = proposed_logprior;
%                 accept(2) = accept(2) + 1;
%             else
%                 reject(2) = reject(2) + 1;
%             end
%         else
%             reject(1) = reject(1) + 1;
%         end
% 
%         % Store sample
%         if mod(ii - 1, skip) == 0
%             row = ceil(ii / skip);
%             models(row, :) = m;
%             logP(row, 1) = logprior;
%             logP(row, 2) = logL;
%         end
% 
%         % Update progress bar
%         if cputime - ctime > 0.3
%             rejectpct = sum(reject) / ii;
%             Lrejectpct = reject(2) / accept(1);
%             waitbar(ii / mccount, hwait, sprintf('%.1f%% rejected (L_{reject} = %.1f%%), ETA: %s', ...
%                 rejectpct * 100, Lrejectpct * 100, datestr((cputime - starttime) * (mccount - ii) / (ii * 60 * 60 * 24), 13)));
%             ctime = cputime;
%             drawnow;
%         end
%     end
%     close(hwait);
% end

