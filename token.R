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

generateToken <- function() {

  # Initial checks
  if (!require("pacman")) install.packages("pacman")
  pacman::p_load(rdrop2, httpuv, curl)
  if (!curl::has_internet()) stop("Please connect to the internet!")

  # Token generation
  token <- drop_auth(new_user = TRUE)
  saveRDS(token, "ee977806d7286510da")
  return(print(paste0("Token saved in ", getwd())))
  
}
