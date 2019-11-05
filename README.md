# quickstat
xinetd service to retrieve basic system information

### Build Requirements
* xinetd
* make
* m4

### Run requirements
* xinetd
* iostat

### Installation
1. Run ```make setup``` and provide the port number to run service as
2. Run ```sudo make install```

### Usage
Query the machine running quickstat (via xinetd) using the following URL:  
```http://HOST:PORT/stats```  
  
The resulting JSON will look like this:   
```
{
	"cpu": {
		"pctuser": "4.93",
		"pctsystem": "3.22",
		"pctwait": "0.66",
		"pctidle": "91.15",
		"1minavg": "0.23",
		"5minavg": "0.33",
		"15minavg": "0.36"
	},
	"mem": {
		"total": "439364",
		"used": "80512",
		"free": "11920"
	},
	"swap": {
		"total": "0",
		"used": "0",
		"free": "0"
	},
	"disk": [{
		"device": "sda",
		"read-kbps": "0.29",
		"write-kbps": "23.97"
	}],
	"partition": [{
		"device": "/dev/sda1",
		"mount": "/",
		"total": "27990468",
		"used": "10520320",
		"free": "17470148"
	}, {
		"device": "/dev/sda2",
		"mount": "/boot",
		"total": "102182",
		"used": "24270",
		"free": "77912"
	}]
}
```  
  
Here are the individual resources and the URI they can be queries with:  

| Resource | URI |
| --- | --- |
| All Resources | /stats |
| CPU | /stats/cpu |
| Memory | /stats/mem |
| Swap Space | /status/swap |
| Disk Devices | /status/disk |
| Partitions | /status/partition |
  
## Extending Functionality  
1. Create a script file in `stats` folder (for example, name it `hits`).  This script will be executed when the URL is hit (for example /stats/hits).  
2. Create a file in the `stats` folder with the `.comments` extension that contains information on what the script does (for example `hits.comments`).
