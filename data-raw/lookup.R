## code to prepare `lookup` dataset goes here

station_lookup <- c(
  "BOBO-DIOULASSO"   = "200099S",
  "BOGANDE"          = "200085S",
  "BOROMO"           = "200107S",
  "DEDOUGOU"         = "200054S",
  "DORI"             = "200026S",
  "FADA-NGOURMA"     = "200089S",
  "GAOUA-TONKAR"     = "200140S",
  "OUAGADOUGOU-AERO" = "200001S",
  "OUAHIGOUYA"       = "200035S",
  "PO"               = "200114S"
  # "VALLEE DU KOU"    = "",
  # "BEREGADOUGOU"     = "",
  # "DI-SOUROU"        = "",
  # "NIANGOLOKO"       = ""
)

element_lookup <- c(
  "Tn" = "TMIN",
  "Tx" = "TMAX",
  "Inso" = "SUND",
  "TnSol"  = "TNS",
  "TxSol"  = "TXS",
  "T-10" = "TS-10",
  "T-20" = "TS-20",
  "T-50" = "TS-50",
  "Un" = "UMIN",
  "Ux" = "UMAX",
  "e"   = "ED",
  "Vent" = "WMF",
  "RA"   = "RR",
  "PICHE"  = "EVP",
  "BAC"  = "EVA"
)

usethis::use_data(station_lookup, element_lookup, internal = TRUE)
