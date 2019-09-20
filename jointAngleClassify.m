function [c_matrix,oofLabel]= jointAngleClassify(actionclasses, Xtrain_data,train_label,Xtest_data,test_label, Xvalidate_data,validate_label)
%     directory = './sampledataset/';
%     actionclasses ={'handwaving','walking','jogging','running','handclapping','boxing'};
%     testlist={'person02','person03','person05','person06','person07','person08','person09',...
%         'person10','person22'};
% 
%     validatelist={'person01','person04','person19','person20','person21','person23','person24',...
%         'person25'};
%     trainlist ={'person11','person12','person13','person14','person15','person16','person17',...
%         'person18'};%'person01','person04','person19','person20','person21','person23','person24',    'person25'};
%     %validatelist={}
% 
% 
%     idxvalidatelbl =0;
%     idxtrainlbl = 0;
%     idxtestlbl = 0;
% 
%     % Number of Joints
%     NJoints =25;
%     Xtrain_data = []
%     train_label = []
% 
% 
%     Xtest_data = []
%     test_label = []
% 
%     Xvalidate_data = []
%     validate_label = []
% 
%     %Threshold
%     T = 20;
%     bins = 8;
% 
%     maxangle=0;
%     for i = 1 : size(actionclasses,2)
%         curdir =  strcat(directory, actionclasses{i});
%         name=strcat(curdir,'/*.csv');
%         FileList=dir(name);
% 
% 
%         for k=1:length(FileList)
%            FileName=FileList(k).name;
% 
%     % %       Open the json file with the stips
%            fname = strcat(curdir,'/',FileName(1:size(FileName,2)-3),'json');
% 
%            jsondata = jsondecode(fileread(fname));
%            nframes = jsondata.numberofframes;
% 
%            %val = jsondecode(fileread(fname));
%            %stips = val.stips
% 
%     %        
%            strcat(curdir,'/',FileName)
%            data = csvread(strcat(curdir,'/',FileName));
%            data =data*(180 / 3.142);
%     %        [mnindx, mnval]=min(data)
%     %        [mxindx, mxval]=max(data)
%            %Joint j 
%            startv = 1 ;
%            endv   = NJoints;
% 
%            Vi=zeros(NJoints);
%            V = [];
% 
%            for j = 1 : NJoints
%                  %sum(data(startv:endv,:)') 
%                  b=0;
%                  dec=0;
%                  for ang = 0 : 12 : 90
%                      dec=dec+2^b*((sum(data(startv:endv,:)')/nframes) > ang);
%                      b=b+1;
%                  end
%                  Vi= dec;
%                  V=[V, Vi];
% 
%     %              joint = data(startv:endv,:)
%     %              plot(joint(1,:))
%     %              for i= 1: 10
%     %                      plot(joint(i,:))
%     %              end
%                  startv = startv + NJoints;
%                  endv = endv + NJoints;
%                  %plot stip vs joint j for the entire frame
%                  %hold on
% 
%            end
% 
%            for idx = 1 :size(testlist,2)
%                       loc=strfind(FileName,testlist(idx));
%                       if(~isempty(loc))
%                               Xtest_data=[Xtest_data;V];
%                               idxtestlbl= idxtestlbl + 1;
%                               test_label(idxtestlbl)= i;
%                               break;
%                       end
%            end
% 
%            for idx = 1 :size(trainlist,2)
%                       loc=strfind(FileName,trainlist(idx));
%                       if(~isempty(loc))
%                               Xtrain_data=[Xtrain_data;V];
%                               idxtrainlbl= idxtrainlbl + 1;
%                               train_label(idxtrainlbl)= i;
%                               break;
%                       end
%            end
% 
% 
%            for idx = 1 :size(validatelist,2)
%                       loc=strfind(FileName,validatelist(idx));
%                       if(~isempty(loc))
%                               Xvalidate_data =[Xvalidate_data;V];
%                               idxvalidatelbl = idxvalidatelbl + 1;
%                               validate_label(idxvalidatelbl)= i;
%                               break;
%                       end
%            end
% 
%     %         x=stips(1,1)
%     %         y=stips(1,2)
%     %         plot(x,y,'*')
%     %         figure
% 
%         end
%     end
%     train_label = train_label';%>1;
%     test_label = test_label';%>1;
%     validate_label = validate_label';%>1;

    %SVMModel = fitcsvm(Xtrain_data,train_label,'KernelFunction','rbf','Standardize',true, 'KernelScale','auto');
%     %[label,score] = predict(SVMModel,Xtest_data);


    t = templateSVM('KernelFunction','rbf', 'Standardize',true, 'KernelScale','auto');
    SVMModel = fitcecoc(Xtrain_data,train_label,'coding','onevsall','Learners',t);
    

%    KNNModel = fitcknn(Xtrain_data,train_label,'NumNeighbors',5,'Standardize',1)
 %    [oofLabel, score] = predict(KNNModel,Xtest_data);


%     
%     options = statset('UseParallel',true);
%     CVMdl = crossval(SVMModel,'Options',options);
%     
%     oofLabel = kfoldPredict(CVMdl,'Options',options);
    %c_matrix =confusion.getMatrix(test_label,oofLabel);
    
  % ConfMat = confusionchart(test_label,oofLabel,'RowSummary','total-normalized');
  % ConfMat.InnerPosition = [0.10 0.12 0.85 0.85];
    
  [oofLabel,score] = predict(SVMModel,Xtest_data);
    c_matrix = confusionmat(test_label,oofLabel);


    n = size(Xtest_data,1);
    % Convert the integer label vector to a class-identifier matrix.
    isLabels = unique(test_label);
    nLabels = numel(isLabels);

    [~,grpOOF] = ismember(oofLabel,isLabels); 
    oofLabelMat = zeros(nLabels,n); 
    idxLinear = sub2ind([nLabels n],grpOOF,(1:n)'); 
    oofLabelMat(idxLinear) = 1; % Flags the row corresponding to the class 
    [~,grpY] = ismember(test_label,isLabels); 

    YMat = zeros(nLabels,n); 
    idxLinearY = sub2ind([nLabels n],grpY,(1:n)'); 
    YMat(idxLinearY) = 1; 

    figure;
    plotconfusion(YMat,oofLabelMat);
    title('Confusion Matrix - Joint Angles')

    oofLabel = score;
    
    
    % result = (label==test_label);
    % disp 'True Positives'
    % TPR = sum(result)/size(result,1)
    %c_matrix = confusion.getMatrix(test_label,label);
    % %Evaluate(test_label,label)

    %label=multisvm(Xtrain_data,train_label,Xtest_data);
    %c_matrix =confusion.getMatrix(test_label,label);

    % 
%     KNNModel = fitcknn(Xtrain_data,train_label,'NumNeighbors',5,'Standardize',1)
%     oofLabel = predict(KNNModel,Xtest_data);
%     ConfMat = confusionmat(test_label,oofLabel)
% 
% 
%     n = size(Xtest_data,1)
%     % Convert the integer label vector to a class-identifier matrix.
%     isLabels = unique(test_label);
%     nLabels = numel(isLabels)
% 
%     [~,grpOOF] = ismember(oofLabel,isLabels); 
%     oofLabelMat = zeros(nLabels,n); 
%     idxLinear = sub2ind([nLabels n],grpOOF,(1:n)'); 
%     oofLabelMat(idxLinear) = 1; % Flags the row corresponding to the class 
%     [~,grpY] = ismember(test_label,isLabels); 
% 
%     YMat = zeros(nLabels,n); 
%     idxLinearY = sub2ind([nLabels n],grpY,(1:n)'); 
%     YMat(idxLinearY) = 1; 
% 
%     figure;
%     plotconfusion(YMat,oofLabelMat);
% inputs = Xtrain_data;
% 
% targets = zeros(size(Xtrain_data,1),size(Xtrain_data,2));
% for iid = 1 : size(train_label)
%     target(i,train_label(i))=1; 
% end
% hiddenLayerSize = 10;
% net = patternnet(hiddenLayerSize);
% [net,tr] = train(net,inputs,targets);
% 
% % Test the Network
% outputs = net(Xtest_data);
%  figure, plotconfusion(test_label,outputs)
%  
% % View the Network
% view(net)

% % Set up Division of Data for Training, Validation, Testing
% net.divideParam.trainRatio = 70/100;
% net.divideParam.valRatio = 15/100;
% net.divideParam.testRatio = 15/100;




end
