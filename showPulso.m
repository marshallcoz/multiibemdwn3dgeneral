function showPulso( para )
%showPulso Mostrar la señal del pulso en la fuente
%   La señal se muestra en frecuencia y tiempo así como los valores máximos
%   calcualdos 

nf      = para.nf;           disp(['nf = ',num2str(nf)])
nfN     = nf/2+1; 
df      = para.fmax/nfN;     disp(['df = ',num2str(df)])
Fq      = (0:nf/2)*df;       disp(['Fmx= ',num2str(Fq(end))])
% Tq      = 1./Fq;
% zeropad = para.zeropad;
% tps     = 0:(1/(df*2*(nfN+zeropad))*(2*(nfN+zeropad)/(2*(nfN+zeropad)-2))):1/df;
% tps     = linspace(0,1/df,para.zeropad);
dt = 1/(df*para.zeropad);    disp(['dt = ',num2str(dt)])
tps = (0:para.zeropad-1)*dt; disp(['tmx= ',num2str(tps(end))])

cspectre  = correction_spectre(para,nfN,df);
% signal    = real(1/(2*nf)*ifft([cspectre(1:nfN),zeros(1,2*zeropad+1),conj(cspectre(nfN-1:-1:2))])).*exp(para.DWNomei*tps);
% signal    = real(1/dt*ifft([cspectre(1:nfN),zeros(1,2*zeropad+1),conj(cspectre(nfN-1:-1:2))])).*exp(para.DWNomei*tps);

% crepa:
vec = zeros(1,para.zeropad);
vec(1:nfN) = cspectre(1:nfN); 
vec(end-nfN+3:end)=conj(cspectre(nfN-1:-1:2));
% escala:
  dt_nopad = 1/df/(nf-1); % dt sin zeropading
  fac = para.zeropad/nf; % por hacer zeropading
  a = 128*(df*nfN)/nf; % por frecuencia maxima
  sca = dt_nopad*fac/(a*nf); % usar el dt sin zeropading
  signal= real(sca*ifft(vec)).*exp(para.DWNomei*tps); % inversa y frec imag

% graficar
figure;
set(gcf,'name','amplitud del pulso en el origen')
subplot(2,1,1)
cla
plot(Fq,real(cspectre.'),'r');hold on;
plot(Fq,imag(cspectre.'),'b');
plot(Fq,abs(cspectre.'),'k')
ax1 = gca;
ax1_pos = ax1.Position;
ax1.Box = 'off';
xlabel('frecuencia en Hertz')
ax2=axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');
xlim(ax1.XLim)
nn = length(ax1.XTick);
ax2.XTickMode = 'auto';
ax2.XTickLabelMode = 'manual';
cl = cell(nn,1);
cl{1} = ' ';
for i=2:nn
    cl{i} = num2str(1/ax1.XTick(i),3);
end
ax2.XTickLabel = cl;
set(gca,'ytick',[])
title('Espectro de pulso')
xlabel('Periodo en segundos')
subplot(2,1,2)
cla
plot(tps,real(signal.'),'r');hold on;
plot(tps,imag(signal.'),'b');
title('Ondícula')
xlabel('tiempo en segundos')
end

