function [k] = r_search(Q, ft, T, Lmax, br,ret)
%Q = descriptors we want to match (1 row per feature)
%ft = descriptors we want to look for a match (1 row per feature)
%T = trees built with random_hierarchical_tree.m function
%Lmax = max number of inspections
%br = branching factor;
%ret = number of neighbours we want to return

distRatio = 0.6;
k_len = min(Lmax,ret)+1;
k= zeros(k_len,numel(Q(:,1)));    %+1 to avoid problems in checking for wrong matches when ret or Lmax = 1
n = numel(T);


for m = 1:numel(Q(:,1))
    %     %%%initialization%%%%%%
    %         PQ = PriorityQueue();     % mat_pq
    %         R = PriorityQueue();      % mat_pq
    
    %     %%%%initialization%%%%%%
    %          R = pq_create(numel(ft(:,1)));   % cpp_pq
    %          PQ = pq_create((n+1)*1000000);   % cpp_pq
    
    %%%%initialization%%%%%%
    R = zeros(Lmax*2,2);
    PQ = zeros(n*round(log10(numel(Q(:,1)))/log10(br)),3);
    pq_l = 0;
    L = 0;
    
    %%%%first traversing%%%%%
    for w = 1:n
        TraverseTree(T{w},0);
    end
    
    %     %%restart tree traversing%%%%%     %uncomment all while for mat_pq
    %         while PQ.size() ~= 0 && R.size()<Lmax
    %             w = PQ.pop()-1;
    %             TraverseTree(T{w},id);
    %         end
    
    %     %%%restart tree traversing%%%%%     %uncomment all while for cpp_pq
    %         while pq_size(R)<Lmax && pq_size(PQ) ~= 0
    %             aux = num2str(pq_pop(PQ));
    %             w = str2num(aux(1));
    %             id = str2num(aux(2:end));
    %             TraverseTree(T{w},id);
    %         end
    
    %%%restart tree traversing%%%%%
    if L < Lmax && pq_l ~= 0
        sz = 0;
        [~, sort_idx, ~]  = unique(PQ(1:pq_l,3)); %sorts and removes duplicate (simulate a pq)
        aux = pq_l;
        while L < Lmax && aux ~= 0
            w = PQ(sort_idx(1+sz),2);
            id = PQ(sort_idx(1+sz),1);
            TraverseTree(T{w},id-1);
            sz = sz+1;
            aux = aux-1;
        end
    end
    
    %     %%%%copy results%%%%%
    %      r_idx = pq_size(R);   % cpp_pq
    %      r_idx = R.size();       % mat_pq
    %      for s = 1:min([k_len,r_idx])  % mat_pq && % cpp_pq
    %             k(s,m) = R.pop();     % mat_pq
    %             k(s,m) = pq_pop(R);   % cpp_pq
    %      end    % mat_pq && % cpp_pq
    
    %%%%%copy results%%%%%
    [~, r_idx, ~] = unique(single(R(1:L,2))); %sorts and removes duplicate (simulate a pq)
    k(1:min(k_len,numel(r_idx)),m) = R(r_idx(1:min(k_len,numel(r_idx))),1); %copy results
    
    %%%%remove wrong matches
    if numel(r_idx) > 1 || r_idx > 1        %second statement for mat_pq && cpp_pq
        des2t = ft(k(1:2,m),:)';
        dotp = Q(m,:) * des2t;
        [v,~] = sort(acos(dotp));
        if (v(1) >= distRatio * v(2)) || k(1,m) == k(2,m) %if we find 2 equals matches assume wrong(unique function may fail due to sqdist2)
            k(:,m) = zeros(1,k_len);
        end
    else %i've compared only one node-->not enough
        k(:,m) = zeros(1,k_len);
    end
    
    %               pq_delete(PQ);  %cpp_pq
    %               pq_delete(R);   %cpp_pq
end
k = k(1:ret,:);

    function TraverseTree(node,res_idx)          %traverse tree procedure
        first_child_node = node(1+res_idx,2);
        lgth = node(first_child_node,3);
        if lgth ~= 0
            dotprods = ft(node(first_child_node:first_child_node + lgth-1,1),:) * Q(m,:).';
            vals = real(acos(dotprods));  % Take inverse cosine
            %%%%update R%%%%%%%%%%%%
            R(L+1:L+lgth,:) = [node(first_child_node: first_child_node +lgth-1,1),vals];
            L = L+lgth;
            %%%%update R%%%%%%%%%%%%
            %                         for q = 1:lgth    % mat_pq && % cpp_pq
            %                                   R.push(vals(q),node(first_child_node +q-1,1));   % mat_pq
            %                                   pq_push(R,node(first_child_node +q-1,1),-vals(q)); % cpp_pq
            %                         end   % mat_pq && % cpp_pq
        else
            cost = sqdist2(ft(node(first_child_node:first_child_node + br -1, 1),:),Q(m,:));
            [~ , ind] = minkmex(cost,1);
            res_idx = first_child_node + ind -2;        %%nearest neigh. restart index
            temp_pq = (1:br)' + first_child_node -1; %restart indexes
            temp_pq(ind) = [];
            cost(ind) = [];
            %%%%%%%update PQ%%%%%%
            PQ(1+pq_l:pq_l + br-1,:) = [temp_pq,w*ones(br-1,1),cost];
            pq_l = pq_l + br-1;
            %%%%%%%update PQ%%%%%%
            %                       for x = 1:br-1      % mat_pq && % cpp_pq
            %                            PQ.push(cost(x,1),temp_pq(x,1));  % mat_pq
            %                            pq_push(PQ,w*1e6+temp_pq(x,1)-1,-cost(x,1)); % cpp_pq
            %                       end      % mat_pq && % cpp_pq
            TraverseTree(T{w},res_idx);
            return;
        end
    end
end
