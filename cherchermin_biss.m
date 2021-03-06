function w0=cherchermin_biss(y,para,DWN,np)
%para buscar los puntos cerca de zero que no cambian de signo
%primero se busca los cambios de signo de la derivada que sean - -> +
%despues se refina la buscqueda alrededor de estos puntos y se verifica que
%la extrapolacion de la parte antes de la curva cambie de signo
dy  =diff(y);
n   =length(dy);
indd1 =find((dy(1:n-1).*dy(2:n)<=0));
indd1=indd1(dy(indd1)<0);
DWN0=DWN;
n0=length(indd1);
dw=DWN.omegac(2)-DWN.omegac(1);
if n0==0
    n0=2;
    indd1=[1 n];
    DWN0.omegac(1)=DWN0.omegac(1)-dw;
    DWN0.omegac(end)=DWN0.omegac(end)+dw;
end
w0=zeros(n0,1);

dw0=1e-3;%precision de la recherche

for i=n0:-1:1
    ind=indd1(i)+1;
    wi          = DWN0.omegac(max(ind-1,1));
    wf          = DWN0.omegac(min(ind+1,length(DWN0.omegac)));
    
    [sign0,sign1,det1,para,DWN]=checkchgmtsign_vec(wi,wf,para,DWN,n)

    DWN.omegac	= linspace(wi,wf,np);
    fj          = DWN.omegac/2/pi;
    paratmp     = attenuation(para,fj);
    paratmp.fj  = fj;
    DWN.omegac	= 2*pi*fj;
    
    if  para.pol==1
        DWN     = calcul_A_DWN_SH_Ncapas_HS(paratmp,DWN);
    else
        DWN     = calcul_A_DWN_PSV_Ncapas_HS(paratmp,DWN);
    end
    tmp     = zeros(np,1);
    for k=1:np
        tmp(k)=abs(det(DWN.A_DWN(:,:,k)));
    end
    %     %check if 2 min are present in the same interval
    %     dy  =diff(y);
    %     n   =length(dy);
    %     indd =find((dy(1:n-1).*dy(2:n)<=0));
    %     indd=indd(dy(indd)<0);
    
    [~,ind1]=min(tmp);%figure;plot(DWN.omegac,tmp)
    
    ind1=ind1-1;%a veces el min esta sobre la pendiente positiva
    if ind1==0
        ind1=1;%a dichotomier // presence de 2 min
        nextw0=1;
    else
        if ind1==1
            nextw0 = interp1(DWN.omegac(3:6),tmp(3:6),DWN.omegac(3)-5*dw/np,'pchip','extrap');
        else
            nextw0 = interp1(DWN.omegac(1:ind1),tmp(1:ind1),DWN.omegac(ind1)+6*dw/np,'pchip','extrap');
        end
    end
    if sign(nextw0)==-1
        w0(i)=DWN.omegac(ind1);
    else
        w0(i)=[];
    end
    
end