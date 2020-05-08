HAPROXY_CONF=/data/haproxy.cfg
cp /readonly/haproxy.cfg "$HAPROXY_CONF"
{{- $fullName := include "redis-ha.fullname" . }}
{{- $replicas := int (toString .Values.redis.replicas) }}
{{- range $i := until $replicas }}
for loop in $(seq 1 10); do
  getent hosts {{ $fullName }}-announce-{{ $i }} && break
  echo "Waiting for service {{ $fullName }}-announce-{{ $i }} to be ready ($loop) ..." && sleep 1
done
ANNOUNCE_IP{{ $i }}=$(getent hosts "{{ $fullName }}-announce-{{ $i }}" | awk '{ print $1 }')
if [ -z "$ANNOUNCE_IP{{ $i }}" ]; then
  echo "Could not resolve the announce ip for {{ $fullName }}-announce-{{ $i }}"
  exit 1
fi
sed -i "s/REPLACE_ANNOUNCE{{ $i }}/$ANNOUNCE_IP{{ $i }}/" "$HAPROXY_CONF"

if [ "${AUTH:-}" ]; then
    echo "Setting auth values"
    ESCAPED_AUTH=$(echo "$AUTH" | sed -e 's/[\/&]/\\&/g');
    sed -i "s/REPLACE_AUTH_SECRET/${ESCAPED_AUTH}/" "$HAPROXY_CONF"
fi
{{- end }}
