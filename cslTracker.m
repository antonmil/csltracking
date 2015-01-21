%% Multi-Object Tracking via Constrained Sequential Labeling
% S. Chen, A. Fern and S. Todorovic, CVPR 2014
%
% Implementation by Anton Milan
%
%
addpath(genpath('./external'))

global scenario sceneInfo gtInfo opt detections

scenario=42;
frames=1:20;
K=800;

F=length(frames);

% set random seed for deterministic results
rng(1); 

% get info about sequence
sceneInfo=getSceneInfo(scenario);
allF=length(sceneInfo.frameNums);
sceneInfo.frameNums=sceneInfo.frameNums(frames);

% now parse detection for specified frames
[detections, nPoints]=parseDetections(sceneInfo,frames);
alldpoints=createAllDetPoints(detections);

% remove unnecessary frames from GT
gtInfo=cropFramesFromGT(sceneInfo,gtInfo,frames,opt);


% get mid-level features
% TODO!
%% all ims, all flows
fprintf('Precomputing helper structures\n');
[flowinfo, iminfo, sp_labels, ISall, IMIND, seqinfo, SPPerFrame] = ...
    precompAux(scenario,sceneInfo,K,frames);
% work with 1-based
sp_labels=sp_labels+1;
ISall(:,1)=ISall(:,1)+1;


% first frame labels
% TODO

%% perform foreground background segmentation
% TODO: This needs to be adjusted to match the paper
detSeg;
svmSeg;

% parameters
w = ones(1,6);
w = w ./ norm(w);

%% supervoxel classification

% how many supervoxels?
nSV = numel(unique(sp_labels(:)));

SVs = zeros(nSV, 3); % supervoxel array [FG, tstart, tend]

% foreground supervoxels
fgThreshold=.5;

scnt=0;
for n=unique(sp_labels(:))'
    scnt=scnt+1;
    sp=find(ISall(:,1)==n);
    meanQ=mean(Q(sp));
    SVs(scnt,1)=double(meanQ>=fgThreshold);
    SVs(scnt,2)=ISall(sp(1),3);
    SVs(scnt,3)=ISall(sp(end),3);
end

fprintf('Total: %d supervoxels (%d foreground, %d background)\n', ...
    nSV, numel(SVfg), numel(SVbg));

% number of labels
k=2; % TODO! FIX

% current labeling
% a boolean matrix, 
%   where (i,j) = true if supervoxel i can attain label j
L = true(nSV,k);

% don't care about background
L(SVbg,:)=false;

AL = getActiveFeatures(SVs,L);
fprintf('Active Features: %d\n',numel(AL));