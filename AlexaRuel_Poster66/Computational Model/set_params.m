function param = set_params

% create parameter structure; each condition (80 and 60) has their own set of parameters.
g = [2.9 2.2];  % parameters of the gamma prior
param(1).name = 'inverse temperature stage1 80';
param(1).logpdf = @(x) sum(log(gampdf(x,g(1),g(2))));  % log density function for prior
param(1).lb = 0;   % lower bound
param(1).ub = 20;  % upper bound

param(2).name = 'inverse temperature stage1 60';
param(2).logpdf = @(x) sum(log(gampdf(x,g(1),g(2))));  % log density function for prior
param(2).lb = 0;   % lower bound
param(2).ub = 20;  % upper bound

param(3).name = 'inverse temperature stage2 80';
param(3).logpdf = @(x) sum(log(gampdf(x,g(1),g(2))));  % log density function for prior
param(3).lb = 0;   % lower bound
param(3).ub = 20;  % upper bound

param(4).name = 'inverse temperature stage2 60';
param(4).logpdf = @(x) sum(log(gampdf(x,g(1),g(2))));  % log density function for prior
param(4).lb = 0;   % lower bound
param(4).ub = 20;  % upper bound

param(5).name = 'learning rate stage1 80';
param(5).logpdf = @(x) sum(log(betapdf(x,2,2)));
param(5).lb = 0;
param(5).ub = 1;

param(6).name = 'learning rate stage1 60';
param(6).logpdf = @(x) sum(log(betapdf(x,2,2)));
param(6).lb = 0;
param(6).ub = 1;

param(7).name = 'learning rate stage2 80';
param(7).logpdf = @(x) sum(log(betapdf(x,2,2)));
param(7).lb = 0;
param(7).ub = 1;

param(8).name = 'learning rate stage2 60';
param(8).logpdf = @(x) sum(log(betapdf(x,2,2)));
param(8).lb = 0;
param(8).ub = 1;

param(9).name = 'eligibility trace decay 80';
param(9).logpdf = @(x) sum(log(betapdf(x,2,2)));
param(9).lb = 0;
param(9).ub = 1;

param(10).name = 'eligibility trace decay 60';
param(10).logpdf = @(x) sum(log(betapdf(x,2,2)));
param(10).lb = 0;
param(10).ub = 1;

param(11).name = 'mixing weight 80';
param(11).logpdf = @(x) sum(log(betapdf(x,2,2)));
param(11).lb = 0;
param(11).ub = 1;

param(12).name = 'mixing weight 60';
param(12).logpdf = @(x) sum(log(betapdf(x,2,2)));
param(12).lb = 0;
param(12).ub = 1;

mu = 0; sd = 1;   % parameters of choice stickiness; choices that were made on the previous trial are given more weight 
param(13).name = 'choice stickiness 80';
param(13).logpdf = @(x) sum(log(normpdf(x,mu,sd)));
param(13).lb = -20;
param(13).ub = 20;

param(14).name = 'choice stickiness 60';
param(14).logpdf = @(x) sum(log(normpdf(x,mu,sd)));
param(14).lb = -20;
param(14).ub = 20;



end
