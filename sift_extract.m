for i = 1:6
    [im{i}, des{i}, loc{i}] = sift(strcat('cimg',num2str(i),'.pgm'));
end
save leuven_data.mat im des loc;