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