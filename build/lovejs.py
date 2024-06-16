import sys
import os

os.system("love.js -c -t {0} -m {1} {2}/love/{0}.love {2}/web".format(sys.argv[1], sys.argv[2], sys.argv[3]))

# Read in the file
with open(sys.argv[3] + "/web/index.html", 'r') as file :
  filedata = file.read()

# Replace the target string
filedata = filedata.replace('{LOADING_WIDTH}', sys.argv[4])
filedata = filedata.replace('{LOADING_HEIGHT}', sys.argv[5])

# Write the file out again
with open(sys.argv[3] + "/web/index.html", 'w') as file:
  file.write(filedata)