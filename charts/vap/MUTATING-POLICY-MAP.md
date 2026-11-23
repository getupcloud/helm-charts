# Mapa de ValidatingAdmissionPolicy para MutatingAdmissionPolicy

Este documento mapeia as políticas do chart `vap` (lidas em `main`) para possíveis políticas mutadoras. É um inventário/proposta, não um conjunto de manifests pronto para instalação.

## Limites de equivalência

`ValidatingAdmissionPolicy` rejeita ou alerta sobre um objeto; `MutatingAdmissionPolicy` altera o objeto durante a admissão. Portanto, uma validação não tem conversão automática 1:1: para cada violação seria necessário escolher um valor substituto e aceitar possíveis mudanças de comportamento. Os nomes de MAP e Binding abaixo são nomes propostos, seguindo o nome da VAP com os prefixos `mutate-` e `mutate-` respectivamente.

Os candidatos marcados como **candidato** podem ser implementados com `MutatingAdmissionPolicy` e um `MutatingAdmissionPolicyBinding` apontando para a política e usando o mesmo escopo de namespace da VAP (`vap.getup.io/enabled: "true"`). Antes de instalar, confirme que a versão do Kubernetes do cluster oferece a versão da API de MAP usada pelos manifests e revise os impactos da mutação. Os demais não têm uma mutação segura/determinística equivalente com as informações disponíveis no chart.

## Políticas globais

| ValidatingAdmissionPolicy | MutatingAdmissionPolicy / Binding propostos | Mutação possível | Avaliação |
| --- | --- | --- | --- |
| `getup-g-100-secure-namespace` | `mutate-getup-g-100-secure-namespace` / `mutate-getup-g-100-secure-namespace` | Incluir o label `vap.getup.io/enabled: "false"` quando label e annotation estiverem ausentes. | Candidato; permite criar Namespace sem habilitar as políticas por acidente. Confirmar se a annotation também deve ser preenchida. |
| `getup-g-101-delete-protection` | — | A VAP atua em `DELETE`; MAP não transforma a operação de deleção em uma operação mutável equivalente. | Sem equivalente. Manter a VAP. |

## Políticas Marvin

| ValidatingAdmissionPolicy | MutatingAdmissionPolicy / Binding propostos | Mutação possível | Avaliação |
| --- | --- | --- | --- |
| `marvin-m-100-host-process` | `mutate-marvin-m-100-host-process` / `mutate-marvin-m-100-host-process` | Definir `windowsOptions.hostProcess: false` no Pod e nos containers quando ausente ou `true`. | Candidato com ressalva: substituir um `true` explícito pode quebrar workloads Windows que dependem do recurso. |
| `marvin-m-101-host-namespaces` | `mutate-marvin-m-101-host-namespaces` / `mutate-marvin-m-101-host-namespaces` | Definir `hostNetwork`, `hostPID` e `hostIPC` como `false` quando ausentes ou `true`. | Candidato com ressalva; alterações explícitas podem mudar conectividade e isolamento. |
| `marvin-m-102-privileged-containers` | `mutate-marvin-m-102-privileged-containers` / `mutate-marvin-m-102-privileged-containers` | Definir `securityContext.privileged: false`. | Candidato com ressalva; pode impedir workloads que dependem de privilégios. |
| `marvin-m-103-capabilities-baseline` | `mutate-marvin-m-103-capabilities-baseline` / `mutate-marvin-m-103-capabilities-baseline` | Remover de `capabilities.add` os itens que não estejam em `params.settings.allowedCapabilities`. | Candidato, mas remover capabilities pode quebrar aplicações; reutilizar o paramKind e o binding paramRef da VAP. |
| `marvin-m-104-host-path-volumes` | — | Remover ou substituir `hostPath` exige decidir por um volume alternativo e por seus dados/montagem. | Sem equivalente seguro genérico. |
| `marvin-m-105-host-ports` | `mutate-marvin-m-105-host-ports` / `mutate-marvin-m-105-host-ports` | Remover `hostPort` dos ports que não estejam em `params.settings.allowedHostPorts`. | Candidato com ressalva; a remoção muda a forma de exposição da aplicação. |
| `marvin-m-106-apparmor` | `mutate-marvin-m-106-apparmor` / `mutate-marvin-m-106-apparmor` | Substituir profiles não permitidos por um profile permitido, por exemplo `runtime/default`. | Candidato; precisa tratar a annotation legada por container e/ou o campo moderno `appArmorProfile`, e escolher a configuração compatível com o cluster. |
| `marvin-m-107-selinux` | `mutate-marvin-m-107-selinux` / `mutate-marvin-m-107-selinux` | Remover `user`/`role` e escolher um tipo em `params.settings.allowedSELinuxTypes`. | Não recomendado como conversão automática: a escolha de tipo pode depender da política do nó e do workload. |
| `marvin-m-108-proc-mount` | `mutate-marvin-m-108-proc-mount` / `mutate-marvin-m-108-proc-mount` | Definir `securityContext.procMount: Default`. | Candidato; alteração explícita pode mudar o comportamento do container. |
| `marvin-m-109-seccomp-baseline` | `mutate-marvin-m-109-seccomp-baseline` / `mutate-marvin-m-109-seccomp-baseline` | Definir `RuntimeDefault` no nível de Pod ou container quando o profile estiver ausente ou for `Unconfined`. | Candidato; verificar compatibilidade dos workloads e alinhar com a configuração real de `allowedSeccompProfiles` (o chart tem referências inconsistentes entre valores e templates). |
| `marvin-m-110-sysctls` | `mutate-marvin-m-110-sysctls` / `mutate-marvin-m-110-sysctls` | Filtrar de `securityContext.sysctls` os nomes fora de `params.settings.allowedSysctls`. | Candidato com ressalva; pode remover configuração necessária ao workload. |
| `marvin-m-111-volume-types` | — | Substituir tipos de volume não permitidos requer determinar fonte e semântica equivalentes. | Sem equivalente seguro genérico. |
| `marvin-m-112-privilege-escalation` | `mutate-marvin-m-112-privilege-escalation` / `mutate-marvin-m-112-privilege-escalation` | Definir `allowPrivilegeEscalation: false` nos containers. | Candidato com ressalva; pode alterar comportamento de containers que dependem de escalonamento. |
| `marvin-m-113-run-as-non-root` | `mutate-marvin-m-113-run-as-non-root` / `mutate-marvin-m-113-run-as-non-root` | Definir `runAsNonRoot: true` no Pod e/ou container quando ausente. | Candidato; não escolhe um UID e pode tornar imagens incompatíveis com execução sem root. |
| `marvin-m-114-run-as-user` | — | A política exige UID diferente de zero, mas o chart não define um UID substituto seguro. | Sem equivalente genérico. Só implementar após definir UID/GID padrão e estratégia de compatibilidade. |
| `marvin-m-115-seccomp-restricted` | `mutate-marvin-m-115-seccomp-restricted` / `mutate-marvin-m-115-seccomp-restricted` | Definir profile `RuntimeDefault` para Pod e containers sem profile seguro. | Candidato; sobrepõe-se parcialmente a `marvin-m-109-seccomp-baseline`; decidir se ambas devem permanecer ativas. |
| `marvin-m-116-capabilities-restricted` | `mutate-marvin-m-116-capabilities-restricted` / `mutate-marvin-m-116-capabilities-restricted` | Acrescentar `drop: ["ALL"]` e remover capabilities adicionadas fora da allowlist. | Candidato com ressalva; deve preservar itens já definidos e reutilizar os parâmetros do chart. Pode conflitar com a política baseline. |
| `marvin-m-200-allowed-registries` | — | Reescrever a referência da imagem para um registry permitido não é determinístico sem um mapeamento de imagens. | Sem equivalente. |
| `marvin-m-201-app-credentials` | — | Remover ou reescrever valores de ConfigMap/env potencialmente sensíveis pode destruir dados ou credenciais. | Sem equivalente seguro; preferir impedir/revisar a criação e usar Secrets. |
| `marvin-m-202-auto-mount-service-account-token` | `mutate-marvin-m-202-auto-mount-service-account-token` / `mutate-marvin-m-202-auto-mount-service-account-token` | Definir `automountServiceAccountToken: false` quando ausente ou `true`. | Candidato com ressalva; workloads que chamam a API Kubernetes podem parar de funcionar. |
| `marvin-m-203-ssh-server` | — | Desabilitar portas SSH em container e Service requer alterar ports, comandos ou imagem de forma específica ao workload. | Sem equivalente genérico. |
| `marvin-m-300-read-only-root-filesystem` | `mutate-marvin-m-300-read-only-root-filesystem` / `mutate-marvin-m-300-read-only-root-filesystem` | Definir `readOnlyRootFilesystem: true` nos containers. | Candidato com ressalva; aplicações que escrevem no filesystem raiz podem falhar. |
| `marvin-m-400-image-tagged-latest` | — | Escolher uma tag imutável/substituta para `latest` exige conhecer a versão correta da imagem. | Sem equivalente. |
| `marvin-m-401-unmanaged-pod` | — | Criar ownerReferences exige conhecer e validar um controlador proprietário; não há alvo seguro inferível. | Sem equivalente. |
| `marvin-m-402-readiness-probe` | — | Não é possível inferir probes corretos sem conhecer o protocolo e a porta da aplicação. | Sem equivalente. |
| `marvin-m-403-liveness-probe` | — | Não é possível inferir um health check correto sem conhecer o comportamento da aplicação. | Sem equivalente. |
| `marvin-m-404-memory-requests` | — | O chart não informa um valor de memória adequado para o workload. | Sem equivalente genérico; requer valores definidos por aplicação/equipe. |
| `marvin-m-405-cpu-requests` | — | O chart não informa um valor de CPU adequado para o workload. | Sem equivalente genérico; requer valores definidos por aplicação/equipe. |
| `marvin-m-406-memory-limit` | — | O chart não informa um limite de memória adequado. | Sem equivalente genérico; requer valores definidos por aplicação/equipe. |
| `marvin-m-407-cpu-limit` | — | O chart não informa um limite de CPU adequado. | Sem equivalente genérico; requer valores definidos por aplicação/equipe. |
| `marvin-m-408-sudo-container-entrypoint` | — | Remover `sudo` do command/args requer conhecer o usuário e a forma correta de execução da imagem. | Sem equivalente genérico. |
| `marvin-m-409-deprecated-image-registry` | — | A substituição do registry precisa de um mapeamento de imagens e tags. | Sem equivalente; além disso, a VAP e os valores do chart parecem usar grafias diferentes para o registry. |
| `marvin-m-410-resource-using-invalid-restartpolicy` | `mutate-marvin-m-410-resource-using-invalid-restartpolicy` / `mutate-marvin-m-410-resource-using-invalid-restartpolicy` | Definir `spec.template.spec.restartPolicy: Always` quando ausente ou diferente. | Candidato; manter o escopo original da VAP (Deployments, DaemonSets e ReplicaSets), pois não vale para todos os workloads. |
| `marvin-m-411-role-binding-referencing-anonymous-or-unauthenticated` | — | Remover sujeitos modifica permissões RBAC e não há forma segura de decidir quais bindings devem ser preservados. | Sem equivalente. |
| `marvin-m-500-workload-in-default-namespace` | — | O namespace faz parte do destino do objeto e não deve ser reescrito automaticamente pela política. | Sem equivalente; corrigir no manifesto/chart de origem. |

## Próximos passos para implementar os candidatos

1. Definir se MAPs devem corrigir apenas campos ausentes ou também sobrescrever valores explícitos que violam as VAPs.
2. Definir a versão mínima de Kubernetes e a versão exata da API de `MutatingAdmissionPolicy` suportada pelos clusters.
3. Criar os manifests de MAP e MAPBinding para os candidatos aprovados, preservando matchConstraints, escopo, params e nomes configuráveis do chart.
4. Testar com manifests representativos e renderizar o Helm chart no container do projeto, usando `docker exec {projeto} {comando_desejado}` para comandos de teste/build.
5. Manter as VAPs como validação final, pelo menos durante a adoção inicial, para detectar mutações insuficientes ou incompatíveis.
