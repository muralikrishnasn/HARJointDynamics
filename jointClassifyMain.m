%This function does the classification of action based on angle between the
% joints. The classifer used is a binary SVM classifier. This function
% invokes the binary classifier for all pairs of classes. i.e one vs one
% classsification. However this function is not useful as the updated
% version includes this in the classification function itself
function[CMatrixAll] = jointClassifyMain()
actionclasses ={'handwaving','walking','jogging','running','handclapping','boxing'};
CMatrixAll=zeros(6,6);
for i= 1: size(actionclasses,2)
    for j= 1: size(actionclasses,2)
        if(i~=j)
            actionpair = {actionclasses{i},actionclasses{j}}
           [c_matrix]= jointAngleClassify(actionpair)
            CMatrixAll(i,i) = c_matrix (1,1);
           % CMatrixAll(j,j) = c_matrix (2,2);
            CMatrixAll(i,j) = c_matrix (1,2);
           % CMatrixAll(j,i) = c_matrix (2,1);
        end
    end
end

end
