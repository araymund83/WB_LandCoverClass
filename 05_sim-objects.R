###############################################################################
## additional simulation object definitions
################################################################################
  data("sppEquivalencies_CA", package = "LandR")
  sppEquivalencies_CA[grep("Pin", LandR), `:=`(EN_generic_short = "Pine",
                                               EN_generic_full = "Pine",
                                               Leading = "Pine leading")]
  
  
  ## Make WB spp equivalences 
  sppEquivCol <- "WB"
  data("sppEquivalencies_CA", package = "LandR")
  # sppEquivalencies_CA[grep("Pin", LandR), `:=`(EN_generic_short = "Pine",
  #                                              EN_generic_full = "Pine",
  #                                              Leading = "Pine leading")]
  
  sppEquivalencies_CA[, WB := c(Pice_Mar = "Pice_mar", Pice_Gla = "Pice_gla",
                                Pinu_Con = "Pinu_con", Popu_Tre = "Popu_tre",
                                Popu_Bal = "Popu_bal", Lari_Lar = "Lari_lar",
                                Pinu_Ban = "Pinu_ban", Betu_Pap = "Betu_pap",
                                Abie_Las = "Abie_las", Abie_Bal = "Abie_bal")[Boreal]]
  
  sppEquivalencies_CA <- sppEquivalencies_CA[!LANDIS_traits == "PINU.CON.CON"]
  
  sppEquivalencies_CA[AB == "Abie_Las", EN_generic_full := "Subalpine Fir"]
  sppEquivalencies_CA[AB == "Abie_Las", EN_generic_short := "Fir"]
  sppEquivalencies_CA[AB == "Abie_Las", Leading := "Fir leading"]
  sppEquivalencies_CA[AB == "Popu_Tre", Leading := "Pop leading"]
  sppEquivalencies_CA[AB == "Betu_Pap", EN_generic_short := "Betula"]
  sppEquivalencies_CA[AB == "Betu_Pap",  Leading := "Betula leading"]
  sppEquivalencies_CA[AB == "Betu_Pap",  EN_generic_full := "Paper birch"]
  
  sppEquivalencies_CA$EN_generic_short <- sppEquivalencies_CA$WB
  
  sppEquivalencies_CA <- sppEquivalencies_CA[!is.na(WB)]
  sppEquivalencies_CA[WB == "Pinu_con", KNN := "Pinu_Con"]
  
  #Assign colour
  sppColorVect <- LandR::sppColors(sppEquiv = sppEquivalencies_CA, 
                                   sppEquivCol = sppEquivCol,
                                   palette = "Set3")
  
  
  