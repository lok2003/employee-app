{{- define "employeeapp.name" }}
{{- .Chart.Name }}
{{- end }}

{{- define "employeeapp.namespace" }}
{{- .Values.namespace.name }}
{{- end }}

{{- define "employeeapp.fullname" }}
{{- .Release.Name }}
{{- end }}

{{- define "employeeapp.labels" }}
app.kubernetes.io/name: {{ include "employeeapp.name" . }}
app.kubernetes.io/instance: {{ include "employeeapp.fullname" . }}
{{- end }}

{{- define "employeeapp.selectorLabels" }}
app.kubernetes.io/name: {{ include "employeeapp.name" . }}
app.kubernetes.io/instance: {{ include "employeeapp.fullname" . }}
{{- end }}