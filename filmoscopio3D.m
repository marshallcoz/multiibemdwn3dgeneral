function filmoscopio3D(para,utc,~,film)
%filmoscopio Make a movie, receiv~ers on a grid and on the boundary.
%   The movie es made with data either from a grid of receivers,
%   from receivers on the boundary (The boundary appears deformed)
%   or both.
filmeRange = film.filmeRange;
% por ahora sólo un estilo
filmStyle    = film.filmStyle;
filmeMecElem = film.filmeMecElem;
cmd_takingNames;
mecelemlist = film.strmecelemlist;
%if (para.rec.resatboundary); warpBoundaries = true; else warpBoundaries = false; end
if (filmStyle == 1); filmStyle = 3; warning ('Using filmSyle = grid with shadow');end

nf      = para.nf;
df      = para.fmax/(nf/2);     %paso en frecuencia
% Fq      = (0:nf/2)*df;
nfN     = nf/2+1; %Nyquist
zerospad= para.zeropad;
dt = (1/(df*2*(nfN+zerospad))*...
  (2*(nfN+zerospad)/(2*(nfN+zerospad)-2)));
tps     = 0:dt:1/df;
tps     = para.delais+tps;

% listinc={'P','S','R'};
[az,el]=view; 
fig=figure('Position', [0, 0, 800, 800],'Color',[1 1 1]);
set(fig,'DoubleBuffer','on'); set(gcf,'Renderer','zbuffer')
name=[para.nomrep,para.nomrep(1),'filmtmp','_000'];
% cont1 = para.cont; % cont1

% nresAtBoundary = para.rec.nresAtBoundary;
nrecx=para.rec.nrecx;%-nresAtBoundary;
nrecy=para.rec.nrecy;
nrecz=para.rec.nrecz;

xr      = para.rec.xri+para.rec.dxr*(0:(nrecx-1));
yr      = para.rec.yri+para.rec.dyr*(0:(nrecy-1));
zr      = para.rec.zri+para.rec.dzr*(0:(nrecz-1));
mxWarp = abs(xr(end) - xr(1))/15;
if (mxWarp == 0)
  mxWarp = abs(yr(end) - yr(1))/15;
end

% estilo tipo mesh y mesh con sombreado :
if (filmStyle ~= 4)
  [MX,MY,MZ] = meshgrid(xr,yr,zr);
end
while exist([name,'.avi'],'file')==2
  compt=str2double(name(length(name)-2:length(name)));
  name=[name(1:length(name)-3),num2str(compt+1,'%.3i')];
end

mov = VideoWriter(name);%,'LosslessCompression','true');
mov.FrameRate = film.fps;
open(mov);
nam = char(mecelemlist(filmeMecElem));
for iinc=1
  
  dibujo_conf_geo(para,gca)
  xlim('manual');ylim('manual');zlim('manual')
  hold on
  view(az,el);
  m3max=max(max(max(max(utc(filmeRange,:,iinc,:)))))/mxWarp;
  u =utc(filmeRange,:,iinc,1)/m3max;
  v =utc(filmeRange,:,iinc,2)/m3max;
  w =utc(filmeRange,:,iinc,3)/m3max;
  r = (u.^2+v.^2+w.^2).^0.5;
  maxr = max(max(r));
  mx = mean(maxr);
  txtiempo = squeeze(tps(filmeRange));
  
  iit=0;
  [ntf,nes]=size(u);
  for it= 1:ntf
    iit=iit+1;
      if ((filmStyle == 2) || (filmStyle == 3)); MXi=MX;MYi=MY;MZi=MZ;C=MX.*0;end
      if (filmStyle == 4); x=zeros(1,nes);y=x;z=x;mag=x;n=zeros(3,nes);end
      for iz=1:nrecz
        for iy=1:nrecy
          for ix=1:nrecx
            ies = ix+(iy-1)*nrecx+(iz-1)*nrecx*nrecy;
            if ((filmStyle == 2) || (filmStyle == 3))
              % mesh
              if (max(abs(sqrt(u(it,ies)^2+v(it,ies)^2+w(it,ies)^2)))==0)
                MZi(iy,ix,iz)= nan; %No traza el grid
              else
                MXi(iy,ix,iz)=MXi(iy,ix,iz)+u(it,ies);
                MYi(iy,ix,iz)=MYi(iy,ix,iz)+v(it,ies);
                MZi(iy,ix,iz)=MZi(iy,ix,iz)+w(it,ies);
                C(iy,ix,iz)  = -r(it,ies);
                %                 MZi(ix,iz)=MZi(ix,iz)-r(it,ies);
              end
            elseif (filmStyle == 4)
              % quiver
              x(1,ies) = xr(ix);
              y(1,ies) = yr(iy);
              z(1,ies) = zr(iz);
              n(1,ies) = u(it,ies);
              n(2,ies) = v(it,ies);
              n(3,ies) = w(it,ies);
              mag(ies) = comprimir(magnitud(n(1:3,ies)),mx);
            end
          end
        end
      end
      if (filmStyle == 2)
        tmph = mesh(MXi,MYi,MZi,C);
        caxis([-40 1]); %todo blanco
      elseif (filmStyle == 3)
        tmph = surf(MXi,MYi,MZi,C,'FaceColor','interp',...
          'FaceLighting','phong','AmbientStrength',.9,'DiffuseStrength',.8,...
          'SpecularStrength',.9,'SpecularExponent',25,...
          'BackFaceLighting','unlit',...
          'EdgeColor','none','LineStyle','none');
        caxis([-0.1*maxr 0.005*maxr]);
        alpha(tmph,0.5);
        camlight right
        %           caxis([-1*maxr 1*maxr]);
        %           caxis([-1*maxr 0.05*maxr]); % fondo blanco, color en los frentes de onda
      elseif (filmStyle == 4)
        iv = mag>1.1*mean(mag);
        tmph = quiver3(x(iv),y(iv),z(iv),n(1,iv),n(2,iv),n(3,iv),max(mag),'k');
      end
    colormap(gray);
    
    if (filmStyle == 1)
      t_title = '|| U ||';
    else
      if strcmp(nam(1:1),'U')
        t_title = '|| U ||';
      else
        t_title = ['|| ' nam ' ||'];
      end
      shading faceted
    end
    title(t_title)
    % Marca de tiempo
    tmpstr=[t_title '  ' num2str(txtiempo(iit)),' s'];
    %             h=annotation('textbox',[.35 .9 .3 .3]);
    %             set(h,'FitHeightToText','on',...
    %             'string',tmpstr,...
    %             'HorizontalAlignment','center','FontWeight','bold','LineStyle','none')
    
    h = uicontrol('Style','text','String',tmpstr,...
      'Units','normalized','Fontsize',12,...
      'Position',[0.35 0.15 0.3 0.035],'BackgroundColor',[1 1 1]);
    frame = getframe(gcf);
    writeVideo(mov,frame);
    pause(.1)
    delete(h)
    delete(tmph)
    %     hold off
  end
end
close(mov);
close(fig);
implay([name,'.avi'])
end

function [s] = comprimir(s,mx)
p = 15; %8
s =  log((1. + exp(p)*abs(s))) / (log(exp(p)+1.));
%disp(s)
s = s / mx;
end

function [r] = magnitud(s)
r = sqrt(sum((s(1:3)).^2));
end


