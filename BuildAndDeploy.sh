#!/usr/bin/ksh

##############################################################
#                                                            #
#       Description : CCE WAS server                         #
#       Author 		: Akshay MS                              #
#       Team 		: CCE level 3                            #
#       Usage 		: updateccepatch.sh                      #
#                                                            #
##############################################################

OPTN1=$1
host1=`hostname`
loginname=`whoami`
orig=$SECONDS
# --- User Functions ---
usage () {
        echo "  Usage :  updateccepatch.sh  [ cce / uc  ]"
}
callClear() {
        case $wcinstances in
                "cce")
                        nahostme=$nmhost
                        instnces="cce"
                        deployjar
                        ;;
                "uc")
                        nahostme=$nmhost
                        instnces="uc"
                        deployjar
                        ;;
                *)
                        echo " unknown wc instances "
                        ;;
        esac

}

deployjar() {
        countinst=${#instnces[*]}
        if [ $countinst -eq 1 ]; then
                for clearalls in ${instnces}
                {
                        case $clearalls
                        in
                                "uc")
                                        echo ""
										cd /uc/lib/
										cp ccepatch.jar backup/ccepatch.jar-`date +"%m-%d-%Y-at%T"`
										echo ""
										echo "Back-up of ccepatch.jar is taken. "
										echo ""
										
										cd /home/wasuser/deploy/jar/
										rm -r *
										jar -xvf ../*.jar
										echo ""
										echo "Given file is extracted."
										echo ""
										
										cp /uc/lib/ccepatch.jar /home/wasuser/deploy/jar/.
										cd /home/wasuser/deploy/jar/
										jar -uvf ccepatch.jar *
										echo ""
										echo "ccepatch.jar updated."
                                        echo ""
                                        
										cp ccepatch.jar /home/wasuser/akshay/.
										echo "Restarting $nahostme-$wcinstances Server... "
										echo ""
										cd /usr/WebSphere/AppServer/profiles/uc/bin
										stopServer.sh server1
										startServer.sh server1
										
										/usr/WebSphere/AppServer/profiles/uc/logs/
										chmod -R 755 server1
										
										echo ""
										echo "$nahostme-$wcinstances Server Restarted."
										echo "Jar deployed in $nahostme-$wcinstances !! "
                                        ;;
                                "cce")
                                        echo ""
										cd /cce/lib
										cp ccepatch.jar backup/ccepatch.jar-`date +"%m-%d-%Y-at%T"`
										echo ""
										echo "Back-up of ccepatch.jar is taken. "
										echo ""
										
										cd /home/wasuser/deploy/jar/
										rm -r *
										jar -xvf ../*.jar
										echo ""
										echo "Given file is extracted."
										echo ""
										
										cp /cce/lib/ccepatch.jar /home/wasuser/deploy/jar/.
										cd /home/wasuser/deploy/jar/
										jar -uvf ccepatch.jar *
										echo ""
										echo "ccepatch.jar updated."
                                        echo ""
                                        
										cp ccepatch.jar /home/wasuser/akshay/.
										echo "Restarting $nahostme-$wcinstances Server... "
										echo ""
										cd /usr/WebSphere/AppServer/profiles/cce/bin
										stopServer.sh server1
										startServer.sh server1
										
										cd /usr/WebSphere/AppServer/profiles/cce/logs/
										chmod -R 755 server1
										
										echo ""
										echo "$nahostme-$wcinstances Server Restarted."
										echo "Jar deployed in $nahostme-$wcinstances !! "
                                        ;;
                                
                                *)
                                        echo " unknown wc instance "
                                ;;
                        esac
                }
        fi

}


# --- Main ---
case $loginname
        in
        "wasuser")
                continue
                ;;
        *)
                echo " Please login as wasuser , and retry "
                exit 1
        ;;
esac


if [ -z "$OPTN1" ]; then
        usage
        exit 1
fi


case $host1
        in
            "cce-l3-emea"|"cce-l3-na"|"cce-l3-na-pre")
                        nmhost=$host1
                        wcinstances=$OPTN1
                        callClear
                        ;;
            *)
                instnces=""
                echo " unknown server"
                exit 1
            ;;
esac


((elasped=SECONDS-orig))
echo ""
echo "Total time taken to deploy jar is $elasped seconds"
echo ""


