function results = wrapper

groupdata = importdata('groupdata.mat');

nstarts = 100; % number of random parameter initializations 

% run optimization
[params] = set_params; %use parameters defined in set_params script, which start as random according to the prior density functions defined.
f = @(x,data) MB_MF_rllik(x,data); % model from MB_MF_rllik script using all parameters defined.
results = mfit_optimize_parallel(f,params,groupdata,nstarts);% finds the max a postriori estimates of the parameters for each subject, using nstarts number of itterations over all parameters to maximize LL

results.id = [groupdata.id];

save('results_YA.mat', 'results')

t = array2table(results.x, 'RowNames', cellstr(num2str(results.id')), 'VariableNames', strrep({results.param.name}, ' ', '_'));
t.Properties.DimensionNames(1) = {'id'};
writetable(t, 'params.csv', 'WriteRowNames',true,'Delimiter','\t')

end
