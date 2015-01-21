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


% first frame labels
% TODO

%% perform foreground background segmentation
detSeg;
svmSeg;

% parameters
w = ones(1,6);
w = w ./ norm(w);