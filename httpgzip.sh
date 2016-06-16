httpgzip(){
	headers=$(curl -s -I -L -H "Accept-Encoding: gzip,deflate" "$1");
	gzipEnabled=$(if echo "$headers" | grep 'Content-Encoding: gzip' > /dev/null 2>&1 ; then echo Yes; else echo No;fi);

	# output if Gzip is enabled
	echo "Gzip Enabled: $gzipEnabled";
	echo "";

	# get the compressed size of the file
	if [[ $gzipEnabled == "Yes" ]]; then
		compress_size=$(curl "$1" --silent -L -H "Accept-Encoding: gzip,deflate" --write-out "%{size_download}" --output /dev/null);
		compress_size_display=$(__bytesToHuman $compress_size);
		echo "Compressed size:   $compress_size_display";
	fi

	# get the raw size of the file
	uncompress_size=$(curl "$1" --silent -L --write-out "%{size_download}" --output /dev/null);
	uncompress_size_display=$(__bytesToHuman $uncompress_size);
	echo "Uncompressed size: $uncompress_size_display";

	# print savings achieved by using Gzip
	if [[ $gzipEnabled == "Yes" ]]; then
		# calculate the size savings, must use "bc" since bash does not do floating values
		size_diff=$(echo "scale=4; 100-(($compress_size/$uncompress_size)*100)" | bc);
		savings_display=$(printf "%.*f" 2 $size_diff);
		echo "Savings:           $savings_display%";
	fi


	# helper function to convert bytes to human readable
	function __bytesToHuman() {
		b=${1:-0}; d=''; s=0; S=(Bytes {K,M,G,T,E,P,Y,Z}B)
		while ((b > 1024)); do
			d="$(printf ".%02d" $((b % 1024 * 100 / 1024)))"
			b=$((b / 1024))
			let s++
		done
		echo "$b$d ${S[$s]}"
	}

}
