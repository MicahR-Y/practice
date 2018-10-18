#! /bin/bash
personal_key="$1"
ticket_file="$2"
event_file="$3"
if [ -e ${ticket_file}.txt ]; then
	rm ${ticket_file}.txt
fi
if [ -e ${event_file}.txt ]; then
	rm ${event_file}.txt
fi

nTick="${4:-3}"
nEven="${5:-89}"


for ((i=1; i<=$nTick; i++))
do curl -sS --request GET -u ${personal_key}:x-oauth-basic 'https://api.github.com/repos/broadinstitute/TAG/issues?state=closed&per_page=102&page='$i \
| grep -E '"created_at"|"number"|"closed_at"|"name"'| sed -e ':a;N;$!ba;s/",\n}/"\n}/g'|sed -e ':a;N;$!ba;s/    "name"/"name"/g'\
|sed -e ':a;N;$!ba;s/",\n    "name":/",/g'| sed -e 's/"name"/"labels"/g'|sed -e ':a;N;$!ba;s/",\n    "number"/\n    "number"/g'|sed -e 's/", "/ /g' \
| sed -e ':a;N;$!ba;s/,\n    /,: /g'\
|awk 'BEGIN{FS=": "}{printf $2; \
if($3=="\42labels\42"){print " " $4 " " $6 " " $8 "\42\n"} \
else{print " \42None\42, " $4 " " $6 "\42\n"}}'\
|sed -e ':a;N;$!ba;s/,"\n/\n/g'>>${ticket_file}.txt
#echo $i
done

for ((j=1; j<=$nEven; j++))
do curl -sS --request GET -u ${personal_key}:x-oauth-basic 'https://api.github.com/repos/broadinstitute/TAG/issues/events?per_page=102&page='$j \
| grep -E '"event": |"created_at"|"number"'| sed -e ':a;N;$!ba;s/",\n    "created_at"/", "created_at"/g'| sed -e ':a;N;$!ba;s/",\n      "number"/", "number"/g'\
|grep -E '"reopened"|"closed"'|awk '{print $2 $4 $6}'| sed 's/",/" /g'|sed 's/,//g'>>${event_file}.txt
#echo $j
done
