REPO_BASE=https://repo1.maven.org/maven2/
LOCAL_REPO_BASE=${HOME}/.m2/repository/
for jar in $(find ${LOCAL_REPO_BASE} -name '*.jar' | cut -d / -f 6-); do
  asc="${jar}.asc"
  if [ ! -f "${LOCAL_REPO_BASE}${asc}" ]; then
    http_status=$(curl "${REPO_BASE}${asc}" -s -o ${LOCAL_REPO_BASE}${asc}  -w "%{http_code}")
    if [ "${http_status}" == 404 ]; then
      echo "FAIL: signature not found"
      rm -f "${LOCAL_REPO_BASE}${asc}"
      continue
    fi
    if [ ! "${http_status}" == 200 ]; then
      echo "FAIL: signature fetch failed with status ${http_status}"
      rm -f "${LOCAL_REPO_BASE}${asc}"
      continue
    fi
  fi
  key_id=$(gpg2 -vv "${LOCAL_REPO_BASE}${asc}" 2>&1 | grep -E 'using \S+ key' | rev | cut -d ' ' -f1 | rev)
  gpg2 -q --keyserver pgp.mit.edu --recv-keys "${key_id}" &> /dev/null
  if [ $? -eq 0 ]; then
    gpg2 -q --verify "${LOCAL_REPO_BASE}${asc}" &> /dev/null
    if [ $? -eq 0 ]; then
      echo "OK: good sign for ${LOCAL_REPO_BASE}${jar}"
    else
      echo "FAIL: bad sign for ${LOCAL_REPO_BASE}${jar}"
      continue
    fi
  else
    echo "FAIL: cannot find key ${key_id} on keyserver"
    continue
  fi
done
