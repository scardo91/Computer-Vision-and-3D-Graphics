clear all;
close all;

len = 6;
matches = zeros(1,len);
perc_matches = zeros(1,len);
perc_right_matches = perc_matches;
speedup = zeros(1,len);
% c_speedup = speedup;
load('boat_data.mat');
%%%%parameters%%%%%
L = 2;
n = 4;
branch = 20;
leaf = 30;
ret = 1;
tot1 = 0; tot2 = tot1; ctot1 = 0; ctot2 = 0;

for i = 1:len-1
    [numa, a, t1, ~, numb, b, t2, ~] = match_mine(des{i},des{i+1},L,branch,n,leaf,ret);
    intsect = 0;
    for g = 1:numel(b)
        intsect = intsect + sum(intersect(a(:,g),b(g))>0);
    end
    matches(i) =  intsect/numa;  %%wrt to all returned
    perc_matches(i) = numa/numb;
    perc_right_matches(i) = intsect/numb; %%wrt linear search
    speedup(i) = t2/t1;
    % c_speedup(i) = c2/c1;
    tot1 = tot1+t1;
    tot2 = tot2+t2;
    % ctot1 = ctot1 + c1;
    % ctot2 = ctot2 + c2;
end
%%%overall metrics%%%%%%
m_tot = sum(matches)/(len-1);
pm_tot = sum(perc_matches)/(len-1);
prm_tot = sum(perc_right_matches)/(len-1);
speed_tot = tot2/tot1;
% speed_c_tot = ctot2/ctot1;