
export DB_URI_SOGIS=$GRETL_PROD_SOGIS_URL
export DB_USER_SOGIS=$GRETL_DB_USER
export DB_PWD_SOGIS=$GRETL_DB_PASS

echo "===================================================================="
echo "DB_URI_SOGIS: $DB_URI_SOGIS"
echo "DB_USER_SOGIS: $DB_USER_SOGIS"
echo "DB_PWD_SOGIS: $DB_PWD_SOGIS"
echo "===================================================================="

/bin/bash ~/Dokumente/git/agi/jobs/start-gretl.sh --docker-image sogis/gretl-runtime:production --job-directory ~/Dokumente/git/gretljobs/afu_gewschutz_export_ai/export

