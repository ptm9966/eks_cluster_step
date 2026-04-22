-------------------------------- prometheus_garafana_doc.sh --------------------------------

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring

#under this https://prometheus-community.github.io/helm-charts  , you can find multiple charts for prometheus and grafana, you can choose the one that best fits your needs. 
#For example, if you want to install both prometheus and grafana together, you can use the kube-prometheus-stack chart. 
#If you want to install them separately, you can use the prometheus and grafana charts respectively.

helm install prometheus prometheus-community/prometheus -f promethes_helm_values.yml -n monitoring
helm install grafana prometheus-community/grafana -f promethes_helm_values.yml -n monitoring

# Prometheus and Grafana Installation at a time
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -f .\prometheus_files\promethes_helm_values.yml -n monitoring

verify the installation:
kubectl get pods -n monitoring

garfana admin password:
kubectl get secret --namespace monitoring -l app.kubernetes.io/component=admin-secret -o jsonpath="{.items[0].data.admin-password}" | base64 --decode

---------------------------------- hlem unstall --------------------------------------
helm uninstall kube-prometheus-stack -n monitoring
helm uninstall prometheus -n monitoring
helm uninstall grafana -n monitoring

----------------------------------------------  hlem prometheus customization --------------------------------------------
how to customize values.yml file for prometheus and grafana
To customize the values.yml file for Prometheus and Grafana, you can follow these steps:
1. Create a custom values.yml file: You can create a new file named custom_values.yml and add your desired configurations for Prometheus and Grafana.
2. Customize Prometheus configurations: In the custom_values.yml file, you can specify various configurations for Prometheus, such as scrape intervals, alerting rules, and storage settings. For example:
prometheus:
  prometheusSpec:
    scrapeInterval: 15s
    evaluationInterval: 15s
    alerting:
      alertmanagers:
        - static_configs:
            - targets: ['alertmanager:9093']
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi
3. Customize Grafana configurations: Similarly, you can customize Grafana settings in the custom_values.yml file. You can configure the Grafana server, data sources, dashboards, and more. For example:
grafana:
  grafana.ini:
    server:
      root_url: "%(protocol)s://%(domain)s/grafana/"
      serve_from_sub_path: true
  datasources:
    datasources.yaml:
      apiVersion: 1
      datasources:
        - name: Prometheus
          type: prometheus
          access: proxy
          url: http://prometheus-server:80
  dashboards:
    default:
      my-dashboard:
        json: |
          {
            "title": "My Dashboard",
            "panels": [
              {
                "type": "graph",
                "title": "CPU Usage",
                "targets": [
                  {
                    "expr": "rate(container_cpu_usage_seconds_total[5m])",
                    "format": "time_series"
                  }
                ]
              }
            ]
          }
4. Install Prometheus and Grafana with the custom values: When installing Prometheus and Grafana using Helm, you can specify your custom values file with the -f flag. For example:     
helm install prometheus prometheus-community/prometheus -f custom_values.yml -n monitoring
This will apply your custom configurations for both Prometheus and Grafana during the installation process.
Make sure to adjust the configurations in the custom_values.yml file according to your specific requirements and environment        
