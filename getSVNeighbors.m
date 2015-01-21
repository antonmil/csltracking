function nb = getSVNeighbors(ISall,S)
% get neighbors for a particular supervoxel

% superpixels
sp=find(ISall(:,1)==S);

% in which frames does S exist?

