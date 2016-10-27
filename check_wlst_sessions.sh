#!/bin/sh
################################################################################
#check_wlst_sessions
#Nagios plugin to check via WLST the number of actives sessions on a Server (On 
#Oracle WebLogic Server v9+). 
#
#Inspired by outdated Weblogic.Admin plugin from Sergei Haramundanis, rewriten
#from scratch to add missing fonctionnalities, clean the code and to use 
#Weblogic.WLST
#
#BOTH check_wlst_sessions.sh and check_wlst_sessions.py are needed for this 
#plugin to work
#
# usage: check_wlst_sessions.sh [-d weblogic_home] [-U url] -u userid \
#    -p password -s server_name -w warning_concurrent_sessions \
#    -c critical_current_sessions
################################################################################
#See Weblogic Documentation for mon information on WLST if you want to modify
#this script to check other Weblogic parameters 
#http://docs.oracle.com/cd/E13222_01/wls/docs90/config_scripting/reference.html
################################################################################
#Nagios Constants
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
SCRIPTPATH=`echo $0 | /bin/sed -e 's,[\\/][^\\/][^\\/]*$,,'`
if [[ -f ${SCRIPTPATH}/utils.sh ]]; then
    . ${SCRIPTPATH}/utils.sh # use nagios utils to set real STATE_* return values
fi

#Useful functions
printversion(){
    echo "$0 $VERSION"
    echo 
}

printusage() {
    printversion
    echo "Nagios plugin to check via WLST the number of actives sessions on a "
    echo "Server (On Oracle WebLogic Server v9+)."
    echo
    echo "usage: 'check_weblogic_sessions [-v] [-d weblogic_home] [-U [protocol://]url:port] -u userid -p password -s server_name -w warning_concurrent_sessions -c critical_current_sessions'"
    echo "usage: 'check_weblogic_sessions -h' displays help"
    echo "usage: 'check_weblogic_sessions -V' displays version"
    echo
    echo "Default -U URL is t3://localhost:7001"
    echo "Default -d weblogic_home is $WEBLOGIC_HOME (script variable, change"
    echo "to fit to your needs)"
}

printvariables() {
    echo "Variables :"
    #Add all your variables at the en of the "for" line to display them in verbose
    for i in WEBLOGIC_HOME URL USERID PASSWORD OBJECT_NAME WARNING_THRESHOLD CRITICAL_THRESHOLD COUNT
        do
        echo -n "$i : "
        eval echo \$${i}
    done
    echo
}

#Set to unknown in case of unplaned exit
FINAL_STATE=$STATE_UNKNOWN
FINAL_COMMENT="UNKNOWN: Unplaned exit. You should check that everything is alright"

#Default values (should be changed according to context)
WARNING_THRESHOLD=10
CRITICAL_THRESHOLD=20
ENABLE_PERFDATA=1
VERSION="1.0"
#Use this variable if you don't want to pass weblogic_home as an argument
#WEBLOGIC_HOME="/appli/weblogic/server"
WEBLOGIC_HOME="/appli/wls_1033/wlserver_10.3/server"
URL="t3://localhost:7001"

while getopts ":c:d:hp:s:u:U:vVw:" opt; do
    case $opt in
        c)
            CRITICAL_THRESHOLD=$OPTARG
            ;;
        d)
            WEBLOGIC_HOME=$OPTARG
            ;;
        h)
            printusage
            exit $STATE_OK
            ;;
        p)
            PASSWORD=$OPTARG
            ;;
        s)
            SERVER_NAME=$OPTARG
            ;;
        u)
            USERID=$OPTARG
            ;;
        U)
            URL=$OPTARG
            ;;
        v)
            echo "Verbose mode ON"
            echo
            VERBOSE=1
            ;;
        V)
            printversion
            exit $STATE_UNKNOWN
            ;;
        w)
            WARNING_THRESHOLD=$OPTARG
            ;;
        \?)
            echo "UNKNOWN: Invalid option: -$OPTARG"
            exit $STATE_UNKNOWN
            ;;
        :)
            echo "UNKNOWN: Option -$OPTARG requires an argument."
            exit $STATE_UNKNOWN
        ;;
    esac
done

#Check all the mandatory arguments
if [[ -z $CRITICAL_THRESHOLD || -z $WARNING_THRESHOLD ]]; then
    echo "UNKNOWN: No warning or critical threshold given"
    printusage
    exit $STATE_UNKNOWN
fi

if [[ -z $USERID || -z $PASSWORD ]]; then
    echo "UNKNOWN: Missing Weblogic login or password"
    printusage
    exit $STATE_UNKNOWN
fi

if [[ -z $SERVER_NAME ]]; then
    echo "UNKNOWN: Missing Weblogic server name"
    printusage
    exit $STATE_UNKNOWN
fi

#Check Weblogic environement file
if [[ ! -f $WEBLOGIC_HOME/bin/setWLSEnv.sh ]] ; then  
    echo "CRITICAL: No file $WEBLOGIC_HOME/bin/setWLSEnv.sh found. Exiting"
    exit $STATE_CRITICAL
fi

#Set Weblogic environement variables
ENV_SCRIPT="$WEBLOGIC_HOME/bin/setWLSEnv.sh"
. $ENV_SCRIPT >/dev/null

#Let the real job begin
if [[ $VERBOSE -eq 1 ]] ; then
    CHECK_VALUE=`java weblogic.WLST $SCRIPTPATH/check_wlst_sessions.py $USERID $PASSWORD $URL $SERVER_NAME`
else
    CHECK_VALUE=`java weblogic.WLST $SCRIPTPATH/check_wlst_sessions.py $USERID $PASSWORD $URL $SERVER_NAME | grep "OpenSessionsCurrentCount"`
fi

if [[ $? -ne 0 ]]; then
    echo "CRITICAL: java weblogic.WLST failed. Use verbose to help debug the error"
    exit $STATE_CRITICAL
fi
COUNT=`echo $CHECK_VALUE | awk -F "=" '{print $2}'`

if [[ $COUNT -ge $CRITICAL_THRESHOLD ]]; then
    FINAL_COMMENT="CRITICAL: There are $CHECK_VALUE sessions on $SERVER_NAME!"
    FINAL_STATE=$STATE_CRITICAL
else
    if [[ $COUNT -ge $WARNING_THRESHOLD ]]; then
        FINAL_COMMENT="WARNING: There are $CHECK_VALUE sessions on $SERVER_NAME"
        FINAL_STATE=$STATE_WARNING
    else
        FINAL_COMMENT="OK: There are $CHECK_VALUE sessions on $SERVER_NAME"
        FINAL_STATE=$STATE_OK
    fi
fi

#Perfdata processing, if applicable
if [[ $ENABLE_PERFDATA -eq 1 ]] ; then
    PERFDATA=" | $CHECK_VALUE;$WARNING_THRESHOLD;$CRITICAL_THRESHOLD;"
fi

#Script end, display verbose information
if [[ $VERBOSE -eq 1 ]] ; then
    printvariables
fi

echo ${FINAL_COMMENT}${PERFDATA}
exit $FINAL_STATE
