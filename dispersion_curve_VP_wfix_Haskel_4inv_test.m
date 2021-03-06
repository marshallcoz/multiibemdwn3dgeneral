function [vp,f1,ikmax]=dispersion_curve_VP_wfix_Haskel_4inv_test(para,wi)

% funcion que busqua a establecer las curvas de dispersion de velocidad de
% fase
% por un medio estratificado sobre un semi espacio
% se busca por cada w(wfix)
% los ceros de la fase de un sub-determinante de la matriz de haskel
% en un gran intervalo busquando un cambio de signo
% metodo mas rapido que con la matriz global
% no hay falso ceros
%
% diferencia con dispersion_curve_wfix_Haskel_4inv:
% no mas las velocidad de fase

para.sub= para.reg(1).sub;
pol     = para.pol;

beta    = zeros(para.nsubmed,1);
alpha   = zeros(para.nsubmed,1);
for ms=1:para.nsubmed
    para.sub(ms).C(6,6)  = para.sub(ms).rho*para.sub(ms).bet^2;
    beta(ms)  = para.sub(ms).bet;
    alpha(ms) = para.sub(ms).alpha;
end

vmin    = min(beta);
vmax    = max(beta);

vmax    = (1-1e-8)*vmax;

wi      = unique(wi);
wmax    = max(wi);
nf      = length(wi);
%&precalculo lista indices
if para.pol==2
    jj=ind4subdetab(para.nsubmed);
    para.jj=jj;
end
[k2c,w0c]   = dispersion_curve_k_critik_Haskel(para,wmax,vmax,1e3);
nmode       = length(k2c);
k01         = zeros(nf,nmode);
time=zeros(nf,2);
for j=1:10:nf
    tStart = tic; 
    % parfor j=1:nf
    wj          = wi(j);
    if wj==0
        k20     = 0;
        %automaticamente hecho porque k20=0
        % nmodej  = 1;
        % k01(j,:)= [flipud(k20);zeros(nmode-nmodej,1)].';
        continue;
    end
    nmodej      = sum(w0c<=wj);
    DWN0        = struct('omegac',wj);
    
    passtest    = 1;
    %limites en k dados por asintotas
    ki          = wj/vmax;
    kf          = wj/vmin*1.3;
    
    nk1         = 5;
    k20(k20<ki)=[];
    if length(k20)>1
        nk5         = round((k20(2)-ki)*wj/(ki^2*1e-3)/10);
        nk1         = min(nk1,nk5);
    end
    
    nk          = nmodej*nk1;%min(floor(max(dk0/dwi*1e3,nmodej*3)),5e3);
    nk0         = nk;
    
    while passtest==1
        if length(k20)>1
            newk2   = zeros(1,(1+length(k20))*nk1);
            i=0;
            newk2(1:nk1)=linspace(ki,k20(i+1),nk1);
            
            for i=1:length(k20)-1
                newk2((1:nk1)+i*nk1)=linspace(k20(i),k20(i+1),nk1);
            end
            i=length(k20);
            newk2((1:nk1)+i*nk1)=linspace(k20(i),kf,nk1);
            DWN0.k2 	= unique(newk2);
        else
            DWN0.k2 	= linspace(ki,kf,nk);
        end
        nk      = length(DWN0.k2);
        indk    = 1:(nk-1);
        
        if  pol==1
            tmp=mode_Love(para,DWN0);
        else
            tmp=mode_Rayleigh_2(para,DWN0);
        end
        tmp(tmp==inf)=0;
        tmp1    = angle(tmp)-pi/2;
        indd1   = logical(tmp1(1:(nk-1)).*tmp1(2:nk)<=0);
        indd1   = indk(indd1);
        nind    = length(indd1);
        if nind<nmodej
            nk1     = nk1*5;
            nk    	= nmodej*nk1;
            %             nk      = nk*10;
            if nk/nk0>200
                %                 k20=[k2c(nmodej);k20];
                passtest=0;
            end
        elseif nind>nmodej
            %k20=k20(1:nmodej);
            passtest=0;
            disp('pb')
        else
            nk1     = max(round(150/nmodej),10);
            nk2     = nk1*nmodej;
            indk1   = 1:(nk2-1);
            
%             while wj*(1/DWN0.k2(end-1)-1/DWN0.k2(end))>1e-3
                newk2=zeros(1,nk2);
                for i=1:nmodej
                    newk2((1:nk1)+(i-1)*nk1)=linspace(DWN0.k2(indd1(i)),DWN0.k2(indd1(i)+1),nk1);
                end
                DWN0.k2=newk2;
                if  pol==1
                    tmp=mode_Love(para,DWN0);
                else
                    tmp=mode_Rayleigh_2(para,DWN0);
                end
                tmp(tmp==inf)=0;
                tmp1    = angle(tmp)-pi/2;
                indd1   = logical(tmp1(1:(nk2-1)).*tmp1(2:nk2)<=0);
                indd1   = indk1(indd1);
%             end
            
            k20   	= cherche_zero(DWN0.k2,real(tmp).',indd1).';
            passtest=0;
        end
    end

    k01(j,:)= [flipud(k20);zeros(nmode-nmodej,1)].';
 time(j,1)=toc(tStart);
      time(j,2)=nk2  ;
      
    for jj=j-(1:9)%(9:-1:1)%
        tStart = tic; 
        % parfor jj=1:nf
        wj          = wi(jj);

        nmodej      = sum(w0c<=wj);
        DWN0        = struct('omegac',wj);
        
        passtest    = 1;
        %limites en k dados por asintotas
        ki          = wj/vmax;
        kf          = wj/vmin*1.3;
        
        nk1         = 5;
        k20(k20<ki)=[];
        if length(k20)>1
            nk5         = round((k20(2)-ki)*wj/(ki^2*1e-3)/10);
            nk1         = min(nk1,nk5);
        end
        
        nk          = nmodej*nk1;%min(floor(max(dk0/dwi*1e3,nmodej*3)),5e3);
        nk0         = nk;
        
        while passtest==1
            if length(k20)>1
                newk2   = zeros(1,(1+length(k20))*nk1);
                i=0;
                newk2(1:nk1)=linspace(ki,k20(i+1),nk1);
                
                for i=1:length(k20)-1
                    newk2((1:nk1)+i*nk1)=linspace(k20(i),k20(i+1),nk1);
                end
                i=length(k20);
                newk2((1:nk1)+i*nk1)=linspace(k20(i),kf,nk1);
                DWN0.k2 	= unique(newk2);
            else
                DWN0.k2 	= linspace(ki,kf,nk);
            end
            nk      = length(DWN0.k2);
            indk    = 1:(nk-1);
            
            if  pol==1
                tmp=mode_Love(para,DWN0);
            else
                tmp=mode_Rayleigh_2(para,DWN0);
            end
            tmp(tmp==inf)=0;
            tmp1    = angle(tmp)-pi/2;
            indd1   = logical(tmp1(1:(nk-1)).*tmp1(2:nk)<=0);
            indd1   = indk(indd1);
            nind    = length(indd1);
            if nind<nmodej
                nk1     = nk1*5;
                nk    	= nmodej*nk1;
                %             nk      = nk*10;
                if nk/nk0>200
                    %                 k20=[k2c(nmodej);k20];
                    passtest=0;
                end
            elseif nind>nmodej
                %k20=k20(1:nmodej);
                passtest=0;
                disp('pb')
            else
                nk1     = max(round(150/nmodej),10);
                nk2     = nk1*nmodej;
                indk1   = 1:(nk2-1);
                
%                 while wj*(1/DWN0.k2(end-1)-1/DWN0.k2(end))>1e-3
                    newk2=zeros(1,nk2);
                    for i=1:nmodej
                        newk2((1:nk1)+(i-1)*nk1)=linspace(DWN0.k2(indd1(i)),DWN0.k2(indd1(i)+1),nk1);
                    end
                    DWN0.k2=newk2;
                    if  pol==1
                        tmp=mode_Love(para,DWN0);
                    else
                        tmp=mode_Rayleigh_2(para,DWN0);
                    end
                    tmp(tmp==inf)=0;
                    tmp1    = angle(tmp)-pi/2;
                    indd1   = logical(tmp1(1:(nk2-1)).*tmp1(2:nk2)<=0);
                    indd1   = indk1(indd1);
%                 end
                 
                k20   	= cherche_zero(DWN0.k2,real(tmp).',indd1).';
                passtest=0;
            end
            
        end
        
        k01(jj,:)= [flipud(k20);zeros(nmode-nmodej,1)].';
        
      time(jj,1)=toc(tStart);
      time(jj,2)=nk2  ;
    end
end
figure;plot(time(:,1))
figure;plot(time(:,2))
sum(time(:,1))
vp      = zeros(nmode,nf);
f1      = zeros(nmode,nf);
ikmax   = zeros(nmode,1);

figure(205);hold on;

for j=1:nmode
    indi=find(k01(:,j)~=0,1,'first');
    indf=find(k01(:,j)~=0,1,'last');
    
    kj              = k01(indi:indf,j);
    wj              = wi(indi:indf).';
    plot(kj,wj,'.r')
    
    ikmax(j)        = length(kj);
    vp(j,1:ikmax(j))= wj./kj;
    f1(j,1:ikmax(j))= wj/2/pi;
end

wj=linspace(0,max(wi),3);
for j=1:para.nsubmed
    plot(wj/para.sub(j).bet,wj,'r')
end

xlabel('k');ylabel('w');

figure(206);hold on;
for j=1:nmode
    plot(f1(j,1:ikmax(j)),vp(j,1:ikmax(j)),'r')
end
xlabel('f');ylabel('vp');