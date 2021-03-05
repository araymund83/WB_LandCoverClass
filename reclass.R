## Add the pixel number to the cohortData
pixelCohortData <- LandR::addNoPixel2CohortData(outSimSppLayers$cohortData, 
                                                outSimSppLayers$pixelGroupMap,
                                                doAssertion = getOption("LandR.assertions", TRUE))

##Add vegetation type column to the cohortData table
vegTypeTable <- LandR::vegTypeGenerator(pixelCohortData, vegLeadingProportion = 0.8,
                                        mixedType = 2, sppEquiv = sppEquivalencies_CA,
                                        sppEquivCol = "WB", pixelGroupColName = "pixelGroup")
vegTypeTable2 <- LandR::vegTypeGenerator(pixelCohortData, vegLeadingProportion = 0.8,
                                        mixedType = 2, sppEquiv = sppEquivalencies_CA,
                                        sppEquivCol = "WB", pixelGroupColName = "pixelGroup")


vegTypeMap<- LandR::vegTypeMapGenerator(pixelCohortData, vegLeadingProportion = 0.8,
                                        mixedType = 2, sppEquiv = sppEquivalencies_CA,
                                        pixelGroupMap = outSimSppLayers$pixelGroupMap,
                                        sppEquivCol = "WB", pixelGroupColName = "pixelGroup")

##subset the pixelCohortData and create a new column with the max age per pixelGroup
newAgeCD <- vegTypeTable[,list(ageMax = max(age)), by = "pixelGroup"]

##apply reclass function to the subset data.table
newAgeCD <- ageReclass(newAgeCD)

## create a new  RasterLayer of Age reclassified
ageGroupRas <- rasterizeReduced(reduced = newAgeCD, 
                              fullRaster = outSimSppLayers[["pixelGroupMap"]],
                              mapcode = "pixelGroup", newRasterCols =  "ageGroup")

## subset the pixelCohortData and create a new column with the sum of Biomass(B) 
## per pixelGroup and RelB per pixelGroup & speciesCode
sumBCD <- vegTypeTable[, list(sumB = sum(B)),
                                  by =  "pixelGroup"]

## create the sumB RasterLayer
sumBRas <- rasterizeReduced(reduced = sumBCD, 
                            fullRaster = outSimSppLayers[["pixelGroupMap"]],
                            mapcode = "pixelGroup", newRasterCols =  "sumB")
## subset the pixelCohortData and create a new column with the sum of Biomass(B) & relB 
## per pixelGroup and RelB per pixelGroup & speciesCode
vegTypeTable2[, sumB := sum(B), by =.(pixelGroup)]
vegTypeTable2[, relB := sum(B)/sumB, by =.(pixelGroup, speciesCode)]
vegTypeTable2[is.na(relB) & sumB == 0, relB := 0]

if(any(is.na(vegTypeTable2$relB)))
   stop("Missing values in relative Biomass")

##subset to a smaller DT 
vegTypes <- unique(vegTypeTable2[B > 0, .(pixelGroup,speciesCode, relB, sumB)])

vegTypes$vegClass <- ifelse(vegTypes$speciesCode %in% c("Pinu_ban", "Pinu_con") & 
  sum(vegTypes$relB >= pureCutoff)
  & vegTypes$speciesCode %in% c("Popu_tre", "Popu_bal","Betu_pap","Abie_las","Abie_bal")
  & sum(vegTypes$relB >= .20), "pine",
  ifelse(vegTypes$speciesCode %in% c("Pice_mar") &  sum(vegTypes$relB >= pureCutoff) &
         vegTypes$speciesCode %in% deciSp & sum(vegTypes$relB >= 0.2), "BkSp",
  ifelse(vegTypes$speciesCode %in% c("Pice_gla", "Abis_bal") & sum(vegTypes$relB >= pureCutoff), "WhSp",
  ifelse(vegTypes$speciesCode %in% c("Popu_tre", "Popu_bal", "Betu_pap") & sum(vegTypes$relB >= pureCutoff), "Deciduous",
  ifelse(vegTypes$speciesCode %in% c("Popu_tre", "Popu_bal", "Betu_pap") & sum(vegTypes$relB >= .20), "Mixedwood",
  ifelse(vegTypes$speciesCode %in% c("Pice_mar") & sum(vegTypes$relB >= pureCutoff), "wetland", "NonVeg"))))))       


a <- vegTypes[ , list(vegClass), by = "pixelGroup"]   
rasterTemplate <- outSimSppLayers$pixelGroupMap
rasterTemplate[!is.na(rasterTemplate)] <- 0

r <- SpaDES.tools::rasterizeReduced(reduced = a, 
                                    fullRaster = vegTypes$pixelGroup,
                                    mapcode = "pixelGroup", newRasterCols = "vegClass")

if (studyArea == "ABBC"){
 
 convertToVegType <- function(DT, groupingCol = "pixelGroup", pureCutoff = 0.8,
                              deciSp = c("Popu_tre", "Popu_bal","Betu_pap","Abie_las",
                                         "Abie_bal"),
                              coniSp = c("Pinu_ban","Pinu_con", "Abie_bal")){
   setkeyv(DT, cols = groupingCol)
   cols <- c("speciesCode", "relB")
  browser()
##Pine dominant : dominated by Pinu_ban(jackpine) &/or Pinu_con (Lodgepole pine) > 80%
## deciduous species less than 20% 
  DT[, pine :=  all(.sumRelBs(c("Pinu_ban","Pinu_con"), .SD) >= pureCutoff,
                    .sumRelBs(c('Popu_tre', 'Popu_bal','Betu_pap','Abie_las',
                                  'Abie_bal'), .SD < 0.2)),
                by = pixelGroup, .SDcols = cols]
##Black Spruce (BkSp): dominated by Pice_mar (black spruce) > 80%
  DT[, BkSp:= all(.sumRelBs("Pice_mar", .SD) >= pureCutoff,
                    .sumRelBs(deciSp), .SD > 0),
                 by = pixelGroup, .SDcols = cols]
   
##White Spruce (WhSp): dominated by Pice_gla (white spruce) & Abis_bal (balsam fir) > 80%   
  DT[, WhSp:= all(.sumRelBs(c("Pice_gla", "Abis_bal"), .SD) >= pureCutoff),
                 by = pixelGroup, .SDcols = cols]
##Deciduous : Popu_tre(trembling aspen) &/or Popu_bal (balsam poplar) &/or 
##Betu_pap(white birch) > 80%   
  DT[, deciduous:= all(.sumRelBs(c("Popu_tre","Popu_bal", "Betu_pap"),
                                            .SD) >= pureCutoff,
                       .sumRelBs(deciSp), .SD < 0.2),
                 by = pixelGroup, .SDcols = cols]
   
##Mixedwood : Deciduous species more than 20%   
  DT[, mixedwood:= all(.sumRelBs(c("Popu_tre","Popu_bal", "Betu_pap"),
                                            .SD) >= 0.20,
                       .sumRelBs(c(coniSp, "Pice_gla", "Pice_mar"), .SD < 0.2)),
                 by = pixelGroup, .SDcols = cols]
##Wetland :Black spruce dominated and  Deciduous species more than 20%    
  DT[, wetland:= all(.sumRelBs("Pice_mar", .SD) >= pureCutoff),
                 by = pixelGroup, .SDcols = cols]
 } 
  
}

#' internal function that sums relative biomasses for species matching a character string,
#' but that can be appear duplicated in another species coding column.
#' @param sppToMatch character string of species to match against for summing B.
#' @param DT data.table with columns 'speciesCode', 'relB'.
.sumRelBs <- function(sppToMatch, DT) {
  browser()
    DT[speciesCode %in% sppToMatch] %>%
  
    .[, .(speciesCode, relB)] %>%
    unique(.) %>%
    .$relB %>%
    sum(.)
}

out <- convertToVegType(DT = vegTypes,
            groupingCol = "pixelGroup")


