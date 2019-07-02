function [LL, latents] = MB_MF_rllik(x,subdata)

% parameters, will start off as a random number as determined by the bounds specified in the set_params script.
b1_80 = x(1);           % softmax inverse temperature stage 1
b1_60 = x(2);
b2_80 = x(3);           % softmax inverse temperature stage 2
b2_60 = x(4);
lr1_80 = x(5);          % learning rate stage 1
lr1_60 = x(6);
lr2_80 = x(7);          % learning rate stage 2
lr2_60 = x(8);
lambda_80 = x(9);       % eligibility trace decay
lambda_60 = x(10);
w_80 = x(11);           % model-based weight
w_60 = x(12);
st_80 = x(13);          % choice stickiness
st_60 = x(14);

% initialization
N = subdata.N; 
LL = 0;

pe = nan(N,2); % create empty vectors for the values that will be later added to the latent structure 
Q = nan(N,2); % hybrid Q values 
Qd1 = nan(N,2); %for the stage 1 Q values (mf but same for mb)
Qd2 = nan(N,2); % for stage 2 Q values (only the state which the participant is currently in) 
Qm = nan(N,2); % for model-based Q values


% loop through trials
for t = 1:N
    
    % Reset values and select parameters on first trial for each block.
    if subdata.trialInBlock(t) == 1 % if the current trial is the first one of the block, go through lines 43 to 67, if not, skips to line 70.
        Qd = 0.5*ones(3,2);         % initializes Qd (model-free reward expectation) choice values to 0.5 for each stage and state (S1, S2(state1), S2(state2)) which results in a 3 x 2 matrix of 0.5 
        M = [0; 0];                 % last choice structure, starts at 0,0 since no choice has yet been made.
        TmDetected = 0;  % transition matrix structure detection starts at 0, and will be updated to 1 later once determineTm has found which plane (s1) transitions to which state in s2. 
        
        if subdata.blockCondition(t) == 80 % if current block is 80/20, then all parameters are using the 80 parameters
            b1 = b1_80;
            b2 = b2_80;
            lr1 = lr1_80;
            lr2 = lr2_80;
            lambda = lambda_80;
            w = w_80;
            st = st_80;
        elseif subdata.blockCondition(t) == 60 % if current block is 60/40, then all parameters are using the 60 parameters
            b1 = b1_60;
            b2 = b2_60;
            lr1 = lr1_60;
            lr2 = lr2_60;
            lambda = lambda_60;
            w = w_60;
            st = st_60;
        else
            error('Could not determine block condition for subject %s in trial %s', num2str(subdata.id), num2str(t))
        end      
    end

    % Break if trial was missed; if no timeout is found in either s1 or s2 choice, continue, if timeout found, then skips the rest of script.
    if (subdata.timeout(t,1) == 1 || subdata.timeout(t,2) == 1)
        continue
    end
    
    % Infer transition matrix; which plane transitioned to which S2 state?
    if TmDetected == 0 % should be at 0 since set to this previously (line 46)
        Tm = determineTm(t, subdata); % calls in determineTm script to determine the tansitions
        TmDetected = 1; % 1 when complete
    end         
    
    
    state2 = subdata.s2(t)+1; %Stage 2 states until now are coded as 1 and 2 (see txt2mat.m). Since in our Qd these are rows 2 and 3, we are transforming our 1 and 2 to 2 and 3. Later state2 is used to kmow if we transitioned into state 1 or 2 of state 2.
    
    
    
   %Calculate mf choice for stage 2 (will be the same for mb), and mb & mf hybrid for stage 1 choice. 
    
    maxQ = max(Qd(2:3,:),[],2);  % take max value in row 2 and 3 of Qd(mf exp reward), which is max for each state of stage 2 (I.e, optimal reward at second step.) same for MB and MF
    Qm = Tm'*maxQ; % compute model-based value function (Qm). Takes transition matrix structure and muliplies it by the max reward at stage 2.

    Q = w*Qm + (1-w)*Qd(1,:)' + st.*M; % Weighted sum of the mb and mf values for S1 choice only. Since stage 2 choice is the same for mb and mf.
                                       % st.*M represents the stickiness multiplied by the M, which gives extra weight to the previous choice.
                                       % w is another free parameter which will be optimized during wrapper function.
    
    LL = LL + b1*Q(subdata.a(t,1))-logsumexp(b1*Q); % log likelihood of choices FOR STAGE 1, given the expected reward of the participant (softmax function: transformed). Takes the unbounded values of reward expectancy (Q), and turns them into a probability.
                                                    % I.e., determines the likelihood of making a choice based on the expected rewards.
                                                    % LL : sum of actions in all previous trials 
                                                    % so, overall: LL + (beta*value of action at S1) - (value of both actions at S1)
                                                    % LL + likelihood of current action
   
                                                    
    LL = LL + b2*Qd(state2,subdata.a(t,2)) - logsumexp(b2*Qd(state2,:)); % same as previous LL function but for the stage 2 choice where state2 is indicating if at stage 2 we ended up in state 1 or 2.

    M = [0; 0];
    M(subdata.a(t,1)) = 1;  % Stores information about which action was taken, to be added to the stickiness on the next trial (see line 91)
                            % given that is only storing information for next trial, could also go to line 115.
    
    dtQ(1) = Qd(state2,subdata.a(t,2)) - Qd(1,subdata.a(t,1)); % State PE (dtQ) for stage 1. Since no reward after S1, SPE is expected state in transitioning to state 1 or 2 - value of action made at S1.
    Qd(1,subdata.a(t,1)) = Qd(1,subdata.a(t,1)) + lr1*dtQ(1);  % update TD value function using the RPE calculated above for S1. 
     
    dtQ(2) = subdata.rew(t) - Qd(state2,subdata.a(t,2));  % reward prediction error (RPE) for 2nd choice. Now, since do receive a reward after S2, add this as reward - expected reward for that action.
    
    Qd(state2,subdata.a(t,2)) = Qd(state2,subdata.a(t,2)) + lr2*dtQ(2);  % RPE for choice 2 updates stage 1 expected reward (TD value function)
    Qd(1,subdata.a(t,1)) = Qd(1,subdata.a(t,1)) + lambda*lr1*dtQ(2);     % RPE for choice 2 also updates stage 2 expectations of reward using lambda
   
    
    % store latent variables
    if nargout > 1
        latents.pe(t,1) = dtQ(1);
        latents.pe(t,2) = dtQ(2);
        latents.Q(t,1) = Q(1);
        latents.Q(t,2) = Q(2);
        latents.Qm(t,1) = Qm(1);
        latents.Qm(t,2) = Qm(2);
        latents.Qd1(t,1) = Qd(1,1);
        latents.Qd1(t,2) = Qd(1,2);
        latents.Qd2(t,1) = Qd(state2,1);
        latents.Qd2(t,2) = Qd(state2,2);
    end
    
end

end
