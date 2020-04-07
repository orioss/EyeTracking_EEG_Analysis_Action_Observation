function [clusters,hip]=ClusterAnalysisOnLocalizerERSP(ersp_data,ersp_data2,ttest_type)
% ClusterAnalysisOnLocalizerERSP performs clustering analysis to calculate
% signficant features of the signal (frequency and time) with significant
% supression.
%
%% Syntax
% [clusters,hip]=ClusterAnalysisOnLocalizerERSP(ersp_data,ersp_data2,ttest_type)
%
%% Description
% ClusterAnalysisOnLocalizerERSP gets ersp maps for each trial, split by
% condition, and the ttest type (paired or not) for calculating 
% times and frequencies with significant supression 
%
% Required Input.
% ersp_data: nx200x200 matrix with time-frequency maps or all n trials forcondition 1.
% ersp_data2: nx200x200 matrix with time-frequency maps or all n trials for condition 2.
% ttest_type: the type of ttest - paired or not, to calculate significance.
%
% Output.
% clusters: indices of clusters that indicate times and frequencies with significant supression
% hip: clusters map for printing

% number of permutations for the clustering analysis
rng(1);
numPerm=100; 

% gets the number of trials.
N = size(ersp_data,1);

%% Clustering on real data
% performs ttest on each frequency and time according to find significant supression accoridng to the given ttest
if (ttest_type==1)
    [h,p,~, stats] = ttest(ersp_data,ersp_data2,'alpha',0.1,'tail','left'); 
else
    [h,p,~, stats] = ttest2(ersp_data,ersp_data2,'alpha',0.1,'tail','left');     
end

% find real clusters in the ttest map
real_CC = bwconncomp(squeeze(h));
for c = 1:real_CC.NumObjects
    real_ClusterTvalues(c) = sum(stats.tstat(real_CC.PixelIdxList{c}));
end

% calculate permutation statistics
maxClusterTvalues=zeros(numPerm,1);
for p = 1:numPerm

        
    % shuffles the data
    AllData=[ersp_data;ersp_data2];
    dataShuffled=AllData(randperm(size(AllData,1)),:);
    
        
    % performs ttest on the shuffled data
    if (ttest_type==1)
        [hs,ps,~, statss] = ttest(dataShuffled(1:N,:,:),dataShuffled(N+1:end,:,:),'alpha',0.1,'tail','left');
    else
        [hs,ps,~, statss] = ttest2(dataShuffled(1:N,:,:),dataShuffled(N+1:end,:,:),'alpha',0.1,'tail','left');
    end

    % finds the best cluster in shuffled data
    CCs = bwconncomp(squeeze(hs));
    if CCs.NumObjects>1
        for cs = 1:CCs.NumObjects
            cluster(cs) = sum(statss.tstat(CCs.PixelIdxList{cs}));
        end
        maxCluster = find(abs(cluster) == max(abs(cluster)));
        maxClusterSize = cluster(maxCluster);
    else
        maxClusterSize=0;
    end
    
    % adds the best cluster in the shuffled data to the shuffle array to
    % compare to real data
    if (isempty(maxClusterSize))
        maxClusterTvalues(p)= 0;
    else
        maxClusterTvalues(p)= maxClusterSize;
    end
        
    clear cluster
end

% calculate p-value for each real cluster
for clust=1:real_CC.NumObjects
    pval(clust) = size(find(maxClusterTvalues > real_ClusterTvalues(clust)),1)/numPerm;
end

% prepares significant clusters map for printing and extract their indices for classification analysis 
hip=squeeze(h);
if (real_CC.NumObjects==0)
    clusters={};
else
    sigCluster=pval>0.9;
    num_of_sig_clusters=1;
    if (max(sigCluster)==0)
        clusters={};
    else
        for ind=1:length(sigCluster)
            if sigCluster(ind)
                hip(real_CC.PixelIdxList{ind})=num_of_sig_clusters+2;
                [I1,I2]=ind2sub(size(hip),real_CC.PixelIdxList{ind});
                clusters{num_of_sig_clusters}=[I1 I2];
                num_of_sig_clusters=num_of_sig_clusters+1;
            end
        end
    end
end
end