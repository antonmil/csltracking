function [flowinfo, iminfo, sp_labels, ISall, IMIND, seqinfo, SPPerFrame] = ...
    precompAux(scenario,sceneInfo,K,frames)
% precomp auxiliary data
%%%%%% superpixels

F=length(frames);
if K>0
    spfile=sprintf('sp-K%d.mat',K);
    try
        load(fullfile(sceneInfo.imgFolder,spfile));
        sp_labels=sp_labels(:,:,frames);
    catch err
        error(err.identifier,'oops, superpixels!');
    end
else
    if ~exist('../../projects/segtracking/tmp/selsear','dir'), mkdir('../../projects/segtracking/tmp/selsear'); end
    spfile=sprintf('../../projects/segtracking/tmp/selsear/spselseach-%04d-K%d.mat',scenario,K);
    fprintf('selsearch');
    try 
        load(spfile)
        sp_labels=sp_labels(:,:,frames);
    catch
        selsearch;
        save(spfile,'sp_labels','-v7.3');
    end
end

% sp_labels=sp_labels+1;



%%%%%% optic flow
% clear flowinfo iminfo
if ~exist('../../projects/segtracking/tmp/seqinfo/','dir'), mkdir('../../projects/segtracking/tmp/seqinfo'); end
fifile=sprintf('../../projects/segtracking/tmp/seqinfo/flowinfo-%04d-%d-%d.mat',scenario,frames(1),frames(end));
fprintf('flow');
try load(fifile)
catch
    for t=2:F
        fprintf('.');
        flow=load(getFlowFile(sceneInfo,t));
        flowinfo(t).flow=flow.flow;
    end
    save(fifile,'flowinfo');
end

% all images in one array
fprintf('\nimage info');
iifile=sprintf('../../projects/segtracking/tmp/seqinfo/iminfo-%04d-%d-%d.mat',scenario,frames(1),frames(end));
try load(iifile)
catch
    for t=1:F
        fprintf('.');
        im=getFrame(sceneInfo,t);
        iminfo(t).img=im;
    end
    save(iifile,'iminfo');
end

fprintf('\n');

%%%%% Iunsp
% independent superpixels for each frame
Iunsplfile=sprintf('../../projects/segtracking/tmp/Iunsp/%04d-%d-%d-K%d.mat',scenario,frames(1),frames(end),K);
fprintf('Iunsp');
try load(Iunsplfile)
catch
    Iunsp=unspliceSeg(sp_labels);
    %     fprintf('!!!!! UNSPLICE\n');
    %     Iunsp=sp_labels;
    save(Iunsplfile,'Iunsp');
end

%%%%% ISall
% all info about superpixel in one single matrix
fprintf('\nISall');
ISallfile=sprintf('../../projects/segtracking/tmp/ISall/%04d-%d-%d-K%d.mat',scenario,frames(1),frames(end),K);
try load(ISallfile)
catch
    [ISall,IMIND]=combineAllIndices(sp_labels,Iunsp, sceneInfo, flowinfo,iminfo);
    save(ISallfile,'ISall','IMIND');
end
fprintf('\n');

%%%%%%%% concat sequence info into struct array
clear seqinfo SPPerFrame
sifile=sprintf('../../projects/segtracking/tmp/seqinfo/%04d-%d-%d-K%d.mat',scenario,frames(1),frames(end),K);
fprintf('seqinfo');
try load(sifile)
catch
    for t=1:F
        fprintf('.');
        im=getFrame(sceneInfo,t);
        thisF=sp_labels(:,:,t);
        
        % vector of superpixels for each frame
        seqinfo(t).segF=unique(thisF(:));
%         seqinfo(t).nSeg=getNeighboringSuperpixels(sp_labels(:,:,t)+1);

        % vector of neighbors for each SP
        seqinfo(t).nSegUnsp = getNeighboringSuperpixels(Iunsp(:,:,t)+1);
        
        % weights for neighrbos
        seqinfo(t).nWeights = getNeighborWeights(seqinfo(t).nSegUnsp,Iunsp(:,:,t)+1,im);
        
        % how many superpixels in each frame?
        SPPerFrame(t)=numel(unique(sp_labels(:,:,t)));
    end
    save(sifile,'seqinfo','SPPerFrame', '-v7.3');
end
fprintf('\n');
