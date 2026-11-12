# DMD941 – Desafío Práctico 2

**Universidad Don Bosco · Datawarehouse y Minería de Datos (DMD941)**
**Docente:** Ing. Katherine Vigil
**Estudiante:** Juan Carlos Monge Ventura (MV253544)

Solución OLAP sobre **AdventureWorksDW2022**. Incluye la restauración de la base, un cubo multidimensional en SQL Server Analysis Services, consultas SQL/MDX para tres preguntas de negocio y un dashboard de Power BI conectado en vivo al cubo.

## Preguntas de negocio
1. ¿Qué categorías y subcategorías tienen mayores ventas por año, y cuál es su tendencia de un trimestre a otro?
2. ¿Qué territorios son más rentables, comparando las ventas por Internet contra las de Reseller?
3. ¿Cuáles son los 10 productos más rentables y cómo se distribuye su utilidad por año y trimestre?

## Estructura
| Carpeta | Contenido |
|---|---|
| `SSAS/` | `Crear_Cubo_DMD941.xmla`: definición completa de la base OLAP `DMD941_AdventureWorks_OLAP` (origen de datos, DSV, dimensiones y cubo `Ventas AW`) |
| `SQL/` | `01_exploracion_tablas.sql`, `02_consultas_negocio.sql` |
| `MDX/` | `consultas_mdx.mdx` |
| `PowerBI/` | `Dashboard_DMD941_Desafio2.pbix` (conexión en vivo al cubo) |
| `Informe/` | Informe en PDF con capturas y análisis |

## Modelo del cubo `Ventas AW`
- **Hechos:** `vFactSales`, que une `FactInternetSales` y `FactResellerSales` con UNION ALL y agrega `CanalKey`.
- **Medidas:** Ventas, Costo, Utilidad (SalesAmount − TotalProductCost), Cantidad y el miembro calculado **Margen %**.
- **Dimensiones:**
  - **Fecha:** Año → Trimestre → Mes → Fecha
  - **Producto:** Categoría → Subcategoría → Producto
  - **Territorio:** Grupo → País → Región
  - **Canal:** Internet / Reseller

## Cómo reproducirlo
1. Restaurar `AdventureWorksDW2022.bak` en SQL Server 2025 (instancia predeterminada). Ver el informe, sección 2.
2. Dar lectura a la cuenta de servicio de SSAS: `NT SERVICE\MSSQLServerOLAPService` con el rol `db_datareader`.
3. En SSMS, conectarse a Analysis Services (modo Multidimensional). Abrir una consulta XMLA, ejecutar `SSAS/Crear_Cubo_DMD941.xmla` y luego:
   ```xml
   <Process xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
     <Type>ProcessFull</Type>
     <Object><DatabaseID>DMD941_AdventureWorks_OLAP</DatabaseID></Object>
   </Process>
   ```
   Para editar el cubo en Visual Studio 2022, crear un proyecto **Import from Server (Multidimensional)** apuntando a `localhost`.
4. Ejecutar las consultas de `SQL/` (Database Engine) y de `MDX/` (Analysis Services).
5. Abrir `PowerBI/Dashboard_DMD941_Desafio2.pbix`. Usa conexión en vivo a `localhost` / `DMD941_AdventureWorks_OLAP`.
