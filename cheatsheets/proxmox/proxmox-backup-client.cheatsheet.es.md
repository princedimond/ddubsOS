# Referencia rápida de Proxmox Backup Client (ayudantes ddubsOS)

Variables de entorno

- PBS_REPOSITORY: user@realm@host:port:datastore (ej.: root@pam@192.168.40.15:8007:PBS-LUN2)
- PBS_FINGERPRINT: huella TLS SHA-256 (verifícala antes de usar)
- BACKUP_ID: id del grupo (por defecto: "$(hostname)-$USER-home")
- PBS_ENCRYPTION_KEY_FILE: ruta a clave de cifrado del cliente (pxar)
- PBS_PASSWORD: contraseña o secreto de token API (se solicita si no está definida)

Tareas comunes

- Mostrar configuración efectiva
  pbs-home-show

- Copia de seguridad del home (pxar) con excluidos razonables
  pbs-home-backup \
    --exclude "$HOME/.cache/**" \
    --exclude "$HOME/.local/share/Trash/**"
  # Excluidos extra vía entorno: PBS_EXCLUDE_PATHS="$HOME/.npm:$HOME/.cargo/registry"

- Listar snapshots del grupo
  pbs-home-ls
  # JSON bonito: pbs-home-ls --output-format json-pretty

- Último snapshot (timestamp)
  pbs-home-last

- Restaurar el último snapshot
  pbs-home-restore-last "$HOME/restore-latest"
  # Omite el dir destino para restaurar en ~/restore-<SNAPSHOT>

- Restaurar un snapshot concreto a un directorio
  pbs-home-restore 2025-09-24T02:10:45Z "$HOME/restore"

- Restaurar un solo archivo (cliente raw)
  proxmox-backup-client restore \
    --repository "$PBS_REPOSITORY" \
    host/$BACKUP_ID/2025-09-24T02:10:45Z \
    home.pxar "$HOME/restore" \
    --allow-existing-dirs \
    --include 'Documents/important.pdf'

- Prune de retención (por defecto)
  # KEEP_LAST=7 KEEP_DAILY=14 KEEP_WEEKLY=8 KEEP_MONTHLY=12
  pbs-home-prune
  # Personaliza: KEEP_LAST=10 KEEP_DAILY=30 pbs-home-prune

- Verificar copias (lectura de catálogo)
  pbs-home-verify        # último
  pbs-home-verify all    # todos los snapshots

Comprobar huella TLS

openssl s_client -connect 192.168.40.15:8007 -servername 192.168.40.15 </dev/null 2>/dev/null | openssl x509 -noout -fingerprint -sha256

Secretos y automatización

- Usa un archivo de entorno con permisos 600 para systemd o un gestor de secretos (sops-nix/agenix)
- Para tokens API: PBS_REPOSITORY=user@realm!TOKEN@host:port:datastore y PBS_PASSWORD al secreto del token