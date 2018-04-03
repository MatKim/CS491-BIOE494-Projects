import time
def follow(thefile):
    thefile.seek(0,2)
    while True:
        line = thefile.readline()
        print (line)
        if not line:
            time.sleep(0.02)
            continue
        yield line

if __name__ == '__main__':
    logfile = open("sketch_180403d/datat.txt","r")
    loglines = follow(logfile)
    for line in loglines:
        print line,
