/* DMD941 - Desafio Practico 2 - Juan Carlos Monge Ventura (MV253544)
   Seccion 3: Exploracion de tablas de AdventureWorksDW2022 */
USE AdventureWorksDW2022;
GO

-- 1. Cantidad de registros de las tablas usadas en el modelo
SELECT 'FactInternetSales' AS Tabla, COUNT(*) AS Registros FROM dbo.FactInternetSales
UNION ALL SELECT 'FactResellerSales', COUNT(*) FROM dbo.FactResellerSales
UNION ALL SELECT 'DimProduct', COUNT(*) FROM dbo.DimProduct
UNION ALL SELECT 'DimProductSubcategory', COUNT(*) FROM dbo.DimProductSubcategory
UNION ALL SELECT 'DimProductCategory', COUNT(*) FROM dbo.DimProductCategory
UNION ALL SELECT 'DimDate', COUNT(*) FROM dbo.DimDate
UNION ALL SELECT 'DimSalesTerritory', COUNT(*) FROM dbo.DimSalesTerritory;

-- 2. Rango de fechas de las ventas
SELECT MIN(d.FullDateAlternateKey) AS PrimeraVenta, MAX(d.FullDateAlternateKey) AS UltimaVenta
FROM (SELECT OrderDateKey FROM dbo.FactInternetSales
      UNION ALL SELECT OrderDateKey FROM dbo.FactResellerSales) f
JOIN dbo.DimDate d ON d.DateKey = f.OrderDateKey;

-- 3. Jerarquia de productos (categorias y numero de subcategorias / productos)
SELECT c.SpanishProductCategoryName AS Categoria,
       COUNT(DISTINCT sc.ProductSubcategoryKey) AS Subcategorias,
       COUNT(p.ProductKey) AS Productos
FROM dbo.DimProductCategory c
JOIN dbo.DimProductSubcategory sc ON sc.ProductCategoryKey = c.ProductCategoryKey
JOIN dbo.DimProduct p ON p.ProductSubcategoryKey = sc.ProductSubcategoryKey
GROUP BY c.SpanishProductCategoryName;

-- 4. Territorios de venta
SELECT SalesTerritoryKey, SalesTerritoryRegion, SalesTerritoryCountry, SalesTerritoryGroup
FROM dbo.DimSalesTerritory ORDER BY SalesTerritoryKey;
