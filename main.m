function main()
clc;
clear;
Times=10;
% [trainSet,testSet,trainLabel,testLabel,classNo,faceNo]=LoadData(Database,trainNo);
[trainSet,tt]=swiss_roll2(500);
% options.gnd=trainLabel;
options.k=5;
options.d=2;
Y=PFE(trainSet,options);
figure
scatter(Y(:,1),Y(:,2),90,tt,'.');
% scatter3(Y(:,1),Y(:,2),Y(:,3),20,trainLabel,'+');


options=[];
options.NeighborMode='KNN';
options.k=3;
options.Metric = 'Euclidean';
options.WeightMode = 'HeatKernel';
options.t = 5;
W = constructW(trainSet,options);
options.Regu=1;
options.ReguAlpha=0.1;
options.ReducedDim=2;
[eigpca,eigvpca]=PCA_T(trainSet,options);
TT=trainSet*eigpca;
[eigvector,eigval]=NPE(options,trainSet);
YY=trainSet*eigvector;
[Plpp,Vlpp]=LPP(W,options,trainSet);
ZZ=trainSet*Plpp;
D = EuDist2(trainSet, trainSet);
options = [];
options.dims = 2;
[UU, ~, ~] = Isomap(D, 'k', 5, options);
VV = UU.coords{1,1}';
figure;
scatter(TT(:,1),TT(:,2),90,tt,'.');
figure;
scatter(YY(:,1),YY(:,2),90,tt,'.');
figure;
scatter(ZZ(:,1),ZZ(:,2),90,tt,'.');
figure;
scatter(VV(:,1),VV(:,2),90,tt,'.');

