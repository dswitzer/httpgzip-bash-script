httpgzip(){
	headers=$(curl "$@" --silent -I -L -H "Accept-Encoding: gzip,deflate");
	# gets the full request, w/headers only and the file size--by getting a full request we can save an HTTP request
	headers=$(curl "$@" --silent --dump-header - -L -H "Accept-Encoding: gzip,deflate" --write-out "Download Size: %{size_download}" --include --output /dev/null);
	gzipEnabled=$(if echo "$headers" | grep 'Content-Encoding: gzip' > /dev/null 2>&1 ; then echo Yes; else echo No;fi);
	fileSize=$(echo "$headers" | grep -P '(?<=Download Size\: )\d+' -o);

	if [[ $fileSize =~ ^[0-9]+$ ]]; then
		hasFileSize=true;
	else
		hasFileSize=false;
	fi

	# output if Gzip is enabled
	echo "Gzip Enabled: $gzipEnabled";
	echo "";

	# get the compressed size of the file
	if [[ $gzipEnabled == "Yes" ]]; then
		# if we already have the file size, we can skip looking it up
		if [[ $hasFileSize ]]; then
			compress_size=$fileSize
		else
			compress_size=$(curl "$@" --silent -L -H "Accept-Encoding: gzip,deflate" --write-out "%{size_download}" --output /dev/null);
		fi
		compress_size_display=$(__bytesToHuman $compress_size);
		echo "Compressed size:   $compress_size_display";
	fi

	# if we already have the filesize, no reason to look it up again
	if [[ ($gzipEnabled == "No") && $hasFileSize ]]; then
		uncompress_size=$fileSize
	else
		# get the uncompressed size and make sure to tell the server now to accept encoding
		uncompress_size=$(curl "$@" --silent -L -H "Accept-Encoding: identity" --write-out "%{size_download}" --output /dev/null);
	fi
	uncompress_size_display=$(__bytesToHuman $uncompress_size);
	echo "Uncompressed size: $uncompress_size_display";

	# print savings achieved by using Gzip
	if [[ $gzipEnabled == "Yes" ]]; then
		# calculate the size savings, must use "bc" since bash does not do floating values
		size_diff=$(echo "scale=4; 100-(($compress_size/$uncompress_size)*100)" | bc);
		savings_display=$(printf "%.*f" 2 $size_diff);
		echo "Savings:           $savings_display%";
	fi

}

# helper function to convert bytes to human readable
__bytesToHuman() {
	b=${1:-0}; d=''; s=0; S=(Bytes {K,M,G,T,E,P,Y,Z}B)
	while ((b > 1024)); do
		d="$(printf ".%02d" $((b % 1024 * 100 / 1024)))"
		b=$((b / 1024))
		let s++
	done
	echo "$b$d ${S[$s]}"
}
