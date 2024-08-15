workspace {
    name "System Context"
    description "This diagram depicts the System Context of Acumen KB"

    !identifiers hierarchical

    !adrs ../01-docs/architecture/decisions/system-context
    !docs ../01-docs

    model {

        administrator = person "Administrator" {
            tags "Employee"
            description "The actor that interacts with the system and configures it"
        }

        po = person "Product Owner" {
            tags "Customer"
            description "The actor that manages a product"
        }

        dts = softwareSystem "data-transformation-services" {

        }

        acumen = softwareSystem "Acumen KB" {
            description ""

            apiGW = container "AWS API Gateway" {
                technology "API Gateway"
                tags "AWS" "Amazon Web Services - API Gateway"
            }

            ontology = container "ontology" {

            }

            orchestrator = container "orchestrator" {
                tags "K8s" "Kubernetes - deploy"

            }
            
            aiGateway = container "ai-gateway" {
                tags "K8s" "Kubernetes - deploy"
                
            }

            resourceHandler = container "resource-handler" {
                tags "K8s" "Kubernetes - deploy"
            }

            eventHandler = container "event-handler" {
                tags "K8s" "Kubernetes - deploy"
            }

            messageBroker = container "message-broker" {

                technology "Kafka"

                ontTopic = component "ontology.events" {
                    tags "Topic"
                }

                resTopic = component "resources.events" {
                    tags "Topic"
                }
            }

            rhDB = container "resources-database" {
                tags "Database"
                technology "RDS"
            }


            ontologyDB = container "ontology-database" {
                tags "Database"
                technology "RDS"
            }

            apiGW -> ontology "routes-traffic"
            ontology -> messageBroker "produces"
            ontology -> ontologyDB "reads/writes"
            apiGW -> resourceHandler "routes-traffic"
            po -> acumen "configures"
            po -> acumen "defines  pipelines"
            acumen -> dts "orchestrates"
            orchestrator -> dts "orchestrates"
            orchestrator -> messageBroker "produces"
            orchestrator -> messageBroker "consumes"
            resourceHandler -> rhDB "reads"
            resourceHandler -> messageBroker "produces"
            eventHandler -> rhDB "writes"
            eventHandler -> messageBroker "consumes"

        }

        devEnv = deploymentEnvironment "Development - Environment" {
            deploymentNode "Amazon Web Services" {
                tags "AWS" "Amazon Web Services - Cloud"
                
                deploymentNode "us-central-1" {
                    tags "AWS" "Amazon Web Services - Region"
                
                    route53 = infrastructureNode "Route 53" {
                        tags "AWS" "Amazon Web Services - Route 53"
                    }
                    elb = infrastructureNode "Elastic Load Balancer" {
                        tags "AWS" "Amazon Web Services - Elastic Load Balancing"
                    }

                    eks = deploymentNode "Amazon EKS" {
                        tags "AWS" "Amazon Web Services - Elastic Kubernetes Service"
                        
                        deploymentNode "Ubuntu Server" {
                            instances 6
                            containerInstance acumen.resourceHandler
                            containerInstance acumen.eventHandler
                        }
                    }

                    deploymentNode "Amazon RDS" {
                        tags "AWS" "Amazon Web Services - RDS"
                        
                        deploymentNode "PostgreSQL" {
                            tags "AWS" "Amazon Web Services - RDS MySQL instance"
                            
                            containerInstance acumen.rhDB
                            containerInstance acumen.ontologyDB
                        }
                    }

                    msk = infrastructureNode "Amazon MSK" {
                        tags "AWS" "Amazon Web Services - Managed Streaming for Apache Kafka"
                    }

                    eks -> msk "produces/consumes"
                }
            }
        }
    }

    views {

        systemContext acumen "Context" "An example System Context diagram for the Acumen" {
            include *
            autoLayout
        }

        container acumen {
            include *
            include dts
            autoLayout
        }

        component acumen.messageBroker "Components" {
            include *
            autoLayout
            description "The component diagram for the API Application."
        }

        deployment acumen devEnv {
            include *
            autoLayout lr
        }

        themes "https://static.structurizr.com/themes/amazon-web-services-2023.01.31/theme.json" "https://static.structurizr.com/themes/kubernetes-v0.3/theme.json"
    }

}
