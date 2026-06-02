{{/* Common labels applied to all components */}}
{{- define "users-stack.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Values.global.environment }}
env: {{ .Values.global.environment | quote }}
{{- end }}
{{- end }}