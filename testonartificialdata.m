xrange = [5,95];
ntrain = 2000;
ntest = 100;
[Train, Test, f] = makeartificialdata(ntrain,ntest,xrange);    

fplot(f,xrange);
hold on
set(gcf, 'Position',  [0, 0, 1000, 1000])
xlim([15,85]);
ylim([30,70]);
scatter(Test.x, Test.y_m,'.');
scatter(Train.x, Train.y_m,'.');

Grid = table();

[Grid.x, Grid.y_nans] = nans_sbr(Train.x, Train.y_m, 150, "Increasing");
Test.y_nans = interp1(Grid.x, Grid.y_nans, Test.x, 'linear', 'extrap');

Grid.y_sbr = sbr(Train.x, Train.y_m, Grid.x, "Increasing");
Test.y_sbr = sbr(Train.x, Train.y_m, Test.x, "Increasing");

svm = fitrsvm(Train.x, Train.y_m, 'KernelFunction', 'gaussian');
Grid.y_svr = predict(svm, Grid.x);
Test.y_svr = predict(svm, Test.x);

hiddenLayerSizes = [10];
net = fitnet(hiddenLayerSizes,'trainlm');
net.divideParam.trainRatio = 90/100;
net.divideParam.valRatio = 10/100;
net.divideParam.testRatio = 0/100;
net.trainParam.showWindow = false;
net= train(net,Train.x',Train.y_m');
Grid.y_ann = net(Grid.x')';
Test.y_ann = net(Test.x')';

tree = fitrtree(Train.x, Train.y_m);
Grid.y_rt = predict(tree, Grid.x);
Test.y_rt = predict(tree, Test.x);

plot(Grid.x, Grid.y_nans);
plot(Grid.x, Grid.y_sbr);
plot(Grid.x, Grid.y_svr);
plot(Grid.x, Grid.y_ann);
plot(Grid.x, Grid.y_rt);

legend('generator', 'testdata', 'traindata', 'nans', 'sbr', 'svr', ...
       'nn', 'rt');

indices = table('Size', [5 0], 'RowNames', {'nans','sbr','svr','nn','rt'});

indices.sqm('nans')     = sqm(Test.y_m, Test.y_nans);
indices.sqm('sbr')      = sqm(Test.y_m, Test.y_sbr);
indices.sqm('svr')      = sqm(Test.y_m, Test.y_svr);
indices.sqm('nn')       = sqm(Test.y_m, Test.y_ann);
indices.sqm('rt')       = sqm(Test.y_m, Test.y_rt);

indices.vaf('nans')     = vaf(Test.y_m, Test.y_nans);
indices.vaf('sbr')      = vaf(Test.y_m, Test.y_sbr);
indices.vaf('svr')      = vaf(Test.y_m, Test.y_svr);
indices.vaf('nn')       = vaf(Test.y_m, Test.y_ann);
indices.vaf('rt')       = vaf(Test.y_m, Test.y_rt);

indices.R2('nans')     = r2(Test.y_m, Test.y_nans);
indices.R2('sbr')      = r2(Test.y_m, Test.y_sbr);
indices.R2('svr')      = r2(Test.y_m, Test.y_svr);
indices.R2('nn')       = r2(Test.y_m, Test.y_ann);
indices.R2('rt')       = r2(Test.y_m, Test.y_rt);

trim=10;
indices.relroughness('nans') = relroughness(Grid.y_nans(1+trim:end-trim));
indices.relroughness('sbr')  = relroughness(Grid.y_sbr(1+trim:end-trim));
indices.relroughness('svr')  = relroughness(Grid.y_svr(1+trim:end-trim));
indices.relroughness('nn')   = relroughness(Grid.y_ann(1+trim:end-trim));
indices.relroughness('rt')   = relroughness(Grid.y_rt(1+trim:end-trim));

indices.roughness('nans') = roughness(Grid.y_nans(1+trim:end-trim));
indices.roughness('sbr')  = roughness(Grid.y_sbr(1+trim:end-trim));
indices.roughness('svr')  = roughness(Grid.y_svr(1+trim:end-trim));
indices.roughness('nn')   = roughness(Grid.y_ann(1+trim:end-trim));
indices.roughness('rt')   = roughness(Grid.y_rt(1+trim:end-trim));

indices
pause
close