function [fixed_sequences,fixed_labels1,fixed_labels2,fixed_original_trials] = RemoveTrialsWithNoData(sequences, labels1,labels2,original_trials)
% RemoveTrialsWithNoData Removes trials from the data and label input that
% don't have enough data for classification
%
%% Syntax
% [fixed_sequences,fixed_labels1,fixed_labels2,fixed_original_trials] = RemoveTrialsWithNoData(sequences, labels1,labels2,original_trials)
%
%% Description
% RemoveTrialsWithNoData creates new data and label structure without
% trials that do not have enough data for classification. 
%

% gets the amount of data in the sequence
length_array = cell2mat(cellfun(@(c) size(c,2), sequences, 'UniformOutput', false));

% sets minimal amount of data needed to make any classification
min_threshold_for_data = mode(length_array);

% creates a "fixed" sequence and label arrays without the trials that don't
% have enough data
fixed_counter=1;
for i=1:length(sequences)
    if (size(sequences{i},2)<min_threshold_for_data)
        continue;
    else
        fix_seq = sequences{i};
        fix_seq = fix_seq(:,1:min_threshold_for_data);
        fixed_sequences{fixed_counter} = fix_seq;
        fixed_labels1(fixed_counter) = labels1(i);
        fixed_labels2(fixed_counter) = labels2(i);
        fixed_original_trials(fixed_counter)=original_trials(i);
        fixed_counter=fixed_counter+1;
    end
end