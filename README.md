# httpgzip-bash-script
A .bashrc script for checking if a web page has Gzip and enabled and displays the compression savings.

Add the code in the httpgzip.sh file into your ~/.bashrc file. After the file has been edited, make to run:

```
source ~/.bashrc file
```

To update your .bashrc file in your environment.

You can now run:

```
httpgzip http://www.google.com
```

To test a page to see if GZip is enabled and the page sizes return:

```
Gzip Enabled: Yes

Compressed size:   4.36 KB
Uncompressed size: 10.13 KB
Savings:           56.91%
```

## Depedencies

* curl
* bc

