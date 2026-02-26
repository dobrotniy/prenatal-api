#* Fetal biometry analysis (INTERGROWTH-21st + Hadlock-3)
#* @post /analyze
#* @param ga:integer Gestational age in weeks
#* @param bpd:numeric Biparietal diameter (mm)
#* @param hc:numeric Head circumference (mm)
#* @param ac:numeric Abdominal circumference (mm)
#* @param fl:numeric Femur length (mm)
#* @serializer json
function(ga, bpd = NA, hc = NA, ac = NA, fl = NA) {

  library(gigs)

  ga_days <- as.numeric(ga) * 7

  if (ga_days < 98 || ga_days > 287) {
    stop("GA outside INTERGROWTH fetal range (98–287 days)")
  }

  result <- list()
  calc_param <- function(value, acronym) {
    list(
      percentile = round(
        gigs::value2centile(
          y = value,
          x = ga_days,
          family = "ig_fet",
          acronym = acronym
        ) * 100, 2),
      zscore = round(
        gigs::value2zscore(
          y = value,
          x = ga_days,
          family = "ig_fet",
          acronym = acronym
        ), 3)
    )
  }

  # --- BPD ---
  if (!is.na(bpd)) {
    result$bpd <- calc_param(as.numeric(bpd), "bpdfga")
  }

  # --- HC ---
  if (!is.na(hc)) {
    result$hc <- calc_param(as.numeric(hc), "hcfga")
  }

  # --- AC ---
  if (!is.na(ac)) {
    result$ac <- calc_param(as.numeric(ac), "acfga")
  }

  # --- FL ---
  if (!is.na(fl)) {
    result$fl <- calc_param(as.numeric(fl), "flfga")
  }

  # --- EFW (Hadlock-3) ---
  if (!is.na(hc) && !is.na(ac) && !is.na(fl)) {

    # перевод в сантиметры
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
          x = ga_days,
          family = "ig_fet",
          acronym = "hefwfga"
        ) * 100, 2),
      zscore = round(
        gigs::value2zscore(
          y = efw,
          x = ga_days,
          family = "ig_fet",
          acronym = "hefwfga"
        ), 3)
    )
  }

  result$ga_weeks <- ga
  result$ga_days <- ga_days

  return(result)
}