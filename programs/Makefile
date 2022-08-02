gpio_binary_sensor: gpio_binary_sensor.c
	gcc -o $@ $< -lwiringPi

dht22: dht22.c
	gcc -o $@ $< -lwiringPi

mhz19/mhz19: mhz19/mhz19.go
	#go mod download github.com/tarm/serial
	cd mhz19 && go build . && cd ..

mhz19: mhz19/mhz19


all: gpio_binary_sensor
