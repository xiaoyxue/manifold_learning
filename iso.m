clc;
clear;
[trainSet,tt]=swiss_roll2(1600);
D = EuDist2(trainSet, trainSet);
options = [];
options.dims = 2;
[Y, ~, ~] = Isomap(D, 'k', 5, options);
Z = Y.coords{1,1}';
scatter(Z(:,1),Z(:,2),90,tt,'.');


clc;
clear;
[trainSet,tt]=swiss_roll2(1500);
trainSet = trainSet';
Y = lle(trainSet, 12, 2);
Y = Y';
figure;
scatter(Y(:,1),Y(:,2),90,tt,'.');