# Gunicorn configuration for Nectar deployment

from multiprocessing import cpu_count

# Worker Options
workers = cpu_count() + 1
worker_class = 'uvicorn.workers.UvicornWorker'

# Non logging stuff
bind = "0.0.0.0:8080"

# Access log - records incoming HTTP requests
accesslog = "/home/ubuntu/gunicorn.access.log"

# Error log - records Gunicorn server goings-on
errorlog = "/home/ubuntu/gunicorn.error.log"

# Whether to send application output to the error log
capture_output = True

# How verbose the Gunicorn error logs should be
loglevel = "info"
