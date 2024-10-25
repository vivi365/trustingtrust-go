# Trusting Trust
> FEP3370 Ethical Hacking @KTH - Demo

Exploit in a Go compiler compiles benign Go code into malicious code.

Patching to Go compiler sources (`malicious.patch`) reused and adapted from [yrjan](https://github.com/yrjan/untrustworthy_go/blob/master/untrustworthy_go.patch).


## Usage

Pull image from registry:

> `docker pull vinterstorm/trustingtrust-demo-go`


Run container, executing main exploit script (/exploit/demo_exploit.sh):

> `docker run -it --rm vinterstorm/trustingtrust-demo-go`


Additionally, run the installation of malicious compiler again with:

> `docker run -it --rm vinterstorm/trustingtrust-demo-go /exploit/install_malicious_go_compiler.sh`

Or build from source and run:

> `docker build -t trustingtrust-demo-go .`

> `docker run -it --rm trustingtrust-demo-go`

