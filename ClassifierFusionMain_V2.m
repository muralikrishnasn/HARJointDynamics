%function ClassifierFusionMain()
clear all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% For KTH Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% actionClasses ={'handwaving','walking','jogging','running','handclapping','boxing'};
% 
% display('preparing joint angle features on KTH dataset')
% [angTrain, angTrLabel, angTest , angTsLabel,angValid, angVlLabel]= prepareJointAngleData(actionClasses);
% display('Classifying based on joint angle feature')
% 
% [c1_matrix, predLabel_angle] = jointAngleClassify(actionClasses,angTrain, angTrLabel, angTest , angTsLabel,angValid, angVlLabel);
% display('The confusion matrix based on joint angle using SVM')
% c1_matrix
% pause
% 
% display('preparing joint displacement feature on KTH dataset')
% [disTrain, disTrLabel, disTest , disTsLabel,disValid, disVlLabel]= prepareJointDisplacementData(actionClasses);
% display('Classifying based on joint displace feature')
% [c2_matrix, predLabel_Displacement] = jointDisplacementClassify(actionClasses,disTrain,disTrLabel, disTest , disTsLabel,disValid, disVlLabel);
% display('The confusion matrix based on joint displacement using SVM')
% c2_matrix
% pause
% % 
% % %R= corrcoef(predLabel_angle,predLabel_Displacement)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %For UT Kinect Data
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% actionClasses = {'walk', 'sitDown', 'standUp', 'pickUp', 'carry', 'throw', 'push', 'pull', 'waveHands', 'clapHands'};
% 
% display('preparing joint angle feature on UTKinect dataset')
% [angTrain, angTrLabel, angTest , angTsLabel,angValid, angVlLabel]= prepareJointAngleDataUTKinect(actionClasses);
% display('Classifying based joint angle feature')
% [c1_matrix, predLabel_angle] = jointAngleClassify(actionClasses,angTrain, angTrLabel, angTest , angTsLabel,angValid, angVlLabel);
% printmatrix(c1_matrix)
% 
% display('preparing joint displacement feature on UTKinect dataset')
% [disTrain, disTrLabel, disTest , disTsLabel,disValid, disVlLabel]= prepareJointDisplacementDataUTKinect(actionClasses);
% display('Classifying based joint displacement feature')
% [c2_matrix, predLabel_Displacement] = jointDisplacementClassify(actionClasses,disTrain,disTrLabel, disTest , disTsLabel,disValid, disVlLabel);
% printmatrix(c2_matrix)
% 
% R= corrcoef(predLabel_angle,predLabel_Displacement)
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %nClassifiers = 2;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %MSRAction3D dataset
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
actionLabeltoFile={'a01','a02','a03','a04','a05','a06','a07','a08','a09','a10'...
    'a11','a12','a13','a14','a15','a16','a17','a18','a19','a20'};


tr_te_splits=load('./datasets/MSRAction3DSkeleton/tr_te_splits.mat');
  
%    Three action sets are defined for testing 

for i = 1: size(tr_te_splits.action_sets,2)
    actionClasses = actionLabeltoFile(tr_te_splits.action_sets{i})

    [angTrain, angTrLabel, angTest , angTsLabel,angValid, angVlLabel]= prepareJointAngleDataMSRAction3D(actionClasses);
    [c1_matrix, predLabel_angle] = jointAngleClassify(actionClasses,angTrain, angTrLabel, angTest , angTsLabel,angValid, angVlLabel);



    [disTrain, disTrLabel, disTest , disTsLabel,disValid, disVlLabel]= prepareJointDisplacementDataMSRAction3D(actionClasses);
    [c2_matrix, predLabel_Displacement] = jointDisplacementClassify(actionClasses,disTrain,disTrLabel, disTest , disTsLabel,disValid, disVlLabel);
% 
% %    R= corrcoef(predLabel_angle,predLabel_Displacement)
% % 
% %     %     figure, plot(predLabel_angle,predLabel_Displacement,'*')
% 
% 
    display('Neural network is being trained...');
    inputs_1=[predLabel_angle, predLabel_Displacement]'; %For the test data

    targets_1=zeros(size(angTsLabel,1),size(actionClasses,1)); %Output class labels for test data

    for j= 1 : size(angTsLabel,1)
        targets_1(j,angTsLabel(j))=1; % or disTrLabel
    end

    targets_1=targets_1';

    
    
    [c1_matrix, predLabel_angle] = jointAngleClassify(actionClasses, angTest , angTsLabel,angTrain, angTrLabel,angValid, angVlLabel);
    [c2_matrix, predLabel_Displacement] = jointDisplacementClassify(actionClasses, disTest , disTsLabel,disTrain,disTrLabel, disValid, disVlLabel);

    inputs_2=[predLabel_angle, predLabel_Displacement]';
        
    targets_2=zeros(size(angTrLabel,1),size(actionClasses,1)); %Output class labels for test data

    for j= 1 : size(angTrLabel,1)
            targets_2(j,angTrLabel(j))=1; % or disTrLabel
    end

    targets_2=targets_2';
    
%     csvwrite('KTHTest.csv',inputs_1')
%     csvwrite('KTHTestLabel.csv',targets_1')
%        
%     csvwrite('KTHTrain.csv',inputs_2')
%     csvwrite('KTHTrainLabel.csv',targets_2')
%     
    inputs  = [inputs_1 inputs_2];
    targets = [targets_1 targets_2];

        
    hiddenLayerSize = 10;
    net = patternnet(hiddenLayerSize);

    net.trainParam.epochs = 100;
    rng('default');

    net.divideParam.trainRatio = 50/100;
     net.divideParam.valRatio   = 10/100;
      net.divideParam.testRatio  = 40/100;
    
    % net.divideParam.valRatio   = 15/100;
    % net.divideParam.testRatio  = 15/100;

    [net,tr] = train(net,inputs,targets);

    %training accuracy.
    outputs = net(inputs);
    
    [r, c]=find(targets);
    [rr, cc]= find(outputs==max(outputs));
    c3_matrix = confusionmat(r,rr)
    printmatrix(c3_matrix)
    pause
%     errors = gsubtract(targets,outputs);
%     performance = perform(net,targets,outputs);

    % 
    % tInd = tr.testInd;
    % tstOutputs = net(inputs(:,tInd));
    % tstPerform = perform(net,targets(:,tInd),tstOutputs);

    % view(net);
    % 
    % figure, plotperform(tr)
    display('Neural Net training complete')
    figure, plotconfusion(targets,outputs);
    title('Confusion Matrix - Neural Network Fusion')
%     
         pause
  end
 %end