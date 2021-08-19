#-------------------------------------------------------------------------------
# Token generator for SForm by Linn Friberg (https://github.com/linfri)
#-------------------------------------------------------------------------------

#' @title generateToken()
#'
#' @description
#' Generates Dropbox token in the current folder.
#' 
#' @return 
#' Returns a text message after generation.
#'
#'

library(rdrop2)
library(httpuv) # just in case, if rdrop2 acts up
library(curl)

generateToken <- function() {
  if(!curl::has_internet()) stop("Please connect to the internet!")
  token <- drop_auth(new_user = TRUE)
  saveRDS(token, "ee977806d7286510da")
  return(print(paste0("Token saved in ", getwd())))
}
