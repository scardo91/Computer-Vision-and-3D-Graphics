function [part_tree_idx] = clustering(feat, branch, leaf_size, idx)
% feat = features we want to organize (one row per descriptor)
% branch = branching factor (max number of childs per node)
% leaf_size = max size of the leafs
% idx = indexes of the features we are considering in our procedure

if leaf_size < branch
    error('Error: leaf_size must be greater than (or equal to) the branching factor')
end

if nargin<4     %if I don't specify idx assume all features to be clustered
    idx(:,1) = 1:length(feat(:,1));
end

K = length(idx);

if K <= leaf_size
    part_tree_idx(:,1) = idx;
    part_tree_idx(1,3) = K;
    
else
    centers = idx(randperm(K,branch));  %indexes of the random centroids
    [~, ind] = pdist2(feat(centers,:),feat(idx,:),'euclidean','Smallest',1); %clusters features
    part_tree_idx(1:branch,1) = centers; %add centers to partial tree
    
    for i = 1:branch
        temp = clustering(feat,branch,leaf_size,idx(ind==i));
        
%         if ~isempty(temp)  %removes empty leafs (no more needed)
            
            insert = max([0,find(part_tree_idx(:,1), 1,'last')]);
            offset = numel(part_tree_idx(:,1));
            part_tree_idx(1+insert:insert + numel(temp(:,1)),1:numel(temp(1,:))) =  temp;
            
            if offset > branch && i ~= 1        %%%to adjust merging for i ~=1
                part_tree_idx(1+insert:insert + numel(temp(:,1)),2) = ...
                    part_tree_idx(1+insert:insert + numel(temp(:,1)),2) + offset;
            end
            
            if i == 1  %new version merge partial tree
                part_tree_idx(i,2) = i;
                part_tree_idx(:,2) = part_tree_idx(:,2) + offset;
            else
                part_tree_idx(i,2) = numel(part_tree_idx(:,1)) - numel(temp(:,1)) +1;
            end
%        end
    end
end
end