#* Calculate fetal biometric percentile (INTERGROWTH-21st Fetal Standards)
#* @post /percentile
#* @param ga:integer Gestational age in weeks
#* @param param:string One of BPD, HC, AC, FL, EFW
#* @param value:numeric Measurement value (mm for biometry, g for EFW)
#* @serializer json
function(ga, param, value) {

  library(gigs)

  ga_days <- as.numeric(ga) * 7
  param <- toupper(param)

  map <- list(
    BPD = list(acronym="bpdfga", min=98,  max=280),
    HC  = list(acronym="hcfga",  min=98,  max=280),
    AC  = list(acronym="acfga",  min=98,  max=280),
    FL  = list(acronym="flfga",  min=98,  max=280),
    EFW = list(acronym="hefwfga", min=126, max=287)
  )

  if (is.null(map[[param]])) {
    stop("Invalid parameter. Use BPD, HC, AC, FL or EFW.")
  }

  acronym <- map[[param]]$acronym
  min_days <- map[[param]]$min
  max_days <- map[[param]]$max

  if (ga_days < min_days || ga_days > max_days) {
    stop(
      paste0(
        "GA out of INTERGROWTH range for ", param,
        " (", min_days, "–", max_days, " days)"
      )
    )
  }

  cent <- gigs::value2centile(
    y = as.numeric(value),
    x = ga_days,
    family = "ig_fet",
    acronym = acronym
  )

  z <- gigs::value2zscore(
    y = as.numeric(value),
    x = ga_days,
    family = "ig_fet",
    acronym = acronym
  )

  list(
    parameter = param,
    ga_weeks = ga,
    ga_days = ga_days,
    value = value,
    percentile = round(cent * 100, 2),
    zscore = round(z, 3)
  )
}