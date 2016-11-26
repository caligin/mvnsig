REPO_BASE=https://repo1.maven.org/maven2/
LOCAL_REPO_BASE=${HOME}/.m2/repository/
KEYSERVER=pgp.mit.edu
for jar in $(find ${LOCAL_REPO_BASE} -name '*.jar' | cut -d / -f 6-); do
  asc="${jar}.asc"
  jar_abs=${LOCAL_REPO_BASE}${jar}
  asc_abs=${LOCAL_REPO_BASE}${asc}
  if [ ! -f "${LOCAL_REPO_BASE}${asc}" ]; then
    http_status=$(curl "${REPO_BASE}${asc}" -s -o ${asc_abs}  -w "%{http_code}")
    if [ "${http_status}" == 404 ]; then
      echo "FAIL NOSIG ${jar_abs} NOKEY signature not found in remote repo"
      rm -f "${asc_abs}"
      continue
    fi
    if [ ! "${http_status}" == 200 ]; then
      echo "FAIL ERROR ${jar_abs} NOKEY signature fetch failed with status ${http_status}"
      rm -f "${asc_abs}"
      continue
    fi
  fi
  key_id=$(gpg2 -vv "${asc_abs}" 2>&1 | grep -E 'using \S+ key' | rev | cut -d ' ' -f1 | rev)
  gpg2 -q --keyserver ${KEYSERVER} --recv-keys "${key_id}" &> /dev/null
  if [ $? -eq 0 ]; then
    gpg2 -q --verify "${asc_abs}" &> /dev/null
    if [ $? -eq 0 ]; then
      echo "OK GOOD ${jar_abs} ${key_id}"
    else
      echo "FAIL BAD ${jar_abs} ${key_id}"
      continue
    fi
  else
    echo "FAIL NOKEY ${jar_abs} ${key_id} cannot find key on keyserver ${KEYSERVER}"
    continue
  fi
done
