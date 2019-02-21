#!/bin/sh
# use option -xv for debugging in above line

# get the list of timestamp from the log
awk '{print $5}' log | awk -F: '{print $1":"$2}' | uniq > timeStampList

# remove blank lines and colon
sed -i -e '/^$/d' -e '/^:/d' timeStampList

# get the list of all the services in sorted order
awk '{print $12}' log | sort | uniq > serviceList 

# remove blank lines and double quotes
sed -i -e '/^$/d' -e 's/"//g' serviceList

for i in `cat timeStampList`        # loop over all the time stamps obtained from above file
do
    grep "$i:" log > logTimeWise_$i

    printf "Time : %s\n" "$i"

    for j in `cat serviceList`        # loop over all the services for particular timestamp from above file
    do
        count=`grep $j logTimeWise_$i | wc -l`        # count of each service per minute

        response_time_count=0
        sum=0
        avg=0

        grep $j logTimeWise_$i > logServiceWise_${i}_${j}        # create file containing service for a particular timestamp

        for k in `cat logServiceWise_${i}_${j} | awk '{print $11}'`        # loop over the file created above
        do
            response_time_count=$((response_time_count + 1))
            sum=`expr $sum + $k`
        done

        avg=`expr $sum / $response_time_count`
        printf "Service : %-14s \t count : %2s \t Average response time : %6s \n" "$j" "$count" "$avg"
    done

    printf "\n"
done

#delete all the files created
rm -rf timeStampList
rm -rf serviceList
rm -rf logTimeWise_*
rm -rf logServiceWise_*
