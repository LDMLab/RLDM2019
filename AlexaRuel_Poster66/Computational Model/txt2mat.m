function txt2mat

d=tdfread('data.YA.txt','\t',1);

ntrials = 116; % trials per block
nblocks = 4; % blocks per subject
nsubjects = numel(d.id)/(ntrials*nblocks);


% iterate over subjects
for sidx=1:nsubjects
    
    % create empty structure
    subject=struct;
    
    % determine first entry in input data for each subject since all data is in one file.
    firstpos=1+(ntrials*nblocks)*(sidx-1);
                                                                            % lastpos=(ntrials*nblocks)*sidx;
    
    subject.id = d.id(firstpos); % subject id
    subject.N = ntrials*nblocks; %  total number of trials, should equal 464 
    
    % create empty vectors with either NaN or 0 as place holders
    subject.a = nan(ntrials*nblocks,2); % action: two columns since 2 actions per trial
    subject.s2 = nan(ntrials*nblocks,1); % second-stage state: either 1,2,3,4 for now, for each possible (gogos) option at S2 
    subject.rew = nan(ntrials*nblocks,1); % reward
    subject.timeout = zeros(ntrials*nblocks,2); % timeout (col1: first stage, col2:second stage)
    subject.commontrans = nan(ntrials*nblocks,1); % common transition: yes or no
    subject.blockCondition = nan(ntrials*nblocks,1); % block condition: 2 possible conditions: 80/20 or 60/40
    subject.trialInBlock = nan(ntrials*nblocks,1); % number of trials in block: 116
    subject.rt = nan(ntrials*nblocks,2); % reaction time (col1:first stage, col2:second stage)
   
    % iterate over trials, filling in subject structure from data (d)
    for tidx=1:ntrials*nblocks %tdix is the number of trials over all 4 blocks for a given subject, ie. 464 trials 
        subject.a(tidx,1) = -(d.s1action(tidx+firstpos-1)-2); %first position ensures that the trials line up with individual participants
        subject.a(tidx,2) = mod(d.s2action(tidx+firstpos-1)-1,2)+1;
        if d.Volk1(tidx+firstpos-1)<=2 % In original data structure 1 & 2 are two options from Stage 2 state 1, these are both coded as 1.
            subject.s2(tidx) = 1;
        else
            subject.s2(tidx) = 2; % 3&4 are stage 2, state 2, and thus recoded as 2.
        end
        subject.rew(tidx) = d.reward(tidx+firstpos-1);
        subject.commontrans(tidx) = -(d.trans(tidx+firstpos-1)-2);
        subject.rt(tidx,1) = d.state1RT(tidx+firstpos-1);
        subject.rt(tidx,2) = d.state2RT(tidx+firstpos-1);
        if d.Volk1(tidx+firstpos-1)==999 % timeout stage 1, then all following entries should be NaN since no further action was taken in this trial
            subject.timeout(tidx,1) = 1;
            subject.a(tidx,:) = [NaN, NaN];
            subject.s2(tidx) = NaN;
            subject.rew(tidx) = NaN;
            subject.commontrans(tidx) = NaN;
            subject.rt(tidx,:) = [NaN, NaN];
        elseif d.s2action(tidx+firstpos-1)==999 % timeout stage 2, all entries dependent on stage 2 action should be NaN
            subject.timeout(tidx,2) = 1;
            subject.a(tidx,2) = NaN;
            subject.rew(tidx) = NaN;
            subject.rt(tidx,2) = NaN;
        end
            
        subject.blockCondition(tidx) = d.cond(tidx+firstpos-1);
        subject.trialInBlock(tidx) = mod(d.trials(tidx+firstpos-1)-1,ntrials)+1;
        
        
        
    end
    
    if ~exist('output', 'var') % if does not exist
        output = subject;
    else
        % concatenate subject structure with output structure
        output = [output subject];
    end
end

save('groupdata.mat', 'output')


end