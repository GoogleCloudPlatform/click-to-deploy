response="$(
      timeout -s 9 1 \
      redis-cli \
        -a "${REDIS_PASSWORD}" --no-auth-warning \
        -h "${REDIS_ADDR}" \
        -p 6379 \
        ping
    )"
if [[ "${response}" != "PONG" ]]; then
  echo "${response}"
  exit 1
fi
