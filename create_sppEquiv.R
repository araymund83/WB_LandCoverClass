allowedStudyAreas <- c("AB", "BC", "MB", "NT", "NU", "SK", "YT") ## prov/terr x BCR intersections


provs <- c("British Columbia", "Alberta", "Saskatchewan", "Manitoba")
terrs <- c("Yukon", "Northwest Territories", "Nunavut")
WB <- c(provs, terrs)

targetCRS <- paste("+proj=lcc +lat_1=49 +lat_2=77 +lat_0=0 +lon_0=-95",
                   "+x_0=0 +y_0=0 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")

bcrzip <- "https://www.birdscanada.org/download/gislab/bcr_terrestrial_shape.zip"

dPath <- file.path("modules", 'WBI_preamble', "data")
bcrshp <- Cache(prepInputs,
                url = bcrzip,
                destinationPath = dPath,
                targetCRS = targetCRS,
                fun = "sf::st_read")

if (packageVersion("reproducible") >= "1.2.5") {
  fn1 <- function(x) {
    x <- readRDS(x)
    x <- st_as_sf(x)
    st_transform(x, targetCRS)
  }
} else {
  fn1 <- "readRDS"
}

canProvs <- Cache(prepInputs,
                  "GADM",
                  fun = fn1,
                  dlFun = "raster::getData",
                  country = "CAN", level = 1, path = paths1$inputPath,
                  #targetCRS = targetCRS, ## TODO: fails on Windows
                  targetFile = "gadm36_CAN_1_sp.rds",
                  destinationPath = paths1$inputPath
)

if (packageVersion("reproducible") < "1.2.5") {
  canProvs <- st_as_sf(canProvs) %>%
    st_transform(., targetCRS)
}

#################################################################################
## BCR for Western Boreal
#################################################################################

bcrWB <- bcrshp[bcrshp$BCR %in% c(4, 6:8), ]
provsWB <- canProvs[canProvs$NAME_1 %in% WB, ]

WBstudyArea <- Cache(postProcess,
                     provsWB,
                     studyArea = bcrWB,
                     useSAcrs = TRUE,
                     cacheRepo = paths1$cachePath,
                     filename2 = NULL) %>%
  as_Spatial(.)

#################################################################################
## BCR subdivision
#################################################################################
AB <- c("Alberta")
BC <- c("British Columbia")
MB <- c("Manitoba")
SK <- c("Saskatchewan")
NT <- c("Northwest Territories")
NU <- c("Nunavut")
YK <- c("Yukon")
##BCR in WB
bcr4 <- bcrshp[bcrshp$BCR %in% c(4), ]
bcr6 <- bcrshp[bcrshp$BCR %in% c(6), ]
bcr7 <- bcrshp[bcrshp$BCR %in% c(7), ]
bcr8 <- bcrshp[bcrshp$BCR %in% c(8), ]

##provinces and territories in WB
AB <- canProvs[canProvs$NAME_1 %in% AB, ]
BC <- canProvs[canProvs$NAME_1 %in% BC, ]
MB <- canProvs[canProvs$NAME_1 %in% MB,]
SK <- canProvs[canProvs$NAME_1 %in% SK,]
NT <- canProvs[canProvs$NAME_1 %in% NT, ]
NU <- canProvs[canProvs$NAME_1 %in% NU, ]
YK <- canProvs[canProvs$NAME_1 %in% YK, ]


bcrBC <- st_intersection(bcrWB, BC)
# bcr6BC <- st_intersection(bcrBC, bcr6)
studyArea <- bcrBC

rstLCC <- reproducible::Cache(LandR::prepInputsLCC,
                              destinationPath = asPath(Paths$inputPath),
                              studyArea = studyArea,
                              rasterToMatch = biomassMaps2011SA$pixelGroupMap,
                              year = 2005)


rstLCC2<- raster::crop(rstLCC, studyArea)
rstLCC<- raster::mask(rstLCC2, studyArea)

##all species considered in WB (will be subset later for each study area)
data("sppEquivalencies_CA", package = "LandR", envir = environment())
allSppCASFRI<- c('Abie amab', 'Abie bals', 'Abie lasi', 'Abie spp', 'Betu neoa',
                 'Betu occi', 'Betu papy', 'Betu pube', 'Betu spp', 'Corn nutt',
                 'Lari lari', 'Lari lari', 'Lari lyal', 'Lari occi', 'Lari sibi',
                 'Lari spp', 'Pice hybr', 'Pice engx', 'Pice enge', 'Pice glau',
                 'Pice hybr', 'Pice mari', 'Pice sitc', 'Pice spp', 'Pinu albi',
                 'Pinu bank', 'Pinu cont', 'Pinu radi', 'Pinu resi' , 'Pinu spp',
                 'Popu balb', 'Popu trem', 'Pseu_menm', 'Pseu_meng', 'Sali bebb',
                 'Sali scou', 'Sali spp', 'Thuj spp')


sppEquiv <- sppEquivalencies_CA[CASFRI %in% allSppCASFRI]
SASppToUse <- data.table::data.table(
  LandR = sppEquiv[, LandR],
  BC = c(FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE),
  AB = c(TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE),
  SK = c(TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, TRUE),
  MB = c(TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, TRUE),
  YT = c(FALSE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE),
  NT = c(FALSE, FALSE, TRUE, TRUE, FALSE,TRUE, TRUE, TRUE, FALSE, TRUE),
  NU = c(FALSE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, TRUE)
)
sAN <- studyarea

sim$sppEquiv <- sppEquiv[which(SASppToUse[, ..sAN][[1]]), ] ##subset per SA
sim$sppEquivCol <- "LandR"
rm(sppEquivalencies_CA)

#Assign colour
sim$sppColorVect <- LandR::sppColors(sppEquiv = sim$sppEquiv,
                                     sppEquivCol = sim$sppEquivCol,
                                     palette = "Paired")
mixed <- structure("#D0FB84", names = "Mixed")
sim$sppColorVect[length(sim$sppColorVect) + 1] <- mixed
attributes(sim$sppColorVect)$names[length(sim$sppColorVect)] <- "Mixed"

CASFRIpixDT<- data.table(pixelID = 1:ncell(CASFRIRas),
                         cas_id = getValues(CASFRIRas))
