function [tree] = random_hieararchical_tree(features, B, size, n)
% features = features we want to organize (one row per descriptor)
% B = branching factor (max number of childs per node)
% size = max leaf size of our trees
% n = number of random trees we want to build (must be >=1)
tree = {n};
for i = 0:n-1
    tree{i+1} = clustering(features ,B , size);
    tree{i+1} = cat(1,[ones(1,2) 0],tree{i+1});       %add root
    tree{i+1}(:,2) = tree{i+1}(:,2) + ones(numel(tree{i+1}(:,1)),1);
end
end
