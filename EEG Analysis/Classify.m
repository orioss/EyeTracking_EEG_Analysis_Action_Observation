function [acc,total_acc_shuff]=Classify(data_from_cond1, data_from_cond2,iter_num, shuf_num)
% Classify gets data or two conditions and performs an SVM classification
% with a 'leave-one-out' and permutation test for significance
%
%% Syntax
% [acc,total_acc_shuff]=Classify(data_from_cond1, data_from_cond2,iter_num, shuf_num)
%
%% Description
% Classify gets two sets of data, one for each condition and performs SVM
% classification to differentiate the data using a 'leave-one-out' fashion.
% based on a given iteration number, it splits data to train set (n-1) and
% test set (1) and calculates accuracy. Then it averages the accuracy
% across iterations. It also gets a number of shuffle as input and
% calculate permutation test to validate accuracy significance. 
%
% Required Input.
% data_from_cond1: condition 1 data.
% data_from_cond2: condition 2 data.
% iter_num: number of 'leave-one-out' iteration., 
% shuf_num: number of shuffles for significance test.
%
% Output:
% acc: classification accuracy across iteations.
% total_acc_shuff: an array that contains all shuffle accuracies (number of
% shuffle is given in the input).



% converts data to double
data_from_cond1 = double(data_from_cond1);
data_from_cond2 = double(data_from_cond2);

% initialize output stuctures 
total_acc = 0;
total_acc_shuff = [];
train_sample = [];

% each condition has to have an equal amount of samples - align according
% to the minimum
min_size = min(size(data_from_cond1,1),size(data_from_cond2,1));
data_from_cond1=data_from_cond1(1:min_size,:);
data_from_cond2=data_from_cond2(1:min_size,:);

%% Analysis of "real" labels:
% iteration loop for permutation
for i=1:iter_num
    
    % randomly select an index for test set in each condition
    % ('leave-one-out')
    test_ind1=ceil(rand(1)*(size(data_from_cond1,1)-1)); 
    test_ind2=ceil(rand(1)*(size(data_from_cond2,1)-1)); 
    
    % creates a test set according to the index
    test_data1 = data_from_cond1(test_ind1,:);
    test_data2 = data_from_cond2(test_ind2,:);
    
    % creates a train set according to the index for each condition
    train_data1 = data_from_cond1; 
    train_data1(test_ind1,:)=[];   
    train_data2 = data_from_cond2; 
    train_data2(test_ind2,:)=[];
    
    % creates the data and labels for SVM
    test_labels = [1;2];
    train_labels = [repmat(1,[size(train_data1,1),1]); repmat(2,[size(train_data1,1),1])];
    train_sample = train_labels;
    
    % creates SVM model based on the training data
    model=svmtrain(train_labels, ([train_data1; train_data2]),'-q');
    
    % test model on test set
    [p_labels, accuracy, prob] = svmpredict(test_labels, [test_data1; test_data2],model,'-q');
    
    % add accuracy to "real" data accuracy
    total_acc = total_acc+accuracy(1);
end

% averaged the accuracy across permutations
acc = total_acc / iter_num;


%% Analysis of "shuffle" labels:
for jj=1:shuf_num
    
    % shuffles the "real" labels
    train_labels=train_sample (randperm(length(train_sample)));
    
    % runs the same analyses as the real data on the shuffled labels 
    total_acc =0;
    for i=1:iter_num
        test_ind1=ceil(rand(1)*(size(data_from_cond1,1)-1)); % choose random trial as "test" (leave-one-out)
        test_ind2=ceil(rand(1)*(size(data_from_cond2,1)-1)); % same for condition 2
        test_data1 = data_from_cond1(test_ind1,:);
        test_data2 = data_from_cond2(test_ind2,:);
        train_data1 = data_from_cond1; % use rest of trials as train..
        train_data1(test_ind1,:)=[];   % minus the 1 test trial
        train_data2 = data_from_cond2; % same for condition 2
        train_data2(test_ind2,:)=[];

        % SVM for shuffled data
        test_labels = [1;2];
        model=svmtrain(train_labels, ([train_data1; train_data2]),'-q');
        [p_labels, accuracy, prob] = svmpredict(test_labels, [test_data1; test_data2],model,'-q');
        total_acc = total_acc+accuracy(1);    
    end

    % adds the shuffled accuracy to the shuffle array
    total_acc_shuff = [total_acc_shuff total_acc/iter_num];
end