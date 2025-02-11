
# psql -U postgres -d postgres -c "select * from test_bonus_spot ;"

mkdir -p /tmp/sql-test
filename=$(mktemp /tmp/sql-test/file.XXX.sql)
echo $filename
container_name="partition-postgresql-1"

replace_dataset(){
	dataset_id=$1
	spot_date=$2
	echo "inserting ${count} spots into $dataset_id for $spot_date"

	truncate -s 0 $filename

	echo "explain (analyze, costs, verbose, buffers) insert into test_bonus_spot (spot_id, dataset_id, order_line_id, zone, network, spot_time) values " >> $filename

	for i in {1..50000}
	do
		echo " ($i, $dataset_id, $i, 1, 1, '$spot_date 00:00:00'), " >> $filename

		# podman exec -it pilot-performance-postgresql-1 psql \
		#  -U postgres -d postgres \
		#  -c "insert into test_bonus_spot (spot_id, dataset_id, order_line_id, zone, network, spot_time) values ($i, $dataset_id, $i, 1, 1, '$spot_date 00:00:00');"
	done
		echo " (5001, $dataset_id, 5001, 1, 1, '$spot_date 00:00:00') ;" >> $filename

	drop_dataset $dataset_id $spot_date $spot_date
	cat $filename | podman exec -i $container_name psql -U postgres -d postgres

}

drop_dataset(){
	dataset_id=$1
	from="$2"
	to="$3"
	echo "deleting dataset $dataset_id"

	podman exec -it $container_name psql \
	 -U postgres -d postgres \
	 -c "explain (analyze, costs, buffers) delete from test_bonus_spot where dataset_id = $dataset_id and "spot_time"::date between '${from}' and '${to}';"
}

insert_data_for_datasets(){
	spot_date=$1
	for dataset_id in {1..100}
	do
		replace_dataset $dataset_id $spot_date
	done
}


# d=2021-01-01
# while [ "$d" != 2021-02-20 ]; do 
#   echo $d
#   d=$(date -I -d "$d + 1 day")

#   insert_data_for_datasets $d
# done

subcommand="${1}"
case "${subcommand}" in
	replace)
		shift
		replace_dataset "${@}"
		;;
	drop)
		shift
		drop_dataset  "${@}"
		;;
	*)
		echo "Usage: <replace|drop>"
		exit 1
		;;
esac

