function acc=NNs(trainData,testData,trainLabel,testLabel)
acc=0;
[testnum,~]=size(testData);
for i=1:testnum
    if testLabel(i)==NN(trainData,testData(i,:),trainLabel)
        acc=acc+1;
    end
end
acc=acc/testnum;