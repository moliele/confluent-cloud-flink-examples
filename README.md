# Confluent Cloud Flink Examples

This repository is a curated collection of practical examples and labs designed to help you learn and deploy **Apache Flink** capabilities on **Confluent Cloud**. 


## 📂 Repository Contents

| Lab / Example | Description                                                                                | Supported Formats |
| :--- |:-------------------------------------------------------------------------------------------| :--- |
| [**ccloud-flink-multi-event-routing**](./ccloud-flink-multi-event-routing) | Intelligent routing of "mixed topics" (Topics with multiple schemas) into dedicated sinks. | Avro, JSON, JSON_SR|
| [**ccloud-flink-audit-logs**](./ccloud-flink-audit-logs) | Example pipelines and processing patterns for Confluent Cloud audit logs using Flink. | JSON, JSON_SR |

---

## 🚀 How to Get Started

Each example is designed to be self-contained. The general workflow is:

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/your-username/confluent-cloud-flink-examples.git
    cd confluent-cloud-flink-examples
    ```

2.  **Choose a Lab**:
    Navigate to the specific example folder:
    ```bash
    cd ccloud-flink-multi-event-routing
    ```

3.  **Configure the environment to execute the example**:
    Follow the instructions in the local `README.md` to set up the environment.
