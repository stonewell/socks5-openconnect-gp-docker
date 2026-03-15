#!/bin/sh

eval $(python3 saml.py)

if test "x$INVALID_SAML_VALUES" = "xyes"; then
  exit 1
fi

echo ${OC_COOKIE} | openconnect \
	--protocol=gp \
	--useragent=\'"${OC_USERAGENT}"\' \
	--allow-insecure-crypto \
	--user=${OC_USER} \
	--os=${OC_OS} \
	--usergroup=\'"${OC_USERGROUP}"\' \
	--csd-user=nobody \
	--csd-wrapper=/libexec/openconnect/hipreport.sh \
	--authgroup=\'"${VPN_GW}"\' \
	--passwd-on-stdin \
	${VPN_PORTAL}
