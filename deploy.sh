set -eux
TIMESTAMP=""
if [ $1 = "release" ]; then
  TIMESTAMP="-"$(date %Y%M%d%H%M)
fi

TARGET="sweetmusic-vol4"

curl -X POST -f -H "Authorization: Bearer ${DROPBOX_TOKEN}" \
	-D - -H "Dropbox-API-Arg: {\"path\": \"/${TARGET}${TIMESTAMP}.pdf\",\"mode\": \"overwrite\",\"mute\": false}" -H "Content-Type: application/octet-stream" --data-binary @target/${TARGET}.pdf https://content.dropboxapi.com/2/files/upload
curl -X POST -f -H "Authorization: Bearer ${DROPBOX_TOKEN}" \
	-D - -H "Dropbox-API-Arg: {\"path\": \"/${TARGET}${TIMESTAMP}.epub\",\"mode\": \"overwrite\",\"mute\": false}" -H "Content-Type: application/octet-stream" --data-binary @target/${TARGET}.epub https://content.dropboxapi.com/2/files/upload
curl -X POST -f -H "Authorization: Bearer ${DROPBOX_TOKEN}" \
	-D - -H "Dropbox-API-Arg: {\"path\": \"/${TARGET}${TIMESTAMP}.txt\",\"mode\": \"overwrite\",\"mute\": false}" -H "Content-Type: application/octet-stream" --data-binary @target/${TARGET}.text https://content.dropboxapi.com/2/files/upload
