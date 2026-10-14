# ZDMO01 — Bảng kê chuyến đi theo khách hàng

App Fiori Elements mẫu dùng lại bộ XLSX + attachment: danh sách khách hàng (`/DMO/CUSTOMER`), chọn dòng → **Export Excel** → file bảng kê các chuyến đi (`/DMO/TRAVEL`) lưu vào bộ attachment, tải ở cột **Bảng kê**. Khuôn giống ZWM13A / ZWM15.

## Objects (naming theo mã ticket `ZDMO01`)

| Object | Loại | Vai trò |
|---|---|---|
| `ZI_ZDMO01` | CDS view entity | Layer 1 — select `/dmo/customer` |
| `ZR_ZDMO01` | CDS root view entity | Layer 2 — join file `ZI_ATTACHMENT_DMO( 'DMO', 'ZDMO01' )` theo `DocumentId = CustomerID` |
| `ZC_ZDMO01` | CDS projection (`transactional_query`) | Layer 3 — cho Fiori |
| `ZC_ZDMO01` | DDLX | UI: list, object page, nút Export Excel, cột Bảng kê |
| `ZR_ZDMO01` / `ZC_ZDMO01` | DCL | R: `where TRUE` (dữ liệu demo) · C: `inheriting conditions from entity ZR_ZDMO01` |
| `ZR_ZDMO01` | BDEF managed | `persistent table ztb_att_dmo` + `mapping`, action `ExportExcel`, `side effects` |
| `ZC_ZDMO01` | BDEF projection | `use side effects`, `use action ExportExcel` |
| `ZBP_R_ZDMO01` | Behavior pool | `ExportExcel` → `ZCL_XLSX_ATT_EXPORT->export` |
| `ZCL_ZDMO01_SOURCE` | Class | Source class form `ZDMO01` (kế thừa `ZCL_XLSX_SOURCE_BASE`) |
| `ZUI_ZDMO01_O4` | Service definition + binding | OData V4 UI (`provider contracts odata_v4_ui`) |

Giá trị phải khớp nhau: form `ZDMO01` · module `DMO` · app id `ZDMO01` · document id = `CustomerID`.

## Phụ thuộc — pull + activate theo thứ tự

1. [`ZPK_XLSX`](https://github.com/KietNq1011/ZPK_XLSX) — engine render, app template `ZUI_XLSX_TMPL_O4`
2. [`ZPK_ATTACHMENT`](https://github.com/KietNq1011/ZPK_ATTACHMENT) — bộ lưu file `_DMO`
3. [`ZPK_XLSX_ATT`](https://github.com/KietNq1011/ZPK_XLSX_ATT) — `ZCL_XLSX_ATT_EXPORT`, `ZCL_XLSX_SOURCE_BASE`
4. Repo này — tạo package `ZDMO01`, link repo, Pull, Activate

Dữ liệu `/DMO/` trống thì chạy `/DMO/CL_FLIGHT_DATA_GENERATOR` (F9).

## Sau khi pull

1. **Template** — app `ZUI_XLSX_TMPL_O4` → Create: Form Name `ZDMO01`, Engine `XLSX`, file [`samples/ZDMO01_template.xlsx`](samples/ZDMO01_template.xlsx), **Source class `ZCL_ZDMO01_SOURCE`**, tick Active → **Save**. Preview để render thử bằng `get_sample`. Logo (tuỳ chọn): asset `LOGO_COMPANY`.
2. **Service binding** `ZUI_ZDMO01_O4` → Publish → Preview entity `Customer`.
3. Chọn khách hàng → **Export Excel** → bấm link cột **Bảng kê**.
4. Người dùng thật (ngoài Preview): tạo IAM App cho binding, gán vào Business Catalog `ZBC_ZDMO01`, Business Role.

## Template

Sinh lại file mẫu: `python samples/build_zdmo01_xlsx.py samples` (openpyxl). Placeholder:

| Ô | Placeholder |
|---|---|
| A1 | `{{*image:logo}}` |
| C3, C6–C8 | `{{printed_on}}`, `{{customer}}`, `{{address}}`, `{{email}}` |
| Dòng 11 (lặp) | `{{#travels}}{{@index}}` · `{{travel_id}}` · `{{agency}}` · `{{begin_date}}` · `{{end_date}}` · `{{status}}` · `{{total_price}}` · `{{currency}}{{/travels}}` |
| Dòng 12 | `{{cnt:travels}}`, `{{sum:travels.total_price}}` |

## Ghi chú

- DCL `ZR_ZDMO01` để `where TRUE` vì `/DMO/` không có authorization object dùng cho demo. App thật: thay bằng `aspect pfcg_auth( <object>, <field>, ACTVT = '03' )` như `ZR_ZWM13A`.
- `persistent table ztb_att_dmo` trong BDEF chỉ để thoả `managed`; BO không có create/update/delete nên framework không ghi bảng này — file được ghi qua `ZR_ATTACHMENT_DMO`.
- Chưa activate thử trên hệ thống.
