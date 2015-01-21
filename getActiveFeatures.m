function AL = getActiveFeatures(SVs,L)
% get set of active supervoxels

AL = [];


% already labeled
labeled = find(sum(L,2)<=1 & SVs(:,1));

% if nothing labeled, done
if isempty(labeled)
    return;
end

% temporally close (all that start before end+1)
latestEndPoint = max(SVs(labeled,3));
tempclose = find(SVs(:,3) <= (latestEndPoint+1) & SVs(:,1));

% remove already labeled
tempclose = setdiff(tempclose,labeled);


% partial labelings
partiallab = find(sum(L,2)>1);

AL = union(tempclose,partiallab);
