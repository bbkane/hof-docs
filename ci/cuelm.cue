package ci

import (
	"github.com/hofstadter-io/cuelm/schema"
)

Install: schema.#List & {
	items: [
		#HofDocs.Ingress,
		#HofDocs.Service,
		#HofDocs.Deployment,
	]
}

Update: schema.#List & {
	items: [
		#HofDocs.Deployment,
	]
}

#HofDocs: {
	_Values: {
		name: "hof-docs"
		namespace: "websites"

		registry: "us.gcr.io/hof-io--develop"
		image: "docs.hofstadter.io"
		version: string | *"manual" @tag(version)

		domain: string | *"docs.hofstadter.io" @tag(domain)
		port: 80

		#metadata: {
			name: _Values.name
			namespace: _Values.namespace
			labels: {
				app: _Values.name
			}
			...
		}
	}

	Ingress: schema.#Ingress & {
		apiVersion: "extensions/v1beta1"
		metadata: _Values.#metadata & {
			annotations: {
				"kubernetes.io/tls-acme": "true"
				"kubernetes.io/ingress.class": "nginx"
				"nginx.ingress.kubernetes.io/force-ssl-redirect": "true"
				"cert-manager.io/cluster-issuer": "letsencrypt-prod"
			}
		} // END Ingress.metadata

		spec: {
			tls: [{
				hosts: [_Values.domain]
				secretName: "\(_Values.name)-tls"
			}]

			rules: [{
				host: _Values.domain
				http: paths: [{
					backend: {
						serviceName: Service.metadata.name
						servicePort: Service.spec.ports[0].port
					}
				}]
			}]

		} // END Ingress.spec
	} // END Ingress

	Service: schema.#Service & {
		metadata: _Values.#metadata
		spec: {
			selector: _Values.#metadata.labels
			type: "ClusterIP"
			ports: [{
				port: _Values.port
				targetPort: _Values.port
			}]
		}
	}

	Deployment: schema.#Deployment & {
		metadata: _Values.#metadata
		spec: {
			selector: matchLabels: _Values.#metadata.labels

			template: {
				metadata: labels: _Values.#metadata.labels
				spec: {
					containers: [{
						name: "website"
						image: "\(_Values.registry)/\(_Values.image):\(_Values.version)"
						imagePullPolicy: "Always"
						ports: [{
							containerPort: _Values.port
							protocol: "TCP"
						}]
						readinessProbe: {
							httpGet: port: _Values.port
							initialDelaySeconds: 6
							failureThreshold: 3
							periodSeconds: 10
						}
						livenessProbe: {
							httpGet: port: _Values.port
							initialDelaySeconds: 6
							failureThreshold: 3
							periodSeconds: 10
						}
					}]
				}
			}
		}
	}

}


