% view supervoxels
alphablend=.5;

[imH,imW]=size(tudgt.sp_label_GT(:,:,1));
npix=imH*imW;


for t=1:20
    im = getFrame(sceneInfo,t);
    imcol = im;

    thisF=sp_labels(:,:,t);
    
    [u,v]=find(thisF==13);
    imind=sub2ind(size(thisF),u,v);
    
    col=[1 0 0];
    imcol(imind)=col(1);
    imcol(imind+npix)=col(2);
    imcol(imind+2*npix)=col(3);
    imshow(imcol);
    
    pause
end