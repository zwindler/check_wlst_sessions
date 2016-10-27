# check_wlst_sessions 1.0
Nagios compatible plugin to check via WLST the number of actives sessions on a Server (On Oracle WebLogic Server v9+)

##Usage
* check_weblogic_sessions [-v] [-d weblogic_home] [-U [protocol://]url:port] -u userid -p password -s server_name -w warning_concurrent_sessions -c critical_current_sessions
 - checks that the number of active user sessions doesn't exceed given warning and critical thresholds
 - warning_concurrent_sessions and critical_concurrent_sessions is a number of sessions, defaults being respectively 10 and 20
 - userid is a user with login capability to weblogic console, password is its password
 - server_name is the server (in weblogic sense, aka JVM app) to check
 - weblogic_home and url are both variables inside the script, respectively set to /wls_1033/wlserver_10.3/server and t3://localhost:7001. You may either change them of use the arguments (url should be ok)
 - add -v for verbose (debuging purpose)
* check_mem_ng.sh -V
 - prints version
* check_mem_ng.sh -h
 - prints help (this message)
 
##Output
./check_wlst_sessions.sh -u weblogic -p password -s SERVER_1 -w 15 -c 25
  OK: There are OpenSessionsCurrentCount=1 sessions on SERVER_1 | OpenSessionsCurrentCount=8;15;25;

./check_wlst_sessions.sh -v -u weblogic -p password -s SERVER_1 -w 15 -c 25
  Verbose mode ON
  
  Variables :
  WEBLOGIC_HOME : /appli/wls_1033/wlserver_10.3/server
  URL : t3://localhost:7001
  USERID : weblogic
  PASSWORD : password
  OBJECT_NAME :
  WARNING_THRESHOLD : 15
  CRITICAL_THRESHOLD : 25
  COUNT : 1 
  
  OK: There are Initializing WebLogic Scripting Tool (WLST) ... 
  Welcome to WebLogic Server Administration Scripting Shell 
  Type help() for help on available commands 
  Connecting to t3://localhost:7001 with userid weblogic ... 
  Successfully connected to Admin Server 'AdminServer' that belongs to domain 'xxx'. 
  Location changed to domainRuntime tree. 
  This is a read-only tree with DomainMBean as the root. 
  For more help, use help
  (domainRuntime) OpenSessionsCurrentCount=1 
  Disconnected from weblogic server: AdminServer 
  Exiting WebLogic Scripting Tool. 
