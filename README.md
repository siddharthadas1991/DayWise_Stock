# ZMATL_DAYWISE_STOCK – Eclipse ADT Package
## SAP S/4HANA Public Cloud · Day-Wise Material Opening & Closing Stock

---

## Package Contents

```
ZMATL_DAYWISE_STOCK/
├── .abapgit.xml                              ← abapgit project config
├── README.md                                 ← this file
└── src/
    ├── package.devc.xml                      ← ABAP package definition
    │
    │── LAYER 1 – Base View (Daily Movements)
    ├── zi_matl_movement_daily.ddls.asddls    ← CDS DDL source
    ├── zi_matl_movement_daily.ddls.xml       ← CDS metadata
    │
    │── LAYER 2 – Calculation View (Opening / Closing Stock)
    ├── zi_matl_stock_daily.ddls.asddls       ← CDS DDL source
    ├── zi_matl_stock_daily.ddls.xml          ← CDS metadata
    │
    │── LAYER 3 – Consumption View (Fiori / OData / SAC)
    ├── zc_matl_daywise_stock_rpt.ddls.asddls ← CDS DDL source
    ├── zc_matl_daywise_stock_rpt.ddls.xml    ← CDS metadata
    ├── zc_matl_daywise_stock_rpt.ddlx.asddlx ← Metadata Extension (Charts)
    ├── zc_matl_daywise_stock_rpt.ddlx.xml    ← Metadata Ext metadata
    ├── zc_matl_daywise_stock_rpt.dcls.asdcls ← Access Control (DCL)
    ├── zc_matl_daywise_stock_rpt.dcls.xml    ← DCL metadata
    │
    │── OData V4 Service
    ├── zmatl_daystock_sd.srvd.asrvd          ← Service Definition
    ├── zmatl_daystock_sd.srvd.xml            ← Service Definition metadata
    ├── zmatl_daystock_sb.srvb.assrvb         ← Service Binding (OData V4 UI)
    └── zmatl_daystock_sb.srvb.xml            ← Service Binding metadata
```

---

## Prerequisites

| Requirement | Detail |
|-------------|--------|
| System | SAP S/4HANA Public Cloud 2402+ |
| IDE | Eclipse 2023-12 + ADT plug-in 3.39+ |
| abapgit | Version 1.128+ (for import via abapgit) |
| Transport | Customer namespace `Z` and `Y` must be available |
| Auth | Developer user with `S_DEVELOP` and `S_TRANSPRT` |

---

## Import via abapgit (Recommended)

### Option A – abapgit Online (GitHub)

1. Push this repository to your GitHub/GitLab/Bitbucket account.
2. In Eclipse ADT → right-click your system → **abapgit Repositories**.
3. Click **New Online Repository** → enter the Git URL.
4. Set **Starting Folder** to `/src/` and **Package** to `ZMATL_DAYWISE_STOCK`.
5. Click **Pull** → assign to a transport request.

### Option B – abapgit Offline (ZIP)

1. Download the ZIP from this repository.
2. In Eclipse ADT → abapgit → **New Offline Repository**.
3. Select the ZIP file and set the package to `ZMATL_DAYWISE_STOCK`.
4. Click **Pull** → assign to a transport request.

---

## Manual Import via ADT (Without abapgit)

> Create objects in the exact order below – each depends on the previous.

### Step 1 – Create the ABAP Package
```
File → New → ABAP Package
  Name        : ZMATL_DAYWISE_STOCK
  Description : Day-Wise Material Stock Report
  Package Type: Development
  SW Component: HOME (or your component)
```
Assign to a transport request.

### Step 2 – Create Layer 1 CDS View
```
File → New → Other → ABAP → Core Data Services → Data Definition
  Name   : ZI_MATL_MOVEMENT_DAILY
  Package: ZMATL_DAYWISE_STOCK
  Template: Define View Entity
```
Paste content from `zi_matl_movement_daily.ddls.asddls` → **Activate (Ctrl+F3)**.

### Step 3 – Create Layer 2 CDS View
```
  Name   : ZI_MATL_STOCK_DAILY
  Package: ZMATL_DAYWISE_STOCK
  Template: Define View Entity
```
Paste `zi_matl_stock_daily.ddls.asddls` → **Activate**.

### Step 4 – Create Layer 3 CDS View (Consumption)
```
  Name   : ZC_MATL_DAYWISE_STOCK_RPT
  Package: ZMATL_DAYWISE_STOCK
  Template: Define View Entity
```
Paste `zc_matl_daywise_stock_rpt.ddls.asddls` → **Activate**.

### Step 5 – Create Metadata Extension
```
File → New → Other → ABAP → Core Data Services → Metadata Extension
  Name   : ZC_MATL_DAYWISE_STOCK_RPT
  Package: ZMATL_DAYWISE_STOCK
```
Paste `zc_matl_daywise_stock_rpt.ddlx.asddlx` → **Activate**.

### Step 6 – Create Access Control
```
File → New → Other → ABAP → Core Data Services → Access Control
  Name   : ZC_MATL_DAYWISE_STOCK_RPT
  Package: ZMATL_DAYWISE_STOCK
```
Paste `zc_matl_daywise_stock_rpt.dcls.asdcls` → **Activate**.

### Step 7 – Create Service Definition
```
File → New → Other → ABAP → Business Services → Service Definition
  Name   : ZMATL_DAYSTOCK_SD
  Package: ZMATL_DAYWISE_STOCK
```
Paste `zmatl_daystock_sd.srvd.asrvd` → **Activate**.

### Step 8 – Create Service Binding
```
File → New → Other → ABAP → Business Services → Service Binding
  Name        : ZMATL_DAYSTOCK_SB
  Service Def : ZMATL_DAYSTOCK_SD
  Binding Type: OData V4 - UI
  Package     : ZMATL_DAYWISE_STOCK
```
→ **Activate** → click **Publish**.

---

## Post-Deployment: Fiori Launchpad Configuration

### Create IAM App and Business Catalog
1. **Identity and Access Management → Manage Launchpad Settings**
2. Create a new **App** pointing to the published service binding `ZMATL_DAYSTOCK_SB`
3. Add the app to a **Business Catalog** (e.g., `SAP_MM_BC_STOCK_REPORT`)
4. Assign the catalog to a **Business Role**
5. Assign the role to users via **Maintain Business Users**

### Launchpad Tile Parameters
| Parameter | Value |
|-----------|-------|
| App Type | Analytical List Page (ALP) |
| Entity Set | `DayWiseMaterialStock` |
| Chart Qualifier | `StockTrendChart` |
| Default Sort | `PostingDate Ascending` |

---

## Transport Strategy

For Public Cloud, use **Software Collection** transport:

```
Transport Request Type : Workbench (K)
Objects to transport   : All objects in package ZMATL_DAYWISE_STOCK
Target system          : Your QA / Production tenant
```

Release the transport in **Manage Software Collections** (SAP Fiori app).

---

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Activation error on Layer 2 | Layer 1 not yet active | Activate `ZI_MATL_MOVEMENT_DAILY` first |
| OData service not visible | Service Binding not published | Open SRVB object → click Publish |
| Empty report result | Date filter too narrow OR no postings in range | Widen date range or check `MATDOC` entries |
| Authorization error | Missing M_MSEG_WMB for plant | Assign correct business role to user |
| `I_MaterialStock` join returns no rows | Material not in `MARD`/`MSKA` | Check storage location assignment |

---

*Package version 1.0 · Compatible with SAP S/4HANA Public Cloud 2402+*
