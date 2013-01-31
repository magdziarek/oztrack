oztrack_kernelbb <- function(sig1, sig2, gridSize, extent, percent, kmlFile) {
  ltraj.obj <- as.ltraj(xy=coordinates(positionFix.proj), date=positionFix$Date, id=positionFix$Name, typeII=TRUE)
  kernelbb.obj <- kernelbb(ltraj.obj, sig1=sig1, sig2=sig2, grid=gridSize, extent=extent)
  hr.proj <- getverticeshr(kernelbb.obj, percent=percent, unin=c('m'), unout=c('km2'))
  if (nrow(hr.proj) == 1) {hr.proj$id <- positionFix[1,'Name']} # Fix: puts 'homerange' instead of animal ID when only one animal
  proj4string(hr.proj) <- proj4string(positionFix.proj)
  hr.xy <- spTransform(hr.proj, CRS('+proj=longlat +datum=WGS84'))
  writeOGR(hr.xy, dsn=kmlFile, layer='KBB', driver='KML', dataset_options=c('NameField=id'))
}