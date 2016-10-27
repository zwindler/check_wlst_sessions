import sys
connect(sys.argv[1],sys.argv[2],sys.argv[3])
count=0
domainRuntime()
cd("/ServerRuntimes/"+sys.argv[4])
apps=cmo.getApplicationRuntimes()
for app in apps:
    comps=app.getComponentRuntimes()
    for comp in comps:
        if comp.getType() == 'WebAppComponentRuntime':
            count+=comp.getOpenSessionsCurrentCount()
print "OpenSessionsCurrentCount="+str(count)
disconnect()
exit()
