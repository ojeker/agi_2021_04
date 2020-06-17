CREATE OR REPLACE VIEW afu_igel_pub.igel_stall_solr_v AS

WITH 
index_base AS (
SELECT 
    'ch.so.afu.abwasser_lw.stall'::text AS subclass,
    t_id AS id_in_class,
    concat(aname,' | Stall-ID: ', id ,', Stao-ID: ', standort_id,' (Stall)') AS part_1,
    concat('Name Bewirtschafter ',stao_name_bewirtschafter ) AS part_3,
    (st_asgeojson(st_envelope(geometrie), 0, 1)::json -> 'bbox')::text AS bbox
FROM
    afu_igel_pub.igel_stall
)

SELECT
    (array_to_json(ARRAY[subclass::text, id_in_class::text]))::text AS id,
    part_1 AS display,
    part_1 AS search_1_stem,
    concat(part_1,' ',part_3) AS search_3_stem, 
    subclass AS facet,
    bbox AS bbox,
    (array_to_json(ARRAY['t_id'::text, 'str:n'::text]))::text AS idfield_meta
FROM
    index_base
;