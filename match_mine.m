function [num, match, time, cpu_time, num2, match2, time2, cpu_time2] = match_mine(des1, des2, Lmax, br, n, lf_sz, n_match)

if ischar(des1)
    [im1, des1, loc1] = sift(des1);
    [im2, des2, loc2] = sift(des2);
end
tic;
t = cputime;
trees = random_hieararchical_tree(des2,br,lf_sz,n);
match = r_search(des1,des2,trees,Lmax,br,n_match);
cpu_time = (cputime - t)/n;
time = toc/n;

num = sum(match(1,:)>0);
fprintf('Found %d matches (hierarchical search).\n', num);

%%linear search
tic;
ter = cputime;
distRatio = 0.6;

% For each descriptor in the first image, select its match to second image.
des2t = des2';  % Precompute matrix transpose
match2 = zeros(1,size(des1,1));
for i = 1 : size(des1,1)
    dotprods = des1(i,:) * des2t;        % Computes vector of dot products
    [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results
    
    % Check if nearest neighbor has angle less than distRatio times 2nd.
    if (vals(1) < distRatio * vals(2))
        match2(i) = indx(1);
    else
        match2(i) = 0;
    end
end
cpu_time2 = cputime-ter;
time2 = toc;

%fprintf('Perc. correct matches (hierarchical search).\n', num3);
num2 = sum(match2 > 0);
fprintf('Found %d matches (linear search).\n', num2);

%%%%%%%%%visualization%%%%%%%%%
% % Create a new image showing the two images side by side.
% im3 = appendimages(im1,im2);
%
% % Show a figure with lines joining the accepted matches.
% for j = 1:numel(match(:,1))
% figure('Position', [100 100 size(im3,2) size(im3,1)]);
% colormap('gray');
% imagesc(im3);
% hold on;
% cols1 = size(im1,2);
% for i = 1: numel(match(1,:))
%     if (match(j,i) > 0)
%         line([loc1(i,2) loc2(match(j,i),2)+cols1], ...
%             [loc1(i,1) loc2(match(j,i),1)], 'Color', 'c');
%     end
% end
% hold off;
end



