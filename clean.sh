
for i in {1..42}
do

MARS_NAMESPACE="mars$i"
	kubectl delete ns $MARS_NAMESPACE
done
