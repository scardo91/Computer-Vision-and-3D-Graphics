function print_match(im1,im2,loc1,loc2,match)

% Create a new image showing the two images side by side.
im3 = appendimages(im1,im2);

% Show a figure with lines joining the accepted matches.
for j = 1:numel(match(:,1))
    figure('Position', [100 100 size(im3,2) size(im3,1)]);
    colormap('gray');
    imagesc(im3);
    hold on;
    cols1 = size(im1,2);
    for i = 1: numel(match(1,:))
        if (match(j,i) > 0)
            line([loc1(i,2) loc2(match(j,i),2)+cols1], ...
                [loc1(i,1) loc2(match(j,i),1)], 'Color', 'c');
        end
    end
end