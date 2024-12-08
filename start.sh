containerlab deploy -c -t ./multivendor-akvorado.clab.yml

if [ ! -d ./akvorado ]; then
        mkdir ./akvorado
        curl -sL https://github.com/akvorado/akvorado/releases/latest/download/docker-compose-quickstart.tar.gz | tar zxvf - -C ./akvorado
        cp ./akvorado-config/.env ./akvorado/.env
        cp ./akvorado-config/akvorado.yaml ./akvorado/config/akvorado.yaml
        cp ./akvorado-config/inlet.yaml ./akvorado/config/inlet.yaml
        cp ./akvorado-config/docker-compose-local.yml ./akvorado/docker/docker-compose-local.yml

fi

(
    cd ./akvorado
    docker compose up -d
)

# Wait until BGP comes up
echo "Waiting for connectivity to come up inside the lab..."
docker exec -it clab-multivendor-akvorado-customer-vjunos-iperf10 /bin/sh -c "while true; do ping -c1 10.0.10.1 && break; done"
docker exec -it clab-multivendor-akvorado-customer-srl-iperf10 /bin/sh -c "while true; do ping -c1 10.0.10.1 && break; done"

echo "vJunos iperf10 via Transit, 1 Mbps"
docker exec -dit clab-multivendor-akvorado-customer-vjunos-iperf10 iperf3 -c 10.0.10.1 -p5205 -t 10000 -b 1M --bidir
echo "vJunos iperf20 via IX, 2 Mbps"
docker exec -dit clab-multivendor-akvorado-customer-vjunos-iperf20 iperf3 -c 10.0.20.1 -p5205 -t 10000 -b 2M --bidir
echo "vJunos iperf30 via PNI, 3 Mbps"
docker exec -dit clab-multivendor-akvorado-customer-vjunos-iperf30 iperf3 -c 10.0.30.1 -p5205 -t 10000 -b 3M --bidir

echo "SRL iperf10 via Transit, 1 Mbps"
docker exec -dit clab-multivendor-akvorado-customer-srl-iperf10 iperf3 -c 10.0.10.1 -p5204 -t 10000 -b 1M --bidir
echo "SRL iperf20 via IX, 2 Mbps"
docker exec -dit clab-multivendor-akvorado-customer-srl-iperf20 iperf3 -c 10.0.20.1 -p5204 -t 10000 -b 2M --bidir
echo "SRL iperf30 via PNI, 3 Mbps"
docker exec -dit clab-multivendor-akvorado-customer-srl-iperf30 iperf3 -c 10.0.30.1 -p5204 -t 10000 -b 3M --bidir

echo "iPerf ports 5201-5203 are available for further testing"
echo "NOTE: SR Linux throughput is limited to 1000 pps total!"

