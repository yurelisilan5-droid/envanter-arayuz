-- ==========================================================================
-- PRO ENVANTER YÖNETİM SİSTEMİ - KURUMSAL VERİ TABANI ŞEMASI (DDL)
-- Hedef Motor: Microsoft SQL Server (MSSQL)
-- Tasarım Tipi: İleri Düzey İlişkisel Veri Modelleme (Relational Modeling)
-- ==========================================================================

USE master;
GO

-- 1. VERİ TABANI OLUŞTURMA (Güvenli Kurulum Kontrolü)
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'EnvanterDB')
BEGIN
    CREATE DATABASE EnvanterDB;
    PRINT 'EnvanterDB veri tabanı başarıyla oluşturuldu.';
END
ELSE
BEGIN
    PRINT 'EnvanterDB veri tabanı zaten mevcut.';
END
GO

-- Oluşturulan veya mevcut olan veri tabanına geçiş yapıyoruz
USE EnvanterDB;
GO

-- Şema standardı olarak kurumsal projelerde her zaman "dbo" (Database Owner) ön eki kullanılır.

-- ==========================================================================
-- 2. KATEGORİLER TABLOSU (dbo.Kategoriler)
-- ==========================================================================
IF OBJECT_ID('dbo.Kategoriler', 'U') IS NOT NULL
BEGIN
    PRINT 'dbo.Kategoriler tablosu sistemde zaten mevcut, atlanıyor.';
END
ELSE
BEGIN
    CREATE TABLE dbo.Kategoriler (
        KategoriId INT IDENTITY(1,1) NOT NULL,
        KategoriAdi NVARCHAR(100) NOT NULL,
        
        -- Endüstri Standardı: Loglama ve Denetim Kolonları
        OlusturmaTarihi DATETIME DEFAULT GETDATE() NOT NULL,
        AktifMi BIT DEFAULT 1 NOT NULL,

        -- Primary Key ve Veri bütünlüğü kısıtlamaları
        CONSTRAINT PK_Kategoriler PRIMARY KEY CLUSTERED (KategoriId),
        CONSTRAINT UQ_Kategoriler_KategoriAdi UNIQUE (KategoriAdi) -- Mükerrer kayıt girişini önler
    );
    PRINT 'dbo.Kategoriler tablosu başarıyla oluşturuldu.';
END
GO

-- ==========================================================================
-- 3. ÜRÜNLER TABLOSU (dbo.Urunler)
-- ==========================================================================
IF OBJECT_ID('dbo.Urunler', 'U') IS NOT NULL
BEGIN
    PRINT 'dbo.Urunler tablosu sistemde zaten mevcut, atlanıyor.';
END
ELSE
BEGIN
    CREATE TABLE dbo.Urunler (
        UrunId INT IDENTITY(1,1) NOT NULL,
        UrunAdi NVARCHAR(150) NOT NULL,
        StokAdedi INT NOT NULL DEFAULT 0,
        KritikStokSeviyesi INT NOT NULL DEFAULT 10,
        KategoriId INT NOT NULL, -- İlişkisel bütünlük bozulmasın diye boş geçilemez yapıldı

        -- Endüstri Standardı: Loglama ve Denetim Kolonları
        OlusturmaTarihi DATETIME DEFAULT GETDATE() NOT NULL,
        AktifMi BIT DEFAULT 1 NOT NULL,

        -- Birincil Anahtar
        CONSTRAINT PK_Urunler PRIMARY KEY CLUSTERED (UrunId),
        
        -- İş Kuralları Doğrulaması (Business Logic Constraints)
        CONSTRAINT CK_Urunler_StokAdedi CHECK (StokAdedi >= 0),
        CONSTRAINT CK_Urunler_KritikStokSeviyesi CHECK (KritikStokSeviyesi >= 0),
        
        -- Yabancı Anahtar (Foreign Key) İlişkisi
        CONSTRAINT FK_Urunler_Kategoriler FOREIGN KEY (KategoriId)
            REFERENCES dbo.Kategoriler (KategoriId)
            ON DELETE NO ACTION -- Güvenli silme kuralı
    );
    PRINT 'dbo.Urunler tablosu başarıyla oluşturuldu.';
END
GO

-- ==========================================================================
-- 4. PERFORMANS OPTİMİZASYONU VE SORGULAR İÇİN İNDEKSLEME
-- ==========================================================================
-- Foreign Key kolonları üzerinde indeks oluşturmak, tablonun JOIN işlemlerinde sorgu hızını katlar.
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_Urunler_KategoriId' AND object_id = OBJECT_ID('dbo.Urunler'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Urunler_KategoriId 
    ON dbo.Urunler (KategoriId);
    PRINT 'İlişkisel sorgu optimizasyonu için IX_Urunler_KategoriId indeksi başarıyla oluşturuldu.';
END
GO