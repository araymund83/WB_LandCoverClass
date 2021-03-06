do.call(SpaDES.core::setPaths, paths1)

## TODO: make this a module

bcrzip <- "https://www.birdscanada.org/download/gislab/bcr_terrestrial_shape.zip"

targetCRS <- paste(
  "+proj=lcc +lat_1=49 +lat_2=77 +lat_0=0 +lon_0=-95",
  "+x_0=0 +y_0=0 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"
)

#################################################################################
## BCR regions
#################################################################################
bcr_sf <- Cache(prepInputs,
                url = bcrzip,
                destinationPath = Paths$inputPath,
                targetCRS = targetCRS,
                fun = "sf::st_read")

#################################################################################
## Canada Provinces
#################################################################################
canProvs <- Cache(prepInputs,
                  "GADM",
                  fun = "base::readRDS",
                  dlFun = "raster::getData",
                  country = "CAN", level = 1, path = paths1$inputPath,
                  # targetCRS = targetCRS, ## TODO: fails on Windows
                  targetFile = "gadm36_CAN_1_sp.rds", ## TODO: this will change as GADM data update
                  cacheRepo = paths1$cachePath,
                  destinationPath = paths1$inputPath
) %>%
  st_as_sf(.) %>%
  st_transform(., targetCRS)

#################################################################################
## BCR for Western Boreal
#################################################################################
provs <- c("British Columbia", "Alberta", "Saskatchewan", "Manitoba")
terrs <- c("Yukon", "Northwest Territories", "Nunavut")
WB <- c(provs, terrs)

bcrWB <- bcr_sf[bcr_sf$BCR %in% c(4, 6:8), ]
provsWB <- canProvs[canProvs$NAME_1 %in% WB, ]

studyArea <- Cache(postProcess,
                   provsWB,
                   studyArea = bcrWB, useSAcrs = TRUE,
                   cacheRepo = paths1$cachePath, filename2 = "WB_studyArea") %>%
  as_Spatial(.)

## TODO: Error in lfn[f]:2 : NA/NaN argument
#shapefile(studyArea, file.path(Paths$inputPath, "BCR_WB.shp"), overwrite = TRUE)

#################################################################################
## BCR6 subdivision
#################################################################################
provBCR6 <- c(
  "British Columbia", "Alberta", "Saskatchewan", "Manitoba",
  "Northwest Territories"
)
provs2 <- c("British Columbia", "Alberta")
provs3 <- c("Saskatchewan", "Manitoba")
provs4 <- c("Northwest Territories")

bcr6 <- bcr_sf[bcr_sf$BCR %in% c(6), ]

provsBCR6 <- canProvs[canProvs$NAME_1 %in% provBCR6, ]
NWT <- canProvs[canProvs$NAME_1 %in% provs4, ]
ABBC <- canProvs[canProvs$NAME_1 %in% provs2, ]
SKMB <- canProvs[canProvs$NAME_1 %in% provs3, ]

bcr6SA <- reproducible::Cache(postProcess,
                              provsBCR6,
                              studyArea = bcr6,
                              useSAcrs = TRUE,
                              cacheRepo = asPath(Paths$cachePath),
                              destinationPath = asPath(Paths$inputPath),
                              filename2 = "bcr6_studyArea")

## in order to be able to rasterize, we need to create a numeric column to ID each of the provinces
## for BCR6
bcr6SA$ID <- as.numeric(as.factor(bcr6SA$NAME_1))

## In addition, this object has problems when rasterize, that is why geometry is being
## homogenize by using st_cast
#bcr6SA <- st_cast(bcr6SA, "MULTIPOLYGON") %>% as_Spatial(bcr6SA) ## TODO:

## BCR6 Alberta - British Columbia
bcr6ABBC <- reproducible::Cache(postProcess,
                                ABBC,
                                studyArea = ABBC,
                                useSAcrs =  TRUE,
                                filename2 = NULL,
                                cacheRepo = Paths$cachePath)

## BCR6 North West Territories
bcr6NWT <- reproducible::Cache(postProcess,
                               NWT,
                               studyArea = bcr6SA,
                               useSAcrs = TRUE,
                               filename2 = NULL,
                               cacheRepo = Paths$cachePath)

## BCR6 Saskatchewan - Manitoba
bcr6SKMB <- postProcess(SKMB,
                        studyArea = bcr6SA,
                        useSAcrs = TRUE,
                        filename2 = NULL,
                        cacheRepo = Paths$cachePath)

## saving shapefiles
st_write(bcr6SA, file.path(Paths$inputPath, "BCR6.shp"), overwrite = TRUE)
st_write(bcr6ABBC, file.path(Paths$inputPath, "BCR6_ABBC.shp"), overwrite = TRUE)
st_write(bcr6SKMB, file.path(Paths$inputPath, "BCR6_SKMB.shp"), overwrite = TRUE)
st_write(bcr6NWT, file.path(Paths$inputPath, "BCR6_NWT.shp"), overwrite = TRUE)

#################################################################################
## LCC 2005
#################################################################################
LCC05Ras <- reproducible::Cache(LandR::prepInputsLCC,
                                destinationPath = asPath(Paths$inputPath),
                                studyArea = studyArea,
                                year = 2005,
                                filename2 = "LCC05_WB"
)

## crop and mask with BCR6
LCC05_6Ras <- reproducible::Cache(postProcess,
                                  destinationPath = asPath(Paths$inputPath),
                                  LCC05Ras,
                                  studyArea = bcr6SA,
                                  filename2 = "LCC05_BCR6")

bcr6SKMB <- as_Spatial(bcr6SKMB)
LCC05_SKMBRas <- reproducible::Cache(LandR::prepInputsLCC,
                                     year = 2005,
                                     studyArea = bcr6SKMB,
                                     destinationPath = asPath(Paths$inputPath),
                                     filename2 = "LCC05_SKMB")

bcr6NWT <- as_Spatial(bcr6NWT)
LCC05_NWTRas <- reproducible::Cache(postProcess,
                                    LCC05Ras, 
                                    studyArea = bcr6NWT,
                                    destinationPath = asPath(Paths$inputPath),
                                    filename2 = "LCC05_NWT")

#################################################################################
studyAreaLarge <- studyArea
rasterToMatchLarge <- LCC05Ras
rstLCC <- LCC05Ras
studyArea <- bcr6SA
rasterToMatch <- LCC05_6Ras

#################################################################################
## Age
#################################################################################
standAgeMapURL <- paste0(
  "ftp://ftp.maps.canada.ca/pub/nrcan_rncan/Forests_Foret/",
  "canada-forests-attributes_attributs-forests-canada/2011-attributes_attributs-2011/",
  "NFI_MODIS250m_2011_kNN_Structure_Stand_Age_v1.tif"
)

standAgeMap2011 <- Cache(LandR::prepInputsStandAgeMap,
                         destinationPath = asPath(Paths$inputPath),
                         ageUrl = standAgeMapURL,
                         ageFun = "raster::raster",
                         studyArea = studyArea,
                         rasterToMatch = rasterToMatch,
                         # maskWithRTM = TRUE,
                         method = "bilinear",
                         datatype = "INT2U",
                         filename2 = "standAgeMap.tif",
                         startTime = 2011)

#################################################################################
## Wetlands
#################################################################################
# wetlandzip <- "https://drive.google.com/file/d/1R1AkkD06E-x36cCHWL4U5450mSDu_vD0/view?usp=sharing"
# wetlandWB <- Cache(prepInputs,
#                 url = wetlandzip,
#                 destinationPath = getPaths()$inputPath,
#                 studyArea = studyArea,
#                 destinationPath = Paths$inputPath,
#                 rasterToMatch = LCC05Ras,
#                 targetFile = "CA_wetlands_post2000.tif",
#                 userTags = c("wetlandWB")
#                 )
# wetland6 <-  reproducible::Cache(postProcess,
#                                  wetlandWB,
#                                  studyArea = bcr6SA,
#                                  useSAcrs = TRUE)

flammableMap <- LandR::defineFlammable(LandCoverClassifiedMap = rstLCC,
                                       nonFlammClasses = c(33, 36:39),
                                       mask = rasterToMatchLarge)

firePointsURL <- "http://cwfis.cfs.nrcan.gc.ca/downloads/nfdb/fire_pnt/current_version/NFDB_point.zip"
firePoints <- Cache(fireSenseUtils::getFirePoints_NFDB,
                    url = firePointsURL,
                    studyArea = studyAreaLarge,
                    rasterToMatch = rasterToMatchLarge,
                    redownloadIn = 1,
                    years = 1991:2017, ## TODO: @araymund83 these are default years; do you want others?
                    fireSizeColName = "SIZE_HA",
                    NFDB_pointPath = asPath(Paths$inputPath)) %>% 
  st_as_sf(.)

biomassMapURL <- paste0(
  "https://ftp.maps.canada.ca/pub/nrcan_rncan/Forests_Foret/",
  "canada-forests-attributes_attributs-forests-canada/2001-attributes_attributs-2001/",
  "NFI_MODIS250m_2001_kNN_Structure_Biomass_TotalLiveAboveGround_v1.tif"
)

with_config(config = config(ssl_verifypeer = 0L), {
  rawbiomassMap2001 <- Cache(prepInputs,
                             destinationPath = asPath(Paths$inputPath),
                             url = biomassMapURL,
                             fun = "raster::raster",
                             studyArea = studyAreaLarge,
                             rasterToMatch = rasterToMatchLarge,
                             maskWithRTM = TRUE,
                             method = "bilinear",
                             datatype = "INT2U",
                             filename2 = "rawBiomassMap2001")
})

speciesLayers2001 <- Cache(LandR::loadkNNSpeciesLayers,
                           dPath = asPath(Paths$inputPath),
                           rasterToMatch = rasterToMatchLarge,
                           studyArea = studyAreaLarge,
                           sppEquiv = sppEquivalencies_CA,
                           sppEquivCol = sppEquivCol,
                           filename2 = "speciesLayers2001",
                           url = paste0(
                             "https://ftp.maps.canada.ca/pub/nrcan_rncan/Forests_Foret/",
                             "canada-forests-attributes_attributs-forests-canada/",
                             "2001-attributes_attributs-2001/"
                           )
)

vegMap <- Cache(prepInputsLCC,
                year = 2005,
                destinationPath = asPath(Paths$inputPath),
                studyArea = studyAreaLarge,
                rasterToMatch = rasterToMatchLarge,
                filename2 = "vegMap.tif"
)

## TODO: revist this -- why are so many changes etc. being done? why use 'WB' column -- use 'LandR'?

## species equivalencies
sppEquivCol <- "WB"
sppEquiv <- data("sppEquivalencies_CA", package = "LandR")

## TODO: is this needed?
# sppEquiv[grep("Pin", LandR), `:=`(EN_generic_short = "Pine",
#                                   EN_generic_full = "Pine",
#                                   Leading = "Pine leading")]

sppEquiv[, WB := c(Pice_mar = "Pice_mar", Pice_gla = "Pice_gla",
                   Pinu_con = "Pinu_con", Popu_tre = "Popu_tre",
                   Popu_bal = "Popu_bal", Lari_lar = "Lari_lar",
                   Pinu_ban = "Pinu_ban", Betu_pap = "Betu_pap",
                   Abie_las = "Abie_las", Abie_bal = "Abie_bal")[LandR]]
#Frax_pen = "Frax_pen", Acer_neg = "Acer_neg",
# Ulmu_ame = "Ulmu_ame", Sali_sp = "Sali_sp")[LandR]]

sppEquiv <- sppEquiv[LANDIS_traits != "PINU.CON.CON"] 

sppEquiv[WB == "Abie_las", EN_generic_full := "Subalpine Fir"]
sppEquiv[WB == "Abie_las", EN_generic_short := "Fir"]
sppEquiv[WB == "Abie_las", Leading := "Fir leading"]
sppEquiv[WB == "Popu_tre", Leading := "Pop leading"]
sppEquiv[WB == "Betu_pap", EN_generic_short := "Birch"]
sppEquiv[WB == "Betu_pap",  Leading := "Birch leading"]
sppEquiv[WB == "Betu_pap",  EN_generic_full := "Paper birch"]
# sppEquiv[WB == "Acer_neg",  EN_generic_full := "Boxelder maple"]
# sppEquiv[WB == "Frax_ame",  EN_generic_full := "American beech"]
# sppEquiv[WB == "Sali_sp",  EN_generic_full := "Willow leading"]

sppEquiv$EN_generic_short <- sppEquiv$WB

sppEquiv <- sppEquiv[!is.na(WB)]
sppEquiv[WB == "Pinu_con", KNN := "Pinu_Con"]

#Assign colour
sppColorVect <- LandR::sppColors(sppEquiv = sppEquiv, 
                                 sppEquivCol = sppEquivCol,
                                 palette = "Paired")
mixed <- structure("#D0FB84", names = "Mixed")
sppColorVect[length(sppColorVect) + 1] <- mixed
attributes(sppColorVect)$names[length(sppColorVect)] <- "Mixed"
