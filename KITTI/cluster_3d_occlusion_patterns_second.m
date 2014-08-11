function cluster_3d_occlusion_patterns_second

is_save = 1;

data_file = 'data.mat';
object = load(data_file);
data = object.data;
cid = unique(data.idx);

fprintf('computing similarity scores...\n'); 
grid = data.grid(:,cid);
scores = compute_similarity(grid);

N = size(scores, 1);
M = N*N-N;
s = zeros(M,3); % Make ALL N^2-N similarities
j = 1;
for i = 1:N
    for k = [1:i-1,i+1:N]
        s(j,1) = i;
        s(j,2) = k;
        s(j,3) = scores(i,k);
        j = j+1;
    end
end 

p = (median(s(:,3)) + max(s(:,3))) / 2;

% clustering
fprintf('Start AP clustering\n');
[idx, netsim, dpsim, expref] = apclustermex(s, p);

fprintf('Number of clusters: %d\n', length(unique(idx)));
fprintf('Fitness (net similarity): %f\n', netsim);

p2 = p;
idx2 = zeros(size(data.idx));
for i = 1:numel(idx2)
    index = data.idx(i) == cid;
    idx2(i) = cid(idx(index));
end

% save results
if is_save == 1
    object = load(data_file);
    data = object.data;
    data.idx2 = idx2;
    data.p2 = p2;
    save(data_file, 'data');
end