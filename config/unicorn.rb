# <html>
# <head><title>301 Moved Permanently</title></head>
# <body bgcolor="white">
# <center><h1>301 Moved Permanently</h1></center>
# <hr><center>nginx/1.0.4</center>
# </body>
# </html>

APP_PATH = "/opt/app/current"
working_directory APP_PATH

stdeer_path APP_PATH + "/opt/logs/unicorn.stderr.log"
stdout_path APP_PATH + "/opt/logs/unicorn.stderr.log"

pid APP_PATH + "/opt/pids/unicorn.pid"