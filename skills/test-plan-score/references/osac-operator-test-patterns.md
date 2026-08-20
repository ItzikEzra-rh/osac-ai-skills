# osac-operator — Test Patterns Reference

Unit tests use Ginkgo v2 + Gomega with envtest (controller-runtime test environment).

## envtest Setup (internal/controller/suite_test.go)

```go
var (
    cfg           *rest.Config
    k8sClient     client.Client
    testMcManager mcmanager.Manager
    testEnv       *envtest.Environment
    ctx           context.Context
    cancel        context.CancelFunc
)
```

**Registered schemes:** osac v1alpha1, HyperShift v1beta1, bare-metal-fulfillment-operator v1alpha1,
OVN UDN v1, KubeVirt v1. All CRDs loaded from envtest.

## Storage Controller Test Patterns (storage_controller_test.go)

### Test helpers

```go
// Create a ready tenant for storage tests
func createReadyTenantForStorage(ctx context.Context, name, namespace string)

// Create the hub secret that Stage 1 checks
func createHubSecret(ctx context.Context, tenantName, namespace string)

// Create a labeled StorageClass for tier resolution tests
func createLabeledStorageClass(ctx context.Context, name, tenant, tier string)

// Create a ClusterOrder with annotations
func newClusterOrder(name, namespace string, annotations map[string]string) *v1alpha1.ClusterOrder
```

### Test structure

```go
Describe("Storage Controller", func() {
    Context("Stage 1: Backend provisioning", func() {
        It("should skip reconciliation when Tenant is not Ready", ...)
        It("should trigger backend provisioning when hub Secret is missing", ...)
        It("should set StorageBackendReady=True when hub Secret exists", ...)
        It("should set StorageBackendReady=False with NoProvider...", ...)
        It("should set ClusterStorageReady=False when no provider...", ...)
        It("should preserve tenant controller fields when patching", ...)
        It("should propagate trigger error without creating fake job", ...)
    })
    Context("Stage 2: Cluster storage provisioning", func() {
        It("should trigger cluster storage provisioning when Stage 1 complete", ...)
        It("should set ClusterStorageReady=True when SCs are discovered", ...)
        It("should use Default SC fallback and trigger provisioning", ...)
        It("should detect duplicate Default SCs and set False", ...)
        It("should not trigger provisioning when tenant-specific SC exists", ...)
        It("should surface duplicate warnings in condition", ...)
    })
    Context("Tier resolution", func() {
        It("should fall back to Default StorageClass", ...)
        It("should prefer tenant-specific SC over Default", ...)
    })
    Context("Finalizer and deletion", func() {
        It("should add storage finalizer on first reconcile", ...)
        It("should run deletion even when class provider is nil", ...)
    })
    Context("Management state", func() {
        It("should skip reconciliation when Unmanaged", ...)
    })
    Context("Job array isolation", func() {
        It("should place backend jobs in StorageBackendJobs array", ...)
        It("should place cluster storage jobs in ClusterStorageJobs array", ...)
    })
    Context("Cluster storage failure", func() {
        It("should record failed cluster storage provisioning job", ...)
    })
    Context("Backend condition transition", func() {
        It("should transition StorageBackendReady from True to False", ...)
    })
    Context("Deprovisioning ordering", func() { ... })
})
```

### Mock provisioning provider pattern

```go
// Create a mock provisioning provider for AAP
triggerProvisionFunc: func(_ context.Context, _ client.Object) (*provisioning.ProvisionResult, error) {
    return &provisioning.ProvisionResult{
        JobID: "test-job-id",
        State: "Succeeded",
    }, nil
}
```

### Condition assertion pattern

```go
// Read and assert conditions on a CR
tenant := &v1alpha1.Tenant{}
Expect(k8sClient.Get(ctx, types.NamespacedName{Name: "test", Namespace: "osac"}, tenant)).To(Succeed())

cond := meta.FindStatusCondition(tenant.Status.Conditions, "StorageBackendReady")
Expect(cond).NotTo(BeNil())
Expect(cond.Status).To(Equal(metav1.ConditionTrue))
```

### Reconciliation trigger pattern

```go
// Trigger reconciliation manually in envtest
result, err := reconciler.Reconcile(ctx, storageReconcileRequest(
    types.NamespacedName{Name: "test-tenant", Namespace: "osac"},
))
Expect(err).NotTo(HaveOccurred())
```

## Other Controller Tests

Same pattern for all controllers — envtest + mock providers:

| Controller | Test File | Key Contexts |
|-----------|-----------|-------------|
| Storage | `storage_controller_test.go` | Stage 1/2 provisioning, tier resolution, finalizers, deletion |
| ClusterOrder | `clusterorder_controller_test.go` | Cluster lifecycle, HyperShift integration |
| ComputeInstance | `computeinstance_controller_test.go` | VM lifecycle, restart, power management |
| Tenant | `tenant_controller_test.go` | Tenant provisioning, Keycloak sync |
| VirtualNetwork | `virtualnetwork_controller_test.go` | Network provisioning via Netris |
| Subnet | `subnet_controller_test.go` | Subnet CIDR allocation |
| SecurityGroup | `securitygroup_controller_test.go` | Firewall rules |
