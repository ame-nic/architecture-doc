workspace {
    name "System Context"
    description "This diagram depicts the System Context of Acumen KB"

    !identifiers hierarchical

    !adrs "../01-docs/architecture/decisions/system-context"
    !docs "../01-docs"

    model {

        administrator = person "Administrator" {
            tags "Employee"
            description "The actor that interacts with the system and configures it"
        }

        po = person "Product Owner" {
            tags "Employee"
            description "The actor that manages a product"
        }

        dts = softwareSystem "data-transformation-services" {

        }

        callerSystem = softwareSystem "callerSystem" {
            tags "Existing System"
        }

        acumen = softwareSystem "Acumen KB" {
            description ""

            ontologyFE = container "ontology-fe" {
                tags "Web Browser"
            }

            ontology = container "ontology" {

            }

            kb = container "knowledge-base" {

                component "event-store"
                component "inferrer"
                component "searcher"
                component "learner"
                component "planner"
                component "consistency-checker"
                component "privateGPT"
                component "smart-knwowledge-base" "It is able to build the graph of all relations"

            }

            orchestrator = container "workflow-manager" {
                tags "Camunda"
                technology "Camunda"
            }
            
            aiGateway = container "ai-gateway" {
                
            }

            resourceHandler = container "resource-handler" {
                
            }

            eventHandler = container "event-handler" {
                
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

            rhDB = container "resources-db" {
                tags "Database"
                technology "NoSQL, document-db"
            }

            rhOS = container "resources-object-storage" {
                tags "Object Store"
                technology "NoSQL, Object Storage"
            }

            ontologyDB = container "ontology-db" {
                tags "Database"
                technology "relational-db"
            }

            clauseDB = container "clause-db" {
                tags "Database"
                technology "tuple-db"
            }

            callerSystem -> acumen "calls"
            ontology -> messageBroker "produces"
            ontologyFE -> ontology "calls"
            ontology -> ontologyDB "reads/writes"
            po -> acumen "configures"
            po -> acumen "defines  pipelines"
            acumen -> dts "orchestrates"
            orchestrator -> dts "orchestrates"
            orchestrator -> resourceHandler "orchestrates"
            orchestrator -> messageBroker "produces"
            orchestrator -> messageBroker "consumes"
            kb -> messageBroker "consumes"
            resourceHandler -> rhDB "reads"
            resourceHandler -> rhOS "generates presignedURL"
            resourceHandler -> messageBroker "produces"
            eventHandler -> rhDB "writes"
            eventHandler -> messageBroker "consumes"
            aiGateway -> kb "calls"
            kb -> clauseDB "reads/writes"

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

                            deploymentNode "ontology-deployment" {
                                tags "K8s" "Kubernetes - deploy"
                                deploymentNode "Ontology" {
                                    tags "K8s" "Kubernetes - pod"
                                    instances 3
                                    deploymentNode "Quarkus Runtime" {
                                        tags "Quarkus Application"
                                        containerInstance acumen.ontology
                                    }
                                }
                            }

                            deploymentNode "resource-handler-deployment" {
                                tags "K8s" "Kubernetes - deploy"
                                deploymentNode "Resource Handler" {
                                    tags "K8s" "Kubernetes - pod"
                                    instances 3
                                    deploymentNode "Quarkus Runtime" {
                                        tags "Quarkus Application"
                                        containerInstance acumen.resourceHandler
                                    }
                                }
                            }

                            deploymentNode "event-handler-deployment" {
                                tags "K8s" "Kubernetes - deploy"
                                deploymentNode "Event Handler" {
                                    tags "K8s" "Kubernetes - pod"
                                    instances 3
                                    deploymentNode "Quarkus Runtime" {
                                        tags "Quarkus Application"
                                        containerInstance acumen.eventHandler
                                    }
                                }
                            }
                        }
                    }

                    deploymentNode "Amazon RDS" {
                        tags "AWS" "Amazon Web Services - RDS"
                        
                        deploymentNode "PostgreSQL" {
                            tags "AWS" "Amazon Web Services - RDS PostgreSQL instance"
                            
                            containerInstance acumen.rhDB
                            containerInstance acumen.clauseDB
                        }
                    }

                    deploymentNode "Amazon DocumentDB" {
                        tags "AWS" "Amazon Web Services - DocumentDB"
                        
                        containerInstance acumen.ontologyDB
                    }

                    s3 = deploymentNode "Amazon S3" {
                        tags "AWS" "Amazon Web Services - Simple Storage Service"

                        containerInstance acumen.rhOS {
                            tags "AWS" "Amazon Web Services - Simple Storage Service Bucket"
                        }
                    }

                    msk = infrastructureNode "Amazon MSK" {
                        tags "AWS" "Amazon Web Services - Managed Streaming for Apache Kafka"
                    }

                    ecr = infrastructureNode "Amazon ECR" {
                        tags "AWS" "Amazon Web Services - Elastic Container Registry"
                    }

                    apiGW = infrastructureNode "AWS API Gateway" {
                        tags "AWS" "Amazon Web Services - API Gateway"
                    }

                    apiGW -> eks "exposes"
                    eks -> msk "produces/consumes"
                    eks -> ecr "pulls images"
                    eks -> s3 "accesses"
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
            autoLayout tb 500 500
        }

        component acumen.messageBroker "Message_Broker-Topics" {
            include *
            autoLayout
            description "The component diagram for the Message Broker"
        }

        component acumen.kb "Knowledge_Base-Components" {
            include *
            autoLayout
            description "The component diagram for the Knowledge Base"
        }

        deployment acumen devEnv {
            include *
            autoLayout lr 500
        }

        themes "https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json" "https://static.structurizr.com/themes/amazon-web-services-2023.01.31/theme.json" "https://static.structurizr.com/themes/kubernetes-v0.3/theme.json" "https://raw.githubusercontent.com/amenic-hub/architecture-doc/main/09-themes/theme.json"
    }

}
