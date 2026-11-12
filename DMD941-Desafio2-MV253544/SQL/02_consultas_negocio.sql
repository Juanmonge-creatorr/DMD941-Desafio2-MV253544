/* DMD941 - Desafio Practico 2 - Juan Carlos Monge Ventura (MV253544)
   Seccion 5: Consultas SQL para las preguntas de negocio
   Utilidad = SalesAmount - TotalProductCost. Se combinan Internet y Reseller. */
USE AdventureWorksDW2022;
GO

/* Vista auxiliar con las ventas de ambos canales */
CREATE OR ALTER VIEW dbo.vVentasDMD941 AS
SELECT 'Internet' AS Canal, ProductKey, OrderDateKey, SalesTerritoryKey,
       SalesAmount, TotalProductCost, SalesAmount - TotalProductCost AS Utilidad
FROM dbo.FactInternetSales
UNION ALL
SELECT 'Reseller', ProductKey, OrderDateKey, SalesTerritoryKey,
       SalesAmount, TotalProductCost, SalesAmount - TotalProductCost
FROM dbo.FactResellerSales;
GO

/* P1a. Categorias y subcategorias con mayores ventas por anio (ranking dentro de cada anio) */
WITH v AS (
    SELECT d.CalendarYear AS Anio, c.SpanishProductCategoryName AS Categoria,
           sc.SpanishProductSubcategoryName AS Subcategoria, SUM(f.SalesAmount) AS Ventas
    FROM dbo.vVentasDMD941 f
    JOIN dbo.DimDate d ON d.DateKey = f.OrderDateKey
    JOIN dbo.DimProduct p ON p.ProductKey = f.ProductKey
    JOIN dbo.DimProductSubcategory sc ON sc.ProductSubcategoryKey = p.ProductSubcategoryKey
    JOIN dbo.DimProductCategory c ON c.ProductCategoryKey = sc.ProductCategoryKey
    GROUP BY d.CalendarYear, c.SpanishProductCategoryName, sc.SpanishProductSubcategoryName
)
SELECT Anio, Categoria, Subcategoria, Ventas, Ranking
FROM (SELECT *, RANK() OVER (PARTITION BY Anio ORDER BY Ventas DESC) AS Ranking FROM v) r
WHERE Ranking <= 5
ORDER BY Anio, Ranking;

/* P1b. Tendencia trimestral por categoria (variacion % vs trimestre anterior) */
WITH t AS (
    SELECT c.SpanishProductCategoryName AS Categoria, d.CalendarYear AS Anio,
           d.CalendarQuarter AS Trimestre, SUM(f.SalesAmount) AS Ventas
    FROM dbo.vVentasDMD941 f
    JOIN dbo.DimDate d ON d.DateKey = f.OrderDateKey
    JOIN dbo.DimProduct p ON p.ProductKey = f.ProductKey
    JOIN dbo.DimProductSubcategory sc ON sc.ProductSubcategoryKey = p.ProductSubcategoryKey
    JOIN dbo.DimProductCategory c ON c.ProductCategoryKey = sc.ProductCategoryKey
    GROUP BY c.SpanishProductCategoryName, d.CalendarYear, d.CalendarQuarter
)
SELECT Categoria, Anio, Trimestre, Ventas,
       LAG(Ventas) OVER (PARTITION BY Categoria ORDER BY Anio, Trimestre) AS VentasTrimAnterior,
       CAST(100.0 * (Ventas - LAG(Ventas) OVER (PARTITION BY Categoria ORDER BY Anio, Trimestre))
            / NULLIF(LAG(Ventas) OVER (PARTITION BY Categoria ORDER BY Anio, Trimestre), 0) AS decimal(10,2)) AS VariacionPct
FROM t
ORDER BY Categoria, Anio, Trimestre;

/* P2. Territorios con mayor rentabilidad, comparando Internet vs Reseller */
SELECT t.SalesTerritoryRegion AS Region, t.SalesTerritoryCountry AS Pais,
       SUM(f.SalesAmount) AS VentasTotales,
       SUM(f.Utilidad) AS UtilidadTotal,
       CAST(100.0 * SUM(f.Utilidad) / NULLIF(SUM(f.SalesAmount), 0) AS decimal(10,2)) AS MargenPct,
       SUM(CASE WHEN f.Canal = 'Internet' THEN f.Utilidad END) AS UtilidadInternet,
       SUM(CASE WHEN f.Canal = 'Reseller' THEN f.Utilidad END) AS UtilidadReseller,
       CAST(100.0 * SUM(CASE WHEN f.Canal = 'Internet' THEN f.Utilidad END)
            / NULLIF(SUM(CASE WHEN f.Canal = 'Internet' THEN f.SalesAmount END), 0) AS decimal(10,2)) AS MargenInternetPct,
       CAST(100.0 * SUM(CASE WHEN f.Canal = 'Reseller' THEN f.Utilidad END)
            / NULLIF(SUM(CASE WHEN f.Canal = 'Reseller' THEN f.SalesAmount END), 0) AS decimal(10,2)) AS MargenResellerPct
FROM dbo.vVentasDMD941 f
JOIN dbo.DimSalesTerritory t ON t.SalesTerritoryKey = f.SalesTerritoryKey
GROUP BY t.SalesTerritoryRegion, t.SalesTerritoryCountry
ORDER BY UtilidadTotal DESC;

/* P3a. Top 10 productos mas rentables */
SELECT TOP 10 p.ProductKey, p.EnglishProductName AS Producto,
       SUM(f.SalesAmount) AS Ventas, SUM(f.Utilidad) AS Utilidad
FROM dbo.vVentasDMD941 f
JOIN dbo.DimProduct p ON p.ProductKey = f.ProductKey
GROUP BY p.ProductKey, p.EnglishProductName
ORDER BY Utilidad DESC;

/* P3b. Distribucion de la utilidad del Top 10 por anio y trimestre */
WITH top10 AS (
    SELECT TOP 10 ProductKey FROM dbo.vVentasDMD941
    GROUP BY ProductKey ORDER BY SUM(Utilidad) DESC
)
SELECT p.EnglishProductName AS Producto, d.CalendarYear AS Anio,
       d.CalendarQuarter AS Trimestre, SUM(f.Utilidad) AS Utilidad
FROM dbo.vVentasDMD941 f
JOIN top10 ON top10.ProductKey = f.ProductKey
JOIN dbo.DimProduct p ON p.ProductKey = f.ProductKey
JOIN dbo.DimDate d ON d.DateKey = f.OrderDateKey
GROUP BY p.EnglishProductName, d.CalendarYear, d.CalendarQuarter
ORDER BY d.CalendarYear, d.CalendarQuarter, Utilidad DESC;
