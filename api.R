library(plumber)
library(gigs)
library(jsonlite)

#* @apiTitle Prenatal Percentile API

#* @post /percentile
function(req){

  data <- fromJSON(req$postBody)

  value <- data$value
  ga_days <- data$ga_days
  param <- data$param

  cent <- value2centile(
    y = value,
    x = ga_days,
    family = "ig_fet",
    acronym = param
  )

  list(percentile = round(cent,1))
}