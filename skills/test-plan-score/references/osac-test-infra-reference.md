# osac-test-infra — API Reference for Test Plan Skills

Curated index of fixtures, client methods, helpers, and test files.
Use this when generating test plans to reference real infrastructure.

## Session Fixtures (tests/conftest.py)

| Fixture | Type | Scope | Description |
|---------|------|-------|-------------|
| `namespace` | `str` | session | OSAC namespace (default: `osac-devel`) |
| `cluster_domain` | `str` | session | OpenShift ingress domain |
| `fulfillment_address` | `str` | session | Public gRPC endpoint `host:443` |
| `fulfillment_private_address` | `str` | session | Private gRPC endpoint |
| `grpc` | `GRPCClient` | session | Public API client (service account token) |
| `private_grpc` | `GRPCClient` | session | Private API client (admin operations) |
| `k8s_hub_client` | `K8sClient` | session | kubectl wrapper for hub cluster CRDs |
| `cli` | `OsacCLI` | session | OSAC CLI binary wrapper |
| `jwt_grpc_tenant1` | `GRPCClient` | session | Tenant1 JWT-authenticated gRPC client |
| `jwt_grpc_tenant2` | `GRPCClient` | session | Tenant2 JWT-authenticated gRPC client |
| `jwt_cli_user` | `OsacCLI` | session | CLI as tenant1_user (JWT) |
| `jwt_cli_admin` | `OsacCLI` | session | CLI as tenant1_admin (JWT) |
| `keycloak_url` | `str` | session | Keycloak URL for token operations |
| `ensure_tenants` | autouse | session | Creates tenant1 and tenant2 via private API |

## GRPCClient Methods (tests/core/grpc_client.py)

### Generic

```python
client.call(service="osac.public.v1.Clusters/List", data={}) -> dict
client.call_unchecked(service=..., data=...) -> (str, int)
```

### Clusters (public)

```python
client.list_cluster_ids() -> list[str]
client.get_cluster(cluster_id=str) -> dict
```

### ComputeInstances (public)

```python
client.create_compute_instance(catalog_item=str, subnet_ids=list[str]) -> str  # returns ID
client.delete_compute_instance(ci_id=str)
client.list_compute_instance_ids() -> list[str]
client.get_compute_instance(ci_id=str) -> dict
client.update_restart(uuid=str, template=str, timestamp=str) -> dict
```

### VirtualNetworks (public)

```python
client.create_virtual_network(name=str, network_class=str, ipv4_cidr=str) -> str  # returns ID
client.get_virtual_network(vn_id=str) -> dict
client.list_virtual_network_ids() -> list[str]
client.delete_virtual_network(vn_id=str)
```

### Subnets (public)

```python
client.create_subnet(name=str, virtual_network=str, ipv4_cidr=str) -> str
client.get_subnet(subnet_id=str) -> dict
client.list_subnet_ids() -> list[str]
client.delete_subnet(subnet_id=str)
```

### SecurityGroups (public)

```python
client.create_security_group(name=str, virtual_network=str) -> str
client.get_security_group(sg_id=str) -> dict
client.list_security_group_ids() -> list[str]
client.delete_security_group(sg_id=str)
```

### ExternalIPPools (private)

```python
client.create_external_ip_pool(name=str, cidrs=list[str], ip_family=str, implementation_strategy=str) -> str
client.get_external_ip_pool(pool_id=str) -> dict
client.list_external_ip_pool_ids() -> list[str]
client.delete_external_ip_pool(pool_id=str)
```

### ExternalIPs (public)

```python
client.create_external_ip(name=str, pool=str) -> str
client.get_external_ip(external_ip_id=str) -> dict
client.list_external_ip_ids() -> list[str]
client.delete_external_ip(external_ip_id=str)
```

### Tenants (private)

```python
client.ensure_tenant(name=str)  # creates if not exists
```

### CatalogItems (mixed)

```python
# ClusterCatalogItems (private create, public read)
client.create_cluster_catalog_item(name=str, template=str, published=bool, field_definitions=list) -> str
client.get_cluster_catalog_item(catalog_item_id=str) -> dict
client.list_cluster_catalog_item_ids() -> list[str]
client.update_cluster_catalog_item(catalog_item_id=str, **fields) -> dict
client.delete_cluster_catalog_item(catalog_item_id=str)

# ComputeInstanceCatalogItems
client.create_compute_instance_catalog_item(name=str, template=str, published=bool, field_definitions=list) -> str
client.get_compute_instance_catalog_item(catalog_item_id=str) -> dict
client.list_compute_instance_catalog_item_ids() -> list[str]
client.update_compute_instance_catalog_item(catalog_item_id=str, **fields) -> dict
client.delete_compute_instance_catalog_item(catalog_item_id=str)
```

### InstanceTypes (private)

```python
client.create_instance_type(name=str, cores=int, memory_gib=int, description=str) -> str
client.get_instance_type(name=str) -> dict
client.list_instance_type_names() -> list[str]
client.update_instance_type(name=str, state=str) -> dict
client.delete_instance_type(name=str)
```

### BareMetalInstances (public)

```python
client.list_baremetal_instance_ids() -> list[str]
client.get_baremetal_instance(bmi_id=str) -> dict
client.get_baremetal_instance_state(bmi_id=str) -> str
client.update_baremetal_instance_run_strategy(bmi_id=str, run_strategy=str) -> dict
client.delete_baremetal_instance(bmi_id=str)
```

## K8sClient Methods (tests/core/k8s_client.py)

### Generic

```python
K8sClient(namespace=str, kubeconfig=str|None)
client.get_json(resource=str, name=str) -> dict
client.get_jsonpath(resource=str, name=str, jsonpath=str) -> str
client.get_by_label(resource=str, label=str, jsonpath=str) -> str
client.patch(resource=str, name=str, patch=str) -> (str, int)
client.apply(manifest=str)
client.delete(resource=str, name=str, wait=bool)
client.is_present(resource=str, name=str) -> bool
client.count_by_label_all_namespaces(resource=str, label=str) -> int
```

### ClusterOrder queries

```python
client.get_cluster_order_name(uuid=str) -> str
client.get_cluster_order_phase(name=str) -> str  # "Ready", "Pending", etc.
client.get_cluster_order_condition_status(name=str, condition_type=str) -> str  # "True"/"False"
client.get_cluster_order_finalizers(name=str) -> list[str]
client.get_cluster_order_hosted_cluster_name(name=str) -> str
client.get_cluster_order_namespace(name=str) -> str
client.get_cluster_order_spec(name=str) -> dict
client.get_cluster_order_latest_job_id(name=str, job_type=str) -> str
client.get_cluster_order_latest_job_state(name=str, job_type=str) -> str
```

### Tenant queries

```python
client.get_tenant_phase(name=str) -> str
client.get_tenant_condition_status(name=str, condition_type=str) -> str
client.get_tenant_storage_classes(name=str) -> list[dict]
client.get_tenant_finalizers(name=str) -> list[str]
client.get_tenant_cluster_storage(name=str) -> list[dict]  # [{clusterName, ready, ...}]
```

### Storage queries (cluster-scoped)

```python
client.count_storage_classes_by_tenant(tenant_name=str) -> int
client.list_storage_class_names_by_tenant(tenant_name=str) -> list[str]
client.get_storage_class_labels(name=str) -> dict[str,str]
client.count_secrets_by_tenant(tenant_name=str, namespace=str) -> int
```

### ComputeInstance, VirtualNetwork, Subnet, SecurityGroup, ExternalIP queries

All follow the pattern: `get_{resource}_name(uuid=)`, `get_{resource}_phase(name=)`, etc.

## Wait Helpers (tests/core/helpers.py)

### Generic pattern

```python
poll_until(fn=callable, until=callable, retries=int, delay=int, description=str) -> T
```

### CaaS / Cluster helpers

```python
wait_for_cluster_order_cr(k8s=, uuid=) -> str  # returns CR name
wait_for_cluster_ready(k8s=, name=)  # retries=240, delay=15
wait_for_cluster_deletion(k8s=, name=)  # includes HyperShift cleanup hacks
wait_for_cluster_grpc_removal(grpc=, uuid=)
wait_for_cluster_order_condition(k8s=, name=, condition_type=, expected_status="True")
```

### Storage helpers

```python
wait_for_tenant_cluster_storage_entry(k8s=, tenant_name=, cluster_name=) -> dict
wait_for_tenant_cluster_storage_entry_removed(k8s=, tenant_name=, cluster_name=)
wait_for_storage_classes_by_tenant(k8s=, tenant_name=, min_count=1) -> list[str]
wait_for_storage_classes_removed(k8s=, tenant_name=)
wait_for_secrets_removed(k8s=, tenant_name=, namespace=)
```

### Tenant helpers

```python
wait_for_tenant_cr(k8s=, name=)
wait_for_tenant_condition(k8s=, name=, condition_type=, expected_status="True")
wait_for_tenant_deletion(k8s=, name=)
```

### ComputeInstance, VirtualNetwork, Subnet, SecurityGroup, ExternalIP helpers

All follow: `wait_for_{resource}_cr`, `wait_for_{resource}_ready`, `wait_for_{resource}_deletion`

### Assertion helpers

```python
assert_grpc_rejected(exc_info, code=str)  # asserts gRPC error code like "AlreadyExists"
```

## Test File Index

| Domain | File | What it tests |
|--------|------|--------------|
| **bmaas** | `tests/bmaas/test_baremetal_instance_lifecycle.py` | BMI create, provision, power ops, delete |
| **caas** | `tests/caas/test_cluster_create.py` | Cluster lifecycle, credentials, templates |
| **catalog** | `tests/catalog/test_catalog_item_lifecycle.py` | ClusterCatalogItem CRUD |
| **catalog** | `tests/catalog/test_compute_instance_catalog_item_lifecycle.py` | ComputeInstanceCatalogItem CRUD |
| **storage** | `tests/storage/test_tenant_storage_lifecycle.py` | Tenant storage onboarding (Stage 1+2) |
| **storage** | `tests/storage/test_caas_cluster_storage.py` | CaaS cluster storage lifecycle (OSAC-1123) |
| **vmaas** | `tests/vmaas/test_compute_instance_creation.py` | VM create with networking |
| **vmaas** | `tests/vmaas/test_compute_instance_api_fields.py` | API field validation |
| **vmaas** | `tests/vmaas/test_compute_instance_cli_fields.py` | CLI field mapping |
| **vmaas** | `tests/vmaas/test_compute_instance_delete_during_provision.py` | Delete while provisioning |
| **vmaas** | `tests/vmaas/test_compute_instance_restart.py` | VM restart lifecycle |
| **vmaas** | `tests/vmaas/test_compute_instance_restart_negative.py` | Restart error paths |
| **vmaas** | `tests/vmaas/test_compute_instance_instance_type.py` | InstanceType selection |
| **vmaas** | `tests/vmaas/test_virtual_network_lifecycle.py` | VN create/ready/delete |
| **vmaas** | `tests/vmaas/test_subnet_lifecycle.py` | Subnet create/ready/delete |
| **vmaas** | `tests/vmaas/test_security_group_lifecycle.py` | SG create/ready/delete |
| **vmaas** | `tests/vmaas/test_jwt_auth_smoke.py` | JWT tenant auth smoke test |
| **vmaas** | `tests/vmaas/test_console.py` | Console session creation |
| **vmaas/ext_ip** | `tests/vmaas/external_ip/test_external_ip_pool_lifecycle.py` | Pool CRUD |
| **vmaas/ext_ip** | `tests/vmaas/external_ip/test_external_ip_pool_capacity.py` | Pool capacity tracking |

## Runner Utilities (tests/core/runner.py)

```python
run(*args, timeout=300) -> str          # subprocess.run with check=True, returns stdout
run_unchecked(*args, timeout=300) -> (str, int)  # returns (combined output, return code)
poll_until(fn, until, retries, delay, description) -> T  # generic polling
env(key, default) -> str                # os.environ.get with default
```
