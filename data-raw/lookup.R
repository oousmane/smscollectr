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
  "PO"               = "200114S",
  "VALLEE-DU-KOU"    = "200149A",
  "BEREGADOUGOU"     = "200153A",
  "DI-SOUROU"        = "200029A",
  "NIANGOLOKO"       = "200133A",
  "BAGRE"            = "200167A",
  "KOMPIENGA"        = "200286A",
  "MARKOYE"          = "200027A",
  "BAM-TOURCOING"    = "200043A",
  "NOUNA"            = "200053A",
  "SARIA"            = "200065A",
  "KAMBOINCE"        = "200072A",
  "MOGTEDO"          = "200080A",
  "BOULSA"           = "200082A",
  "FARAKO-BA"        = "200098A",
  "MANGA"            = "200115A",
  "PAMA"             = "200125A",
  "LOUMANA"          = "200129A",
  "BATIE"            = "200144A",
  "NDOROLA"          = "200147A",
  "BAZEGA"           = "200152A",
  "KIE"              = "200161A",
  "KASSOU"           = "200162A"
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

usethis::use_data(
  station_lookup,
  element_lookup, 
  internal = TRUE, overwrite = TRUE
  )
