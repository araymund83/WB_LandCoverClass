###############################################################################
## additional simulation object definitions
################################################################################
# library(data.table)
# library(magrittr)

if (studyarea == "WB") {
  
  data("sppEquivalencies_CA", package = "LandR")
  sppEquivalencies_CA[grep("Pin", LandR), `:=`(EN_generic_short = "Pine",
                                               EN_generic_full = "Pine",
                                               Leading = "Pine leading")]
  
  
  ## Make AB spp equivalences 
  sppEquivCol <- "AB"
  data("sppEquivalencies_CA", package = "LandR")
  # sppEquivalencies_CA[grep("Pin", LandR), `:=`(EN_generic_short = "Pine",
  #                                              EN_generic_full = "Pine",
  #                                              Leading = "Pine leading")]
  
  # Make spp equivalencies based on Cadieux et al. 2020
  sppEquivalencies_CA[, AB := c( Popu_Tre = "Popu_tre", Pice_Gla = "Pice_gla",
                                 Popu_Bal = "Popu_bal", Lari_Lar = "Lari_lar",
                                 Pinu_Ban = "Pinu_ban", Pinu_Con = "Pinu_con",
                                 Pice_Mar = "Pice_mar", Betu_Pap = "Betu_pap", 
                                 Abie_Bal = "Abie_bal")[Boreal]]
  
  sppEquivalencies_CA <- sppEquivalencies_CA[!LANDIS_traits == "PINU.CON.CON"]
  
  # sppEquivalencies_CA[AB == "Abie_sp", EN_generic_full := " Fir"]
  # sppEquivalencies_CA[AB == "Abie_sp", EN_generic_short := "Fir"]
  # sppEquivalencies_CA[AB == "Abie_sp", Leading := "Fir leading"]
  # sppEquivalencies_CA[AB == "Popu_Tre", Leading := "Pop leading"]
  # sppEquivalencies_CA[AB == "Betu_Pap", EN_generic_short := "Betula"]
  # sppEquivalencies_CA[AB == "Betu_Pap",  Leading := "Betula leading"]
  # sppEquivalencies_CA[AB == "Betu_Pap",  EN_generic_full := "Paper birch"]
  
  sppEquivalencies_CA$EN_generic_short <- sppEquivalencies_CA$AB
  
  sppEquivalencies_CA <- sppEquivalencies_CA[!is.na(AB)]
  sppEquivalencies_CA
  
}