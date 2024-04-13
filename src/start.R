#
# start.R
#

backend = BackendRserve$new(
    content_type = 'application/json'
)

backend$start(application,
              http_port = 8001,
              encoding = "utf8",
              port = 6311,
              daemon = "disable",
              pid.file = "Rserve.pid")


