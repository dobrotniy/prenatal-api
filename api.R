#* @filter cors
function(req, res){
  res$setHeader("Access-Control-Allow-Origin", "*")
  res$setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
  res$setHeader("Access-Control-Allow-Headers", "Content-Type")
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$status <- 200
    return(list())
  }
  plumber::forward()
}

#* Fetal biometry analysis (INTERGROWTH-21st + Hadlock-3)
#* @post /analyze
#* @param ga_weeks:integer Gestational age (weeks)
#* @param ga_days:integer Additional days (0–6)
#* @param bpd:numeric Biparietal diameter (mm)
#* @param hc:numeric Head circumference (mm)
#* @param ac:numeric Abdominal circumference (mm)
#* @param fl:numeric Femur length (mm)
#* @serializer json
function(ga_weeks, ga_days = 0, bpd = NA, hc = NA, ac = NA, fl = NA, efw_manual = NA) {

  library(gigs)

  ga_total_days <- as.numeric(ga_weeks) * 7 + as.numeric(ga_days)

  if (ga_total_days < 98) {
    stop("GA below INTERGROWTH fetal range (min 98 days)")
  }

  result <- list()

  calc_param <- function(value, acronym) {
    list(
      percentile = round(
        gigs::value2centile(
          y = value,
          x = ga_total_days,
          family = "ig_fet",
          acronym = acronym
        ) * 100, 2),
      zscore = round(
        gigs::value2zscore(
          y = value,
          x = ga_total_days,
          family = "ig_fet",
          acronym = acronym
        ), 3)
    )
  }

  # --- BPD (98–280) ---
  if (!is.na(bpd)) {
    if (ga_total_days > 280) {
      stop("BPD valid only up to 280 days GA")
    }
    result$bpd <- calc_param(as.numeric(bpd), "bpdfga")
  }

  # --- HC (98–280) ---
  if (!is.na(hc)) {
    if (ga_total_days > 280) {
      stop("HC valid only up to 280 days GA")
    }
    result$hc <- calc_param(as.numeric(hc), "hcfga")
  }

  # --- AC (98–280) ---
  if (!is.na(ac)) {
    if (ga_total_days > 280) {
      stop("AC valid only up to 280 days GA")
    }
    result$ac <- calc_param(as.numeric(ac), "acfga")
  }

  # --- FL (98–280) ---
  if (!is.na(fl)) {
    if (ga_total_days > 280) {
      stop("FL valid only up to 280 days GA")
    }
    result$fl <- calc_param(as.numeric(fl), "flfga")
  }

  # --- EFW (Hadlock-3, 126–287) ---
  if (!is.na(hc) && !is.na(ac) && !is.na(fl)) {

    if (ga_total_days < 126 || ga_total_days > 287) {
      stop("EFW valid only between 126–287 days GA")
    }

    hc_cm <- as.numeric(hc) / 10
    ac_cm <- as.numeric(ac) / 10
    fl_cm <- as.numeric(fl) / 10

    log10_efw <- 1.326 +
      0.0107 * hc_cm +
      0.0438 * ac_cm +
      0.158 * fl_cm -
      0.00326 * ac_cm * fl_cm

    efw <- 10^log10_efw

    result$efw <- list(
      value = round(efw, 0),
      percentile = round(
        gigs::value2centile(
          y = efw,
          x = ga_total_days,
          family = "ig_fet",
          acronym = "hefwfga"
        ) * 100, 2),
      zscore = round(
        gigs::value2zscore(
          y = efw,
          x = ga_total_days,
          family = "ig_fet",
          acronym = "hefwfga"
        ), 3)
    )
  }

  # --- Manual EFW (126–287) ---
  if (!is.na(efw_manual)) {

  if (ga_total_days < 126 || ga_total_days > 287) {
    stop("EFW valid only between 126–287 days GA")
  }

  result$efw_manual <- list(
    value = as.numeric(efw_manual),
    percentile = round(
      gigs::value2centile(
        y = as.numeric(efw_manual),
        x = ga_total_days,
        family = "ig_fet",
        acronym = "hefwfga"
      ) * 100, 2),
    zscore = round(
      gigs::value2zscore(
        y = as.numeric(efw_manual),
        x = ga_total_days,
        family = "ig_fet",
        acronym = "hefwfga"
      ), 3)
  )
}
  result$ga_weeks <- ga_weeks
  result$ga_days <- ga_days
  result$ga_total_days <- ga_total_days

  return(result)
}