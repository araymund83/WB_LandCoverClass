do.call(SpaDES.core::setPaths, paths2a)

objects2a <- list(
    "cloudFolderID" = cloudFolderID,
    "rstLCC" = rstLCC,
    "rasterToMatch" = rasterToMatch,
    "rasterToMatchLarge" = rasterToMatchLarge,
    "speciesLayers" = simOutSppLayers[["speciesLayers"]],
    "sppEquiv" = sppEquivalencies_CA,
    "studyArea" = studyArea,
    "studyAreaLarge" = studyAreaLarge)
  

parameters2a <- list(
  Biomass_borealDataPrep = list(
    "sppEquivCol" = sppEquivCol,
    "speciesUpdateFunction" = list(
      quote(LandR::speciesTableUpdate(sim$species, sim$speciesTable,
                                      sim$sppEquiv, P(sim)$sppEquivCol)),
      quote(LandR::updateSpeciesTable(sim$species, sim$speciesParams))
      )
    ## ### MAKE SURE of closing the list in the right plaCE!!!!!!!
    , "forestedLCCClasses" =  forestedLCCClasses
    , "LCCClassesToReplaceNN" = 34:36
    , ".useCache" = c(".inputObjects", "init")
    #, "runName" = runName
    #, "standAgeMap" = simOutPreamble$standAgeMap2011
    #, "rawBiomassMap" = simOutPreamble$rawbiomassMap2011
    #, "speciesLayers" = simOutPreamble$speciesLayers2011
    , "successionTimestep" = 10
    , "subsetDataBiomassModel" = 10
    , "useCloudCacheForStats" = TRUE
    , ".useCache" = c(".inputObjects", "init")
    , "exportModels" = "all"
    , "pixelGroupAgeClass" = 10)
,
   scfmLandcoverInit = list(
     ".plotInitialTime" = NA
#     #"fireRegimePolys" = simOutPreamble$fireRegimePolygons,
#     #"sliverThreshold" = 1e10
# 
   ),
   scfmRegime = list(
     fireCause = "L",
#     #"targetBurnRate" = 1/65,
     "fireEpoch" = fireEpoch
   )
#   # scfmDriver = list(
#   #   "studyArea" = simOutPreamble$studyAreaReporting,
#   #   "fireRegimeRas" = simOutSppLayers$fireRegimeRas,
#   #   "fireRegimPolys" = simOutSppLayers$fireRegimePolys,
#   #   "scfmRegimePars" = simOutSppLayers$scfmRegimePars,
#   #   "landscapeAttr" = simOutSppLayers$landscapeAttr,
#   #   "flammableMap" = simOutSppLayers$flammableMap,
#   #   ".useParallel" = FALSE,
#   #   "quickCalibration" = FALSE
#   #
#   # )
 )

dataPrepFile <- file.path(Paths$inputPath, paste0("simOutDataPrep_", studyarea, ".qs"))
# speciesModules <- c("PSP_Clean", "Biomass_speciesData", "Biomass_borealDataPrep",
#                     "Biomass_speciesParameters", "scfmLandcoverInit", "scfmRegime")

simOutDataPrep <- Cache(simInitAndSpades,
                         times = list(start = simTimes$start, end = simTimes$start + 1)
                         , params = parameters2a
                         , modules = c("Biomass_borealDataPrep","scfmLandcoverInit", "scfmRegime")
                         , objects = objects2a
                         , paths = paths2a
                         , debug = TRUE
                         , .plotInitialTime = NA
                        )
saveSimList(simOutSppLayersDataPrep, dataPrepFile)

scfmDriverObjs <- list(
  'studyArea' = simOutPreamble$studyArea,
  'fireRegimeRas' = simOutSppLayers$fireRegimeRas,
  'fireRegimePolys' = simOutSppLayers$fireRegimePolys,
  'scfmRegimePars' = simOutSppLayers$scfmRegimePars,
  'landscapeAttr' = simOutSppLayers$landscapeAttr,
  'flammableMap' = simOutSppPreamble$flammabilityMap
)
