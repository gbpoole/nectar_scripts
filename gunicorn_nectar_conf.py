from multiprocessing import cpu_count

# Socket Path
bind = 'unix:/home/ubuntu/gunicorn.sock'

# Worker Options
workers = cpu_count() + 1
worker_class = 'uvicorn.workers.UvicornWorker'

# Logging Options
loglevel  = 'debug'
accesslog = '/home/ubuntu/access_log.txt'
errorlog  = '/home/ubuntu/error_log.txt'
