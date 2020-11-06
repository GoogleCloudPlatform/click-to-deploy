{{- define "solrMode" }}
{{- if .Values.solr.standalone }}
{{- printf "Solr"}}
{{- else }}
{{- printf "SolrCloud" }}
{{- end }}
{{- end }}
