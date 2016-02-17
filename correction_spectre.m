function spectre=correction_spectre(para,nf,df)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% correction spectre espace et temps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

w   = 2*pi*(df*((1:nf)-1));
%%%%%%%%%%
% tiempo %
%%%%%%%%%%
if para.pulso.tipo==1 % file
    disp('input file')
    [a,b] = uigetfile;
    para.arch_pulso = [b,a];
    dt=(1/(df*2*nf)*(2*nf/(2*nf-2))); % dt simul
    pulsoinput=load(para.arch_pulso);
    dt0=pulsoinput(2,1)-pulsoinput(1,1);
    if dt0>dt
        inputsignal=resample(pulsoinput(:,2),round(dt0/dt),1);
    else
        inputsignal=resample(pulsoinput(:,2),1,round(dt/dt0));
    end
    cr=fft(inputsignal,2*nf+1);
    spectre=cr(1:nf);
elseif para.pulso.tipo==2 %Ricker duraci�n total de la ondicula
    dt=(1/(df*2*nf)*(nf/(nf-1)));
    tp=0.5*para.pulso.a;
    cr=ric(1:(2*nf-2),dt,tp);
    cr=2*(2*nf-2)*ifft(0.5*cr);
    spectre=cr(1:nf);
    spectre(1)=0;

%     sigma=sqrt(80*para.tps_anchoG^2/(8*log(2)));
%     freq1 = 2*pi*(freq0 + df*((1:nf)-1))+0*damp;
%     spectre1=exp(-2*(pi*(freq1-30*df)/(2*pi)*sigma).^2);
%     spectre=spectre+spectre1;
%     toto=5;

    
%     tp=2*para.Ricker_tp;
%     cr=ric(1:(2*nf+1),dt,tp);
%     cr=ifft(0.5*cr);
%     spectre=spectre+.3*cr(1:nf);
%     
elseif para.pulso.tipo==3 %Ricker periodo caracter�stico tp
dt=(1/(df*2*nf)*(nf/(nf-1)));
tp=para.pulso.a;
ts=para.pulso.b;
a = pi*(-ts)/tp;
ntiempo = (2*nf-2);
cr = zeros(1,ntiempo);
cr(1) = (a*a-0.5)*exp(-a*a);
for i=2:ntiempo/2+1
    a = pi*(dt*(i-1)-ts)/tp;
    a = a*a;
    cr(i) = (a-0.5)*exp(-a);
end
cr = -cr;
spectre=fft(cr*dt); %forward
spectre=spectre(1:nf); % se�al en frecuencia
% if length(para.Ricker_tp) ~= 2
% w   = 2*pi*(df*((1:nf)-1));
% spectre=spectre.*exp(1i*w*(1.5*tp));
% end

% figure;subplot(2,1,1);plot(real(cr),'r');hold on;plot(imag(cr),'b')
% subplot(2,1,2);plot(real(spectre),'r');hold on;plot(imag(spectre),'b')
% elseif para.pulso.tipo==4  % pulso gaussiana
%   % para.pulso.a  es aprox. el ancho de la campana de Gauss
%   % sigma est� corregido para que el 2(desv. estandard) coincida con .a
%     sigma   = sqrt(para.pulso.a^2/(8*log(2)));
%     freq0   = 0;
%     damp    = 0;
%     freq1   = 2*pi*(freq0 + df*((1:nf)-1))+damp;
%     spectre = exp(-2*(pi*freq1/(2*pi)*sigma).^2);
% % % 
% %     sigma=sqrt(100*para.tps_anchoG^2/(8*log(2)));
% %     freq1 = 2*pi*(freq0 + df*((1:nf)-1))+damp;
% %     spectre=spectre.*(1+3*exp(-2*(pi*freq1/(2*pi)*sigma).^2));
elseif para.pulso.tipo==4 % plano + tapper gaussiano
  % para.pulso.a  es aprox. el ancho de la campana de Gauss
  % sigma est� corregido para que el 2(desv. estandard) coincida con .a
  % se aplica un corrimiento manteniendo plano el espectro hasta .c
    sigma   = sqrt(para.pulso.a^2/(8*log(2)));
    freq0   = 0;
    damp    = 0;
    freq1   = 2*pi*(freq0 + df*((1:nf)-1))+damp;
    spectre = exp(-2*(pi*freq1/(2*pi)*sigma).^2);
    if para.pulso.c > 0
    init = find(w/2/pi > para.pulso.c); 
    if ~isempty(init)
    init = max(1,init(1));
    spectre = circshift(spectre,init,2);
    spectre(1:init) = 1;
    end
    end
elseif para.pulso.tipo==5 % dirac
    spectre=ones(1,nf);
end

if para.pulso.tipo~=3 
spectre=spectre.*exp(1i*w*(para.pulso.b));
elseif para.pulso.tipo == 3
spectre=spectre.*exp(1i*w*(para.pulso.c));
end