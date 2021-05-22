hextasy: hextasy.cr
	crystal build --release --no-debug hextasy.cr

dev: hextasy.cr
	crystal build hextasy.cr
