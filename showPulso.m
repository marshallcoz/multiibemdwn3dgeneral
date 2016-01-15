function showPulso( para )
%showPulso Mostrar la señal del pulso en la fuente
%   La señal se muestra en frecuencia y tiempo así como los valores máximos
%   calcualdos 

nf      = para.nf;
nfN     = nf/2+1; 
df      = para.fmax/nfN;
Fq      = (0:nf/2)*df;
Tq      = 1./Fq;
zeropad = para.zeropad;
tps     = 0:(1/(df*2*(nfN+zeropad))*(2*(nfN+zeropad)/(2*(nfN+zeropad)-2))):1/df;
if para.pulsotps~=3 
tps     = para.delais+tps;
end
cspectre  = correction_spectre(para,nfN,df);
signal    = real(1/(2*nf)*ifft([cspectre(1:nfN),zeros(1,2*zeropad+1),conj(cspectre(nfN-1:-1:2))])).*exp(para.DWNomei*tps);

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

