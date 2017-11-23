function class=NN(trainData,testData,trainLabel)
distance=EuDist2(trainData,testData);
[result,index]=min(distance);
class=trainLabel(index);
end