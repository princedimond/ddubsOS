# Guía de Personalización de Vicinae

## Eliminar Elementos Predeterminados No Deseados

Vicinae viene con varios elementos integrados que pueden no ser relevantes para tu configuración. Aquí te mostramos cómo eliminarlos o deshabilitarlos.

### Método 1: Configuración NixOS (Automatizada)

El módulo vicinae de ddubsOS ya incluye configuración para deshabilitar muchos elementos no deseados:

```nix
# Ya configurado en modules/home/vicinae.nix
builtins = {
  # Elementos deshabilitados
  store.enabled = false;              # Tienda de extensiones
  documentation.enabled = false;      # Enlaces de documentación
  sponsor.enabled = false;            # Enlaces de patrocinio/financiación
  themeManager.enabled = false;       # Navegador de temas
  extensionStore.enabled = false;     # Marketplace de extensiones
  
  # Elementos útiles habilitados
  applications.enabled = true;        # Lanzador de aplicaciones
  system.enabled = true;             # Controles del sistema
};
```

### Método 2: Configuración Manual (Ajuste Fino)

Después de que Vicinae se inicie por primera vez, puedes editar manualmente la configuración:

#### Ubicación del Archivo de Configuración
```bash
~/.config/vicinae/vicinae.json
```

#### Ejemplo de Ediciones de Configuración

```json
{
  "builtins": {
    "store": {
      "enabled": false,
      "showInRootSearch": false
    },
    "documentation": {
      "enabled": false,
      "showInRootSearch": false
    },
    "sponsor": {
      "enabled": false,
      "showInRootSearch": false
    },
    "themeManager": {
      "enabled": false,
      "showInRootSearch": false
    },
    "raycastStore": {
      "enabled": false,
      "showInRootSearch": false
    }
  },
  "rootSearch": {
    "hiddenBuiltins": [
      "store",
      "documentation", 
      "sponsor",
      "themeManager",
      "extensionStore",
      "raycast-store",
      "manage-extensions",
      "get-help",
      "report-bug",
      "upgrade-vicinae",
      "about-vicinae"
    ]
  }
}
```

### Método 3: Configuración por Interfaz (Interactiva)

1. Lanza Vicinae (`Alt+Espacio`)
2. Escribe "preferencias" o "configuración"
3. Navega a la sección de Elementos Integrados o Extensiones
4. Desactiva los elementos no deseados:
   - ❌ **Tienda** - Marketplace de extensiones
   - ❌ **Documentación** - Enlaces de ayuda
   - ❌ **Patrocinador** - Enlaces de financiación/donación
   - ❌ **Administrador de Temas** - Navegador de temas (si no se necesita)
   - ❌ **Obtener Ayuda** - Enlaces de soporte
   - ❌ **Reportar Error** - Reportes de errores
   - ❌ **Actualizar** - Notificaciones de actualización

### Elementos que Mantener Habilitados ✅

**Funcionalidad principal:**
- ✅ **Aplicaciones** - Lanzar aplicaciones instaladas
- ✅ **Sistema** - Controles del sistema (cerrar sesión, apagar, etc.)
- ✅ **Calculadora** - Expresiones matemáticas
- ✅ **Historial del Portapapeles** - Elementos recientes del portapapeles
- ✅ **Búsqueda de Archivos** - Buscar archivos
- ✅ **Accesos Directos** - Marcadores/enlaces rápidos

**Herramientas para desarrolladores (si usas el perfil developer):**
- ✅ **Terminal** - Acceso rápido al terminal
- ✅ **Administrador de Procesos** - Terminar procesos
- ✅ **Red** - Información de IP, estado de red

### Configuración Mínima Limpia

Para la experiencia más limpia, deshabilita todo excepto:
```json
{
  "builtins": {
    "applications": { "enabled": true },
    "calculator": { "enabled": true },
    "clipboardHistory": { "enabled": true },
    "fileSearch": { "enabled": true },
    "system": { "enabled": true }
  }
}
```

### Solución de Problemas

**¿La configuración no se aplica?**
1. Reinicia Vicinae: `pkill vicinae && vicinae server &`
2. Verifica la sintaxis de configuración: `cat ~/.config/vicinae/vicinae.json | jq .`
3. Restablecer a valores predeterminados: `rm ~/.config/vicinae/vicinae.json`

**¿Los elementos siguen apareciendo?**
1. Limpia la caché: `rm -rf ~/.local/share/vicinae/cache`
2. Verifica las configuraciones de usuario en la interfaz
3. Algunos elementos pueden estar codificados y requerir deshabilitación por interfaz

**Rendimiento después de la personalización:**
- Menos elementos integrados habilitados = búsqueda más rápida
- Deshabilita extensiones no utilizadas para mejor rendimiento
- Usa el perfil `minimal` o `standard` para configuraciones básicas

### Recomendaciones por Perfil

**Perfil Mínimo:**
- Solo Aplicaciones + Calculadora
- Sin extensiones, sin características avanzadas

**Perfil Estándar:** 
- Aplicaciones, Calculadora, Portapapeles, Búsqueda de Archivos
- Sin tienda, documentación o extensiones

**Perfil Desarrollador:**
- Todas las herramientas útiles habilitadas
- Elementos de tienda/patrocinador deshabilitados
- Extensiones habilitadas para herramientas de desarrollo

**Perfil Usuario Avanzado:**
- Todas las características excepto elementos de marketing
- Búsqueda avanzada e indexación
- Soporte para extensiones personalizadas

### Comandos Útiles

**Reiniciar el servicio Vicinae:**
```bash
systemctl --user restart vicinae
```

**Ver logs del servicio:**
```bash
journalctl --user -u vicinae -f
```

**Verificar estado del servicio:**
```bash
systemctl --user status vicinae
```

**Limpiar toda la configuración:**
```bash
rm -rf ~/.config/vicinae
rm -rf ~/.local/share/vicinae
```

### Personalización Avanzada

**Cambiar la transparencia de la ventana:**
```json
{
  "window": {
    "opacity": 0.90
  }
}
```

**Ajustar el redondeado de esquinas:**
```json
{
  "window": {
    "rounding": 20
  }
}
```

**Configurar atajos de teclado personalizados:**
```json
{
  "shortcuts": {
    "toggleLauncher": "Alt+Space",
    "closeWindow": "Escape"
  }
}
```

### Integración con ddubsOS

**Cambiar perfil en variables.nix:**
```nix
# En hosts/tu-host/variables.nix
{
  enableVicinae = true;
  vicinaeProfile = "developer";  # minimal, standard, developer, power-user
}
```

**Aplicar cambios:**
```bash
sudo nixos-rebuild switch --flake .#tu-host
```

Esta configuración te proporciona un lanzador limpio y rápido enfocado en la productividad en lugar del descubrimiento de características.

## Consejos Adicionales

- **Rendimiento**: El perfil mínimo es ideal para máquinas con recursos limitados
- **Productividad**: El perfil estándar es perfecto para uso diario
- **Desarrollo**: El perfil developer incluye herramientas específicas para programadores
- **Poder**: El perfil power-user activa todas las características para usuarios expertos

¡Disfruta de tu lanzador personalizado! 🚀
