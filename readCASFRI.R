# Load libraries ----------------------------------------------------------
library("fasterize")
library("sf")
library("sp")

## set SppEquiv
sppEquiv <- simOutPreamble$sppEquiv
RTM <- simOutPreamble$rasterToMatch
sppEquivCol <- simOutPreamble$sppEquivCol

# Load data ---------------------------------------------------------------
# SA_geodata <- Cache (prepInputs,
#                      destinationPath = paths1$inputPath,
#                      url = paste0("https://drive.google.com/file/d/",
#                                   "1uZ_JBIYWooGTxIPHThnRKCkXhnC9FoCy/view?usp=sharing"),
#                      targetFile = 'bcr6bc_wb.gdb',
#                      archive = "bcr6RIA_CASFRI.zip",
#                      alsoExtract = "similar",
#                      fun = "sf::st_read",
#                      filename2 = NULL)
SA_data <- st_read('./inputs/bcr6bc_wb.gdb')
CASFRI_sf<- st_as_sf(SA_data)

SA_spp <- data.table::fread('./inputs/bcr6bc_wb_lyr.csv')

# SA_spp <- Cache(prepInputs,
#                 destinationPath = asPath(paths1$inputPath),
#                 url = paste0("https://drive.google.com/file/d/",
#                              "1uZ_JBIYWooGTxIPHThnRKCkXhnC9FoCy/view?usp=sharing"),
#                 targetFile = "output/bcr6bc_wb_lyr.csv",
#                 archive = "bcr6RIA_CASFRI.zip",
#                 alsoExtract = "similar",
#                 #fun = "data.table::fread",
#                 filename2 = NULL)

## transform the name column to a factor one. It is important to use as.numeric
CASFRI_sf$polyID <- as.numeric(as.factor(CASFRI_sf$cas_id))


## reproject to RTM crs
CASFRI_sf <- st_transform(CASFRI_sf, raster::crs(RTM))


## create the raster for the whole area
CASFRIRas <- fasterize::fasterize(CASFRI_sf, RTM, field = "polyID")

#writeRaster(CASFRIRas, file= "./inputs/bcr6BCRasCasfri", format ="GTiff", overwrite = TRUE)

loadCASFRIana <- function(CASFRIRas, attrFile, sppEquiv, sppEquivCol,
                          type = c("cover", "age")) {
  # The ones we want
  sppEquiv <- sppEquiv[!is.na(sppEquiv[[sppEquivCol]]), ]

  # Take this from the sppEquiv table; user cannot supply manually
  sppNameVector <- unique(sppEquiv[[sppEquivCol]])
  names(sppNameVector) <- sppNameVector

  sppNameVectorCASFRI <- equivalentName(sppNameVector, sppEquiv,  column = "CASFRI", multi = TRUE)

  ## qcAtt <- read.csv(file.path("inputs", "studyArea", "QC", "qc_att.csv"))
  CASFRIcas <- data.table::fread(file.path("inputs", "studyArea", "output", "bcr6bc_wb_cas.csv"))
  CASFRISpp <- data.table::fread(file.path("inputs", "studyArea", "output", "bcr6bc_wb_lyr.csv"))
  CASFRIattr <- merge(CASFRIcas, CASFRISpp, by = "cas_id", all = TRUE)
  ## qcAtt <- as.data.table(qcAtt) ## convert to a data.table to be able to join
  #write.csv(CASFRIattr, file= file.path("inputs", "studyArea", "output", "bcr6bc_wb_att.csv"))

  keep <- c ("cas_id", "stand_photo_year", "origin_upper", "origin_lower", "species_1",
             "species_per_1","species_2","species_per_2","species_3","species_per_3",
             "species_4", "species_per_4", "species_5","species_per_5","species_6",
             "species_per_6", "species_7", "species_per_7", "species_8", "species_per_8",
             "species_9", "species_per_9", "species_10", "species_per_10")

  CASFRIattr <- CASFRIattr[, .SD, .SDcols = keep ]
  #create polyID column will match the raster cell
  CASFRIattr$polyID <- as.numeric(as.factor(CASFRIattr$cas_id))

  ## create age column
  # CASFRIattr[, age:= ifelse(stand_photo_year == -9997, 'NA',
  #                    ifelse(origin_upper == c(-9999, -8888) , 'NA',
  #                    ifelse(origin_lower == c(-9999, -8888), 'NA',
  #                           stand_photo_year - sum(origin_upper, origin_lower)/2)))]

  ### age for casfri can be obtained by susbtracting the stand_photo year, from the
  ### origin_lower or origin_upper, both columns are identical. I checked them by
  ### using identical(CASFRIattr[['origin_lower']], CASFRIattr[['origin_upper']]

  CASFRIattr[, age:= ifelse(stand_photo_year == -9997, 'NA',
                            ifelse(origin_upper == c(-9999, -8888) | origin_lower == c(-9999, -8888), 'NA',
                                   #stand_photo_year - (sum(origin_upper, origin_lower)/2)))]
                                   stand_photo_year - origin_lower))]


  NAVals <- c(-9999, -8888, -9997)

  numSpeciesColumns <- length(grep("species_", names(CASFRIattr), value = TRUE))

  if (type[1] == "cover") {
    for (i in seq(numSpeciesColumns)) {
      set(CASFRIattr, which(CASFRIattr[[paste0("species_", i)]] %in% NAVals),
          paste0("species_", i), NA_character_)
      set(CASFRIattr, which(CASFRIattr[[paste0("species_per_", i)]] %in% NAVals),
          paste0("species_per_", i), NA_character_)
    }
    for (i in 1:1) {
      message("remove CASFRI entries with <15 cover as dominant species,",
              " i.e., these pixels are deemed untreed")
      CASFRIattr <- CASFRIattr[which(CASFRIattr[[paste0("species_per_", i)]] > 15), ]
    }
    message("set CASFRI entries with <15 cover in 2nd-5th dominance class to NA")
    for (i in 2:20) {
      set(CASFRIattr, which(CASFRIattr[[paste0("species_per_", i)]] <= 15),
          paste0("species_", i), NA_character_)
    }

    CASFRIattrLong <- melt(CASFRIattr, id.vars = c("cas_id", "polyID"),
                           measure.vars = paste0("species_", 1:5)) ## TODO: how to automate this for only columns with values??
    CA2 <- melt(CASFRIattr, id.vars = c("polyID"),
                measure.vars = c(paste0("species_per_", 1:5)))
    CASFRIattrLong[, pct := CA2$value]
    rm(CA2)
    CASFRIattrLong <- na.omit(CASFRIattrLong)
   # CASFRIattrLong <- CASFRIattrLong[value %in% sppNameVectorCASFRI]  ## There is a mistmatch in the naming schema of CASFRI

  } else{
    CASFRIattrLong <- CASFRIattr[, .(polyID, age)]
    CASFRIattrLong <- CASFRIattrLong[!is.na(age) & age > -1]
  }
  # file_list<- list(qcPoly1, qcPoly2) ## as sf objects
  # CASFRI_allPolys <- data.table::rbindlist(file_list)
  # QC_allPolys<- merge(CASFRI_allPolys,CASFRIattrLong, by = "cas_id")
  # QC_allPolys<- st_as_sf(QC_allPolys)
  # st_write(QC_allPolys, "QC_allPolys.shp")

  # #create the raster for the whole area
  # CASFRIRasQC <- fasterize(CASFRIsf, RTM, field = "polyID")
  #
  # writeRaster(CASFRIRasQC, file= "CASFRIRasGid_QC", format ="GTiff", overwrite = TRUE)

  CASFRIdt <- data.table(polyID = CASFRIRas[], rastInd = 1:ncell(CASFRIRas))
  CASFRIdt <- CASFRIdt[!is.na(polyID)]
  setkey(CASFRIdt, polyID)

  return(list(CASFRIattrLong = CASFRIattrLong, CASFRIdt = CASFRIdt))
}

##adding the new CASFRI  name   to sppEquiv table. There are other species, but this is a test
CASFRI2 <- c('ABIE_LAS_###', 'BETU_PAP_###', 'LARI_LAR_###', 'PICE_ENG_###',
             'PICE_GLA_###', 'PICE_MAR_###', 'PINU_CON_###', 'POPU_TRE_###')

spp <- sort(unique(CASFRIattrLong$value))

sppEquiv$CASFRI2 <- CASFRI2


CASFRItoSpRasts <- function(CASFRIRas, CASFRIattrLong, CASFRIdt,
                            sppEquiv, sppEquivCol, destinationPath) {
  # The ones we want
  sppEquiv <- sppEquiv[!is.na(sppEquiv[[sppEquivCol]]), ]

  # Take this from the sppEquiv table; user cannot supply manually
  sppNameVector <- unique(sppEquiv[[sppEquivCol]])
  names(sppNameVector) <- sppNameVector

  # This
  sppListMergesCASFRI <- lapply(sppNameVector, function(x)
    equivalentName(x, sppEquiv,  column = "CASFRI2", multi = TRUE)
  )

  ## create list and template raster
  spRasts <- list()
  spRas <- raster(CASFRIRas) %>% setValues(., NA_integer_)

  ## NOT SURE IF THESE LINES ABOUT NA are relevant -- Eliot Dec 7
  ## selected spp absent from CASFRI data
  NA_Sp <- which(is.na(sppListMergesCASFRI))#setdiff(speciesLandR, unique(keepSpecies$spGroup))

  ## All NA_Sp species codes should be in CASFRI spp list
  if (length(NA_Sp))
    warning("Not all selected species are in loadedCASFRI. Check if this is correct:\n",
            paste(paste0(keepSpecies$CASFRI[NA_Sp], collapse = ", "), "absent\n"))

  ## empty rasters for NA_sp
  for (sp in NA_Sp) {
    message("  running ", sp, ". Assigning NA, because absent from CASFRI")
    spRasts[[sp]] <- spRas
    spRasts[[sp]] <- Cache(writeRaster, spRasts[[sp]],
                           filename = asPath(file.path(destinationPath,
                                                       paste0("CASFRI", sp, ".tif"))),
                           overwrite = TRUE, datatype = "INT2U")
  }

  sppTODO <- unique(names(sppListMergesCASFRI))
  destinationPath <- './inputs/studyArea/CASFRI'

  for (sp in sppTODO) {
    spCASFRI <- sppListMergesCASFRI[[sp]]
    spRasts[[sp]] <- spRas
    message("starting ", sp)
    if (length(spCASFRI) > 1)
      message("  Merging ", paste(spCASFRI, collapse = ", "), "; becoming: ", sp)
    aa2 <- CASFRIattrLong[value %in% spCASFRI][, min(100L, sum(pct)), by = polyID]
    setkey(aa2, polyID)
    cc <- aa2[CASFRIdt] %>% na.omit()
    rm(aa2)
    spRasts[[sp]][cc$rastInd] <- cc$V1
    message("  ", sp, " writing to disk")

    startCRS <- crs(spRasts[[sp]])
    spRasts[[sp]] <- writeRaster(spRasts[[sp]],
                                 filename = asPath(file.path(destinationPath,
                                                             paste0("CASFRI", sp, ".tif"))),
                                 datatype = "INT1U", overwrite = TRUE)

    if (is(spRasts[[sp]], "Raster")) {
      # Rasters need to have their disk-backed value assigned, but not shapefiles
      # This is a bug in writeRaster was spotted with crs of rastTmp became
      # +proj=lcc +lat_1=49 +lat_2=77 +lat_0=0 +lon_0=-95 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs
      # should have stayed at
      # +proj=lcc +lat_1=49 +lat_2=77 +lat_0=0 +lon_0=-95 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0
      if (!identical(startCRS, crs(spRasts[[sp]])))
        crs(spRasts[[sp]]) <- startCRS
    }
    message("  ", sp, " done")
  }

  raster::stack(spRasts)
}



#' @export
#' @rdname prepSpeciesLayers
prepSpeciesLayers_CASFRIAna<- function(destinationPath, outputPath,
                                     url = NULL,
                                     studyArea, rasterToMatch,
                                     sppEquiv,
                                     sppEquivCol, ...) {
  if (is.null(url))
    url <- "https://drive.google.com/file/d/1y0ofr2H0c_IEMIpx19xf3_VTBheY0C9h/view?usp=sharing"

  CASFRItiffFile <- asPath(file.path(destinationPath, "Landweb_CASFRI_GIDs.tif"))
  CASFRIattrFile <- asPath(file.path(destinationPath, "Landweb_CASFRI_GIDs_attributes3.csv"))
  CASFRIheaderFile <- asPath(file.path(destinationPath, "Landweb_CASFRI_GIDs_README.txt"))

  message("  Loading CASFRI layers...")
  CASFRIRas <- Cache(prepInputs,
                     #targetFile = asPath("Landweb_CASFRI_GIDs.tif"),
                     targetFile = basename(CASFRItiffFile),
                     archive = asPath("CASFRI for Landweb.zip"),
                     url = url,
                     alsoExtract = c(CASFRItiffFile, CASFRIattrFile, CASFRIheaderFile),
                     destinationPath = destinationPath,
                     fun = "raster::raster",
                     studyArea = studyArea,
                     rasterToMatch = rasterToMatch,
                     method = "bilinear", ## ignore warning re: ngb (#5)
                     datatype = "INT4U",
                     filename2 = NULL,
                     overwrite = TRUE,
                     userTags =  c("CASFRIRas", "stable"))

  message("Load CASFRI data and headers, and convert to long format, and define species groups")

  #Cache
  loadedCASFRI <- Cache(loadCASFRI,
                        CASFRIRas = CASFRIRas,
                        attrFile = CASFRIattrFile,
                        headerFile = CASFRIheaderFile, ## TODO: this isn't used internally
                        sppEquiv = sppEquiv,
                        sppEquivCol = sppEquivCol,
                        type = "cover"#,
                        #userTags = c("function:loadCASFRI", "BigDataTable",
                        #"speciesLayers", "KNN")
  )

  message("Make stack from CASFRI data and headers")
  CASFRISpStack <- CASFRItoSpRasts(CASFRIRas = CASFRIRas,
                                   sppEquiv = sppEquiv,
                                   sppEquivCol = sppEquivCol,
                                   CASFRIattrLong = loadedCASFRI$CASFRIattrLong,
                                   CASFRIdt = loadedCASFRI$CASFRIdt,
                                   destinationPath = paths2$cachePath)

  return(CASFRISpStack)
}
