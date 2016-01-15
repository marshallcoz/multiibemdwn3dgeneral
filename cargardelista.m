function para = cargardelista(para,J)
for m = 2:para.nmed % para cada medio (sólo inclusiones)
    for p = 1:para.cont(m,1).NumPieces % cada pieza
      kind = para.cont(m,1).piece{p}.kind;
      if kind ~= 3 % si no es una frontera auxiliar
          nomlista = para.cont(m,1).piece{p}.fileName;
          
          
          [para.cont(thismed,1).piece{info.ThisPiece}.geoFileData,flag] = ...
 previewSTL(bouton.gfPreview,para.cont(thismed,1).piece{info.ThisPiece});
      end
    end
end

end