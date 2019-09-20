function [Xtrain_data,train_label,Xtest_data,test_label, Xvalidate_data, validate_label] = prepareJointAngleDataMSRAction3D(actionclasses);
    directory = './datasets/MSRAction3DSkeleton/processed';
    %actionclasses ={'handwaving','walking','jogging','running','handclapping','boxing'};
    
%     testlist={'person02','person03','person05','person06','person07','person08','person09',...
%         'person10','person22'};
% 
%     validatelist={'person01','person04','person19','person20','person21','person23','person24',...
%         'person25'};
%     trainlist ={'person11','person12','person13','person14','person15','person16','person17',...
%         'person18'}
    
    tr_te_splits=load('./datasets/MSRAction3DSkeleton/tr_te_splits.mat');
    tr_subjects = tr_te_splits.tr_subjects(1,:);
    te_subjects = tr_te_splits.te_subjects(1,:);
    
    
    
    subjecttoFile={'s01','s02','s03','s04','s05','s06','s07','s08','s09','s10'};
    testlist = {subjecttoFile{te_subjects}};
    trainlist = {subjecttoFile{tr_subjects}};
    validatelist={};
    
    

    idxvalidatelbl =0;
    idxtrainlbl = 0;
    idxtestlbl = 0;

    % Number of Joints
    NJoints =20;
    Xtrain_data = [];
    train_label = [];

    Xtest_data = [];
    test_label = [];

    Xvalidate_data = [];
    validate_label = [];

    %Threshold
    T = 20;
    bins = 16;

    maxangle=90;
    
    Tl = maxangle/bins;
    for i = 1 : size(actionclasses,2)
        %curdir =  strcat(directory, actionclasses{i});
        curdir = directory;
        name=strcat(curdir,'/*',actionclasses{i},'*.csv');
        FileList=dir(name);
        


        for k=1:length(FileList)
           FileName=FileList(k).name;

    % %       Open the json file with the stips
           fname = strcat(curdir,'/',FileName(1:size(FileName,2)-3),'json');

           jsondata = jsondecode(fileread(fname));
           nframes = jsondata.numberofframes;

           %val = jsondecode(fileread(fname));
           %stips = val.stips

    %        
           data = csvread(strcat(curdir,'/',FileName));
           data =data*(180 / 3.142);%Scale used for MSRAction3D dataset
    %        [mnindx, mnval]=min(data)
    %        [mxindx, mxval]=max(data)
           %Joint j 
           startv = 1 ;
           endv   = NJoints;

           Vi=zeros(NJoints);
           V = [];

           for j = 1 : NJoints
                 %sum(data(startv:endv,:)') 
                 b=0;
                 dec=0;
                 for ang = 0 : Tl : maxangle
                     dec=dec+2^b*((sum(data(startv:endv,:)')/nframes) > ang);
                     b=b+1;
                 end
                 Vi= dec;
                 V=[V, Vi];
                 

    %              joint = data(startv:endv,:)
    %              plot(joint(1,:))
    %              for i= 1: 10
    %                      plot(joint(i,:))
    %              end
                 startv = startv + NJoints;
                 endv = endv + NJoints;
                 %plot stip vs joint j for the entire frame
                 %hold on

           end

           for idx = 1 :size(testlist,2)
                      loc=strfind(FileName,testlist(idx));
                      if(~isempty(loc))
                              Xtest_data=[Xtest_data;V];
                              idxtestlbl= idxtestlbl + 1;
                              test_label(idxtestlbl)= i;
                              break;
                      end
           end

           for idx = 1 :size(trainlist,2)
                      loc=strfind(FileName,trainlist(idx));
                      if(~isempty(loc))
                              Xtrain_data=[Xtrain_data;V];
                              idxtrainlbl= idxtrainlbl + 1;
                              train_label(idxtrainlbl)= i;
                              break;
                      end
           end


           for idx = 1 :size(validatelist,2)
                      loc=strfind(FileName,validatelist(idx));
                      if(~isempty(loc))
                              Xvalidate_data =[Xvalidate_data;V];
                              idxvalidatelbl = idxvalidatelbl + 1;
                              validate_label(idxvalidatelbl)= i;
                              break;
                      end
           end

    %         x=stips(1,1)
    %         y=stips(1,2)
    %         plot(x,y,'*')
    %         figure

        end
    end
    train_label = train_label';%>1;
    test_label = test_label';%>1;
    validate_label = validate_label';%>1;
