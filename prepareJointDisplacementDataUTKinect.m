function [Xtrain_data,train_label,Xtest_data,test_label, Xvalidate_data, validate_label]= prepareJointDisplacementData(actionclasses)
    directory = './datasets/UTKinect/processed';
    %actionclasses ={'handwaving','walking','jogging','running','handclapping','boxing'};
    testlist={'s01_e01','s02_e02','s04_e01','s05_e02','s07_e01','s08_e02','s10_e01'};

    validatelist={'s01_e02','s03_e01','s04_e02','s06_e01','s07_eo2',};
    trainlist ={'s02_e01','s03_e02','s05_e01','s06_e02','s08_e01','s09_e01','s09_e02','s10_e02'}


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

    
    bins = 16;
    maxangle=90;
    Tl = maxangle/bins;
    
    for i = 1 : size(actionclasses,2)
        %curdir =  strcat(directory, actionclasses{i});
        curdir = directory;
        name=strcat(curdir,'/*',actionclasses{i},'*.txt');
        FileList=dir(name);


        for k=1:length(FileList)
           FileName=FileList(k).name;
            

    % %       Open the json file with the stips
           fname = strcat(curdir,'/',FileName(1:size(FileName,2)-8),'.json'); %remove _dis.txt

           jsondata = jsondecode(fileread(fname));
           nframes = jsondata.numberofframes;

           %val = jsondecode(fileread(fname));
           %stips = val.stips

    %        
%             strcat(curdir,'/',FileName)
            data = csvread(strcat(curdir,'/',FileName));
           
            %Joint j 
            startv = 1 ;
            endv   = NJoints;
            V = [];
            Magnitude= data(startv:endv,:)/max(max(data));
            startv = startv + NJoints;
            endv = endv + NJoints;
            Orientation = data(startv:endv,:);
            n_1=20;
            Orientation_feature =[];
            Magnitude_feature = [];
            for jnt = 1 : NJoints
                binCenters = linspace(-pi,pi,n_1+1)*180/pi;
                binCenters = binCenters+(binCenters(2)-binCenters(1))/2;
                binCenters = binCenters(1:numel(binCenters)-1);
                fineHist = hist(Orientation(jnt,:),binCenters);
                Orientation_feature =[Orientation_feature, fineHist];
            end
%             for jnt = 1 : NJoints
%                 binCenters = linspace(-pi,pi,n_1+1);
%                 binCenters = binCenters+(binCenters(2)-binCenters(1))/2;
%                 binCenters = binCenters(1:numel(binCenters)-1);
%                 fineHist = hist(Magnitude(jnt,:),binCenters);
%                 Magnitude_feature =[Magnitude_feature, fineHist]
%             end
    
           for idx = 1 :size(testlist,2)
                      loc=strfind(FileName,testlist(idx));
                      if(~isempty(loc))
                              %Xtest_data=[Xtest_data;Magnitude_feature];
                              Xtest_data=[Xtest_data;Orientation_feature];
                              idxtestlbl= idxtestlbl + 1;
                              test_label(idxtestlbl)= i;
                              break;
                      end
           end

           for idx = 1 :size(trainlist,2)
                      loc=strfind(FileName,trainlist(idx));
                      if(~isempty(loc))
                              Xtrain_data=[Xtrain_data;Orientation_feature];
                              %Xtrain_data=[Xtrain_data;Magnitude_feature];
                              idxtrainlbl= idxtrainlbl + 1;
                              train_label(idxtrainlbl)= i;
                              break;
                      end
           end


           for idx = 1 :size(validatelist,2)
                      loc=strfind(FileName,validatelist(idx));
                      if(~isempty(loc))
                              Xvalidate_data =[Xvalidate_data;Orientation_feature];
                              %Xvalidate_data =[Xvalidate_data;Magnitude_feature];
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
