# Use Template from https://github.com/sol-eng/plumber-logging

library(plumber)

# Config
log_dir = here::here("logs")

# logging
library(logger)
# Ensure glue is a specific dependency so it's avaible for logger
library(glue)

# Specify how logs are written 
if (!fs::dir_exists(log_dir)) fs::dir_create(log_dir)
log_appender(appender_tee(tempfile("plumber_", log_dir, ".log")))

convert_empty <- function(string) {
  if (string == "") {
    "-"
  } else {
    string
  }
}

pr <- plumb(here::here("plumber","plumber.R"))

pr$registerHooks(
  list(
    preroute = function() {
      # Start timer for log info
      tictoc::tic()
    },
    postroute = function(req, res) {
      end <- tictoc::toc(quiet = TRUE)
      # Log details about the request and the response
      log_info('{convert_empty(Sys.info()["nodename"])} {convert_empty(req$REMOTE_ADDR)} "{convert_empty(req$HTTP_USER_AGENT)}" {convert_empty(req$HTTP_HOST)} {convert_empty(req$REQUEST_METHOD)} {convert_empty(req$PATH_INFO)} {convert_empty(res$status)} {round(end$toc - end$tic, digits = getOption("digits", 5))}')
    }
  )
)

pr
