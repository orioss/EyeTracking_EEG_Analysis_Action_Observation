function VideoClassification(group_subject_array, shuffle_num)
% VideoClassification uses CNN to classify an action based on looking videos
%
%% Syntax
% VideoClassification(AOI_event_array, shuffle_num) 
%
%% Description
% VideoClassification gets an array that has the groups and all subjects 
% per group. Also gets whether this is a shuffle run (and permutation of 
% the labels is needed) is so - which shuffle number is it (if this is 
% real data, than shuffle = 0). It divides the data to train (that
% includes also validation set for training) and test sets. It builds the
% model above the first layer that was alread ycreated and train the model
% on the train set. then, test the model on the test sets. 
%
% Required Input.
% group_subject_array: array including the group and the subject numbers
% shuffle_num: the shuffle index (if =0, no permultation of the labels)
rng('shuffle');

% creates the folder for the files with the classification results
mkdir('CNN_Results')

% go over the groups
for group=1:2
    
    % gets all the subject in the group
    group_subjects = unique(group_subject_array(group_subject_array(:,1)==group-1,2));
    
    % gets the input to the classifier for the particular subject
    load(fullfile('DataForCNN',['group_' num2str(group) '_subj_' num2str(subj_ix) '.mat']));


    % in case this is a shuffle - makes a random permutations of the labels
    % for a particular shuffle. all the rest stays the same
    if (shuffle_num>0)
        labels1=labels1(randperm(length(labels1)))
    end
    
    % make labels categorical
    labels = categorical(labels1);
    numObservations = numel(sequences);
    accuracy=0;
    
    % make 500 classification iterations and average accuracy across them ('leave-one-out'
    % procedure)
    for iter=1:500
        
        % Gets the number of samples for the first display type
        numObservations1=find(strcmp(labels1,'1')); 
        
        % Gets the number of samples for the second display type
        numObservations2=find(strcmp(labels1,'3'));
        
        % randomly order indices for each condition
        idx1 = randperm(length(numObservations1));
        idx2 = randperm(length(numObservations2));
        
        % gets 1 trials for each condition that will be the test set
        idx_test1=numObservations1(idx1(1));
        idx_test2=numObservations2(idx2(1));
        
        % gets 6 trials for each condition that will be the validation set
        % during training
        idx_validation1=numObservations1(idx1(2:7));
        idx_validation2=numObservations2(idx2(2:7));
        
        % gets the rest of the trials for training set
        idx_train1=numObservations1(idx1(8:end));
        idx_train2=numObservations2(idx2(8:end));

        % creates sequence and labels array acoording to the training sets -
        % as input to the classifier (combines both display types
        sequencesTrain = [sequences(idx_train1) sequences(idx_train2)];
        labelsTrain = [labels(idx_train1) labels(idx_train2)];

        % creates a sequence and labels array for validation during
        % training
        sequencesValidation = [sequences(idx_validation1) sequences(idx_validation2)];
        labelsValidation = [labels(idx_validation1) labels(idx_validation2)];


        % creates a sequence and labels array for test set
        sequencesTest = [sequences(idx_test1) sequences(idx_test2)];
        labelsTest = [labels(idx_test1) labels(idx_test2)];

        % gets the number of features and classes for building the CNN
        % model layers
        numFeatures = size(sequencesTrain{1},1);
        numClasses = numel(categories(labelsTrain));

        % Builds the layers of the classification model
        layers = [
        sequenceInputLayer(numFeatures,'Name','sequence')
        bilstmLayer(2000,'OutputMode','last','Name','bilstm')
        dropoutLayer(0.5,'Name','drop')
        fullyConnectedLayer(numClasses,'Name','fc')
        softmaxLayer('Name','softmax')
        classificationLayer('Name','classification')];
        miniBatchSize = 16; 
        numObservations = numel(sequencesTrain);
        numIterationsPerEpoch = floor(numObservations / miniBatchSize);
        
        % specify training options for the model and adds the validation
        % set to the training
        options = trainingOptions('adam', ...
        'MiniBatchSize',miniBatchSize, ...
        'InitialLearnRate',1e-4, ...
        'GradientThreshold',2, ...
        'Shuffle','every-epoch', ...
        'ValidationData',{sequencesValidation',labelsValidation'}, ...
        'ValidationFrequency',numIterationsPerEpoch, ...
        'Plots','none', ...
        'Verbose',false);
    
        % trains the network on training data
        [netLSTM,info] = trainNetwork(sequencesTrain',labelsTrain',layers,options);

        % create a layer graph of the googlenet network
        cnnLayers = layerGraph(netCNN);

        % remove the input layer ("Data") and the layers after the pooling
        % layer used for the activations
        layerNames = ["data" "pool5-drop_7x7_s1" "loss3-classifier" "prob" "output"];
        cnnLayers = removeLayers(cnnLayers,layerNames);

        % add a sequence input layer
        inputSize = netCNN.Layers(1).InputSize(1:2);
        averageImage = netCNN.Layers(1).AverageImage;
        inputLayer = sequenceInputLayer([inputSize 3], ...
        'Normalization','zerocenter', ...
        'Mean',averageImage, ...
        'Name','input');

        % add the sequence input layer to the layer graph
        layers = [
        inputLayer
        sequenceFoldingLayer('Name','fold')];
        lgraph = addLayers(cnnLayers,layers);
        lgraph = connectLayers(lgraph,"fold/out","conv1-7x7_s2");

        % add LSTM layers (remove the LSTM input layer first)
        lstmLayers = netLSTM.Layers;
        lstmLayers(1) = [];
        layers = [
        sequenceUnfoldingLayer('Name','unfold')
        flattenLayer('Name','flatten')
        lstmLayers];
        lgraph = addLayers(lgraph,layers);
        lgraph = connectLayers(lgraph,"pool5-7x7_s1","unfold/in");
        lgraph = connectLayers(lgraph,"fold/miniBatchSize","unfold/miniBatchSize");
        
        % assemble the CNN as a combination of the GoogleNet and the LSTM
        net = assembleNetwork(lgraph)
        
        % classify the test set and gets the prediction of the network for
        % each trial in the test set
        YPred1 = classify(net,sequencesTest(1));
        YPred2 = classify(net,sequencesTest(2));

        % calculates the accuracy of the classifier in the current
        % iteration by checking whether prediction match actual label
        iter_accuracy=(double(YPred1==labelsTest(1))+double(YPred2==labelsTest(2)))/2;
        
        % adds to the overall accuracy 
        accuracy=accuracy+iter_accuracy;
        
        % deletes the model for this iteration
        clear net;
    end
    
    % saves the result (if "real data then is_shuffle = 0)
    save(fullfile('CNN_Results',['group_' num2str(group) '_subj_' num2str(subj_ix) '_shuffle' num2str(shuffle_num) '_accuracy_' num2str(accuracy/num_of_iterations) '.mat']),'accuracy');
end