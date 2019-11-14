
export SOLR_INDEXUPDATER_BASE_URL=$GRETL_INDEXUPDATER_BASE_URL

DB_URI_SOGIS=$GRETL_PROD_SOGIS_URL
DB_USER_SOGIS=$GRETL_DB_USER
DB_PWD_SOGIS=$GRETL_DB_PASS

DB_URI_PUB=$GRETL_TEST_PUB_URL
DB_USER_PUB=$GRETL_DB_USER
DB_PWD_PUB=$GRETL_DB_PASS

echo "===================================================================="
echo "SOLR_INDEXUPDATER_BASE_URL: $SOLR_INDEXUPDATER_BASE_URL"
echo ""
echo "DB_URI_SOGIS: $DB_URI_SOGIS"
echo "DB_USER_SOGIS: $DB_USER_SOGIS"
echo "DB_PWD_SOGIS: $DB_PWD_SOGIS"
echo ""
echo "DB_URI_PUB: $DB_URI_PUB"
echo "DB_USER_PUB: $DB_USER_PUB"
echo "DB_PWD_PUB: $DB_PWD_PUB"
echo "===================================================================="

/bin/bash ~/Dokumente/git/agi/jobs/start-gretl.sh --docker-image sogis/gretl-runtime:production --job-directory ~/Dokumente/git/gretljobs/agi_mopublic_pub/

