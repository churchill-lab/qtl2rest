#
# run.R
#

# load the R data into GlobalEnv
message("Sourcing: /app/qtl2rest/load.R")
source("/app/qtl2rest/load.R")

# define the base functionaloty from qtl2api
message("Sourcing: /app/qtl2rest/base.R")
source("/app/qtl2rest/base.R")

# override any functionality
message("Sourcing: /app/qtl2rest/plugins.R")
source("/app/qtl2rest/plugins.R")

# define the RServe application
message("Sourcing: /app/qtl2rest/application.R")
source("/app/qtl2rest/application.R")

# define the base API HTTP calls
message("Sourcing: /app/qtl2rest/restapi.R")
source("/app/qtl2rest/restapi.R")

# define or override custom API HTTP calls
message("Sourcing: /app/qtl2rest/custom.R")
source("/app/qtl2rest/custom.R")

# start the server
message("Sourcing: /app/qtl2rest/start.R")
source("/app/qtl2rest/start.R")


